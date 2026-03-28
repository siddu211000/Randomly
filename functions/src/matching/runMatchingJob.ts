import * as logger from "firebase-functions/logger";
import type { DocumentData, Firestore } from "firebase-admin/firestore";
import { FieldValue } from "firebase-admin/firestore";
import type { DestinationDoc, UserDoc } from "./types";
import { avgJaccardToGroup, jaccard, ratioAllowsAdd } from "./scoring";

const BATCH_SIZE = 6;

const SAMPLE_DESTINATIONS: DestinationDoc[] = [
  { id: "dest_goa", name: "Goa", tags: ["Beach", "Nightlife", "Music"], region: "IN-West" },
  { id: "dest_manali", name: "Manali", tags: ["Hiking", "Nature", "Photography"], region: "IN-North" },
  { id: "dest_jaipur", name: "Jaipur", tags: ["Art", "Food", "Photography"], region: "IN-West" },
  { id: "dest_munnar", name: "Munnar", tags: ["Nature", "Wellness", "Photography"], region: "IN-South" },
  { id: "dest_udaipur", name: "Udaipur", tags: ["Art", "Food", "Music"], region: "IN-West" },
];

function shuffle<T>(arr: T[]): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

function toUserDoc(id: string, data: DocumentData): UserDoc {
  return {
    id,
    hobbies: Array.isArray(data.hobbies) ? data.hobbies.map(String) : [],
    genderIdentity: data.genderIdentity as string | undefined,
    role: data.role as string | undefined,
    onboardingComplete: data.onboardingComplete === true,
    matchingStatus: data.matchingStatus as string | undefined,
    batchId: data.batchId as string | undefined,
    raw: data,
  };
}

async function ensureSampleDestinations(db: Firestore): Promise<void> {
  const snap = await db.collection("destinations").limit(1).get();
  if (!snap.empty) return;
  const batch = db.batch();
  for (const d of SAMPLE_DESTINATIONS) {
    batch.set(db.collection("destinations").doc(d.id), {
      name: d.name,
      tags: d.tags,
      region: d.region ?? null,
      createdAt: FieldValue.serverTimestamp(),
    });
  }
  await batch.commit();
  logger.info("Seeded sample destinations", { count: SAMPLE_DESTINATIONS.length });
}

function buildGreedyBatch(pool: UserDoc[], size: number): UserDoc[] {
  if (pool.length === 0) return [];
  const remaining = [...pool];
  const first = remaining.shift()!;
  const batch: UserDoc[] = [first];
  while (batch.length < size && remaining.length > 0) {
    let bestI = -1;
    let bestScore = -1;
    for (let i = 0; i < remaining.length; i++) {
      const cand = remaining[i]!;
      if (!ratioAllowsAdd(batch, cand)) continue;
      const score = avgJaccardToGroup(batch, cand);
      if (score > bestScore) {
        bestScore = score;
        bestI = i;
      }
    }
    if (bestI < 0) {
      for (let i = 0; i < remaining.length; i++) {
        if (ratioAllowsAdd(batch, remaining[i]!)) {
          bestI = i;
          break;
        }
      }
    }
    if (bestI < 0) break;
    batch.push(remaining.splice(bestI, 1)[0]!);
  }
  return batch;
}

function batchCohesion(members: UserDoc[]): number {
  if (members.length < 2) return 1;
  let sum = 0;
  let n = 0;
  for (let i = 0; i < members.length; i++) {
    for (let j = i + 1; j < members.length; j++) {
      sum += jaccard(members[i]!.hobbies || [], members[j]!.hobbies || []);
      n++;
    }
  }
  return n === 0 ? 0 : sum / n;
}

function pickDestination(
  dests: DestinationDoc[],
  members: UserDoc[],
): DestinationDoc {
  const allHobbies = new Set(
    members.flatMap((m) => (m.hobbies || []).map((h) => h.toLowerCase())),
  );
  const tagged = dests.filter((d) =>
    d.tags.some((t) => allHobbies.has(t.toLowerCase())),
  );
  const pool = tagged.length > 0 ? tagged : dests;
  return pool[Math.floor(Math.random() * pool.length)]!;
}

export interface RunMatchingResult {
  batchesCreated: number;
  memberIdsGrouped: string[][];
  dryRun: boolean;
}

