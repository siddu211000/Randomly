import type { UserDoc } from "./types";

/** Jaccard similarity on hobby tag sets (0–1). */
export function jaccard(a: string[], b: string[]): number {
  const A = new Set(a.map((x) => x.toLowerCase()));
  const B = new Set(b.map((x) => x.toLowerCase()));
  if (A.size === 0 && B.size === 0) return 1;
  let inter = 0;
  for (const x of A) {
    if (B.has(x)) inter++;
  }
  const union = A.size + B.size - inter;
  return union === 0 ? 0 : inter / union;
}

/** Average Jaccard between candidate and everyone already in the batch. */
export function avgJaccardToGroup(
  members: UserDoc[],
  candidate: UserDoc,
): number {
  if (members.length === 0) return 1;
  const h = candidate.hobbies || [];
  let sum = 0;
  for (const m of members) {
    sum += jaccard(h, m.hobbies || []);
  }
  return sum / members.length;
}

export type GenderBucket = "woman" | "man" | "non_binary" | "other";

export function genderBucket(g: string | undefined): GenderBucket {
  if (g === "woman") return "woman";
  if (g === "man") return "man";
  if (g === "non_binary") return "non_binary";
  return "other";
}

/**
 * Soft balance: keep |woman − man| ≤ 2 when adding (other/non_binary exempt).
 * Skipped when batch is mostly "other".
 */
export function ratioAllowsAdd(batch: UserDoc[], candidate: UserDoc): boolean {
  const counts = { woman: 0, man: 0 };
  const add = (u: UserDoc) => {
    const b = genderBucket(u.genderIdentity);
    if (b === "woman") counts.woman++;
    else if (b === "man") counts.man++;
  };
  for (const m of batch) add(m);
  add(candidate);
  return Math.abs(counts.woman - counts.man) <= 2;
}