export async function runMatchingJob(
  db: Firestore,
  options: { dryRun?: boolean } = {},
): Promise<RunMatchingResult> {
  const dryRun = options.dryRun === true;
  await ensureSampleDestinations(db);

  const usersSnap = await db
    .collection("users")
    .where("matchingStatus", "==", "queued")
    .limit(120)
    .get();

  const candidates: UserDoc[] = [];
  for (const doc of usersSnap.docs) {
    const u = toUserDoc(doc.id, doc.data());
    if (u.onboardingComplete !== true) continue;
    if (u.role && u.role !== "user") continue;
    candidates.push(u);
  }

  if (candidates.length < BATCH_SIZE) {
    logger.info("Not enough queued travellers", { count: candidates.length });
    return { batchesCreated: 0, memberIdsGrouped: [], dryRun };
  }

  const pool = shuffle(candidates);
  const batches: UserDoc[][] = [];
  let rest = [...pool];
  while (rest.length >= BATCH_SIZE) {
    const batch = buildGreedyBatch(rest, BATCH_SIZE);
    const ids = new Set(batch.map((b) => b.id));
    rest = rest.filter((u) => !ids.has(u.id));
    batches.push(batch);
  }

  const destSnap = await db.collection("destinations").get();
  const dests: DestinationDoc[] = destSnap.docs.map((d) => {
    const x = d.data();
    return {
      id: d.id,
      name: String(x.name ?? d.id),
      tags: Array.isArray(x.tags) ? x.tags.map(String) : [],
      region: x.region as string | undefined,
    };
  });

  if (dests.length === 0) {
    logger.warn("No destinations after seed — abort");
    return { batchesCreated: 0, memberIdsGrouped: [], dryRun };
  }

  const memberIdsGrouped: string[][] = [];

  if (dryRun) {
    for (const b of batches) {
      memberIdsGrouped.push(b.map((m) => m.id));
    }
    return { batchesCreated: batches.length, memberIdsGrouped, dryRun: true };
  }

  const vendorsSnap = await db
    .collection("users")
    .where("role", "==", "vendor")
    .limit(50)
    .get();
  const vendorIds = vendorsSnap.docs.map((d) => d.id);

  for (const members of batches) {
    const dest = pickDestination(dests, members);
    const batchId = `batch_${Date.now()}_${Math.random().toString(36).slice(2, 10)}`;
    const memberIds = members.map((m) => m.id);
    memberIdsGrouped.push(memberIds);

    const personalityScore = batchCohesion(members);

    const writeBatch = db.batch();

    writeBatch.set(db.collection("batches").doc(batchId), {
      memberIds,
      destinationId: dest.id,
      destinationName: dest.name,
      status: "vendor_pending",
      personalityScoreApprox: Math.round(personalityScore * 1000) / 1000,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    for (const uid of memberIds) {
      writeBatch.update(db.collection("users").doc(uid), {
        matchingStatus: "in_batch",
        batchId,
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    for (const vid of vendorIds) {
      const offerRef = db
        .collection("vendorOffers")
        .doc(vid)
        .collection("incoming")
        .doc(batchId);
      writeBatch.set(offerRef, {
        batchId,
        destinationId: dest.id,
        destinationName: dest.name,
        memberCount: memberIds.length,
        status: "pending",
        createdAt: FieldValue.serverTimestamp(),
      });
    }

    await writeBatch.commit();
    logger.info("Created batch", { batchId, memberIds, destination: dest.id });

    await notifyVendorsIfPossible(db, vendorIds, batchId, dest.name, memberIds.length);
  }

  return { batchesCreated: batches.length, memberIdsGrouped, dryRun: false };
}

async function notifyVendorsIfPossible(
  db: Firestore,
  vendorIds: string[],
  batchId: string,
  destinationName: string,
  memberCount: number,
): Promise<void> {
  try {
    const { getMessaging } = await import("firebase-admin/messaging");
    const messaging = getMessaging();
    for (const vid of vendorIds) {
      const doc = await db.collection("users").doc(vid).get();
      const tokens = doc.data()?.fcmTokens;
      if (!Array.isArray(tokens) || tokens.length === 0) continue;
      const valid = tokens.filter((t: unknown) => typeof t === "string") as string[];
      if (valid.length === 0) continue;
      await messaging.sendEachForMulticast({
        tokens: valid,
        notification: {
          title: "New trip batch",
          body: `${memberCount} travellers · ${destinationName} · Open app to respond`,
        },
        data: { batchId, type: "vendor_batch_offer" },
      });
    }
  } catch (e) {
    logger.warn("FCM skipped or failed (add fcmTokens[] on vendor user docs)", { e });
  }
}
