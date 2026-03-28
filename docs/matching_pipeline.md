# Matching pipeline (Firebase + Cloud Functions)

Server-side logic lives in **`functions/`**. The Flutter app only **queues** travellers and **reads** batches they belong to.

## Collections

| Path | Written by | Purpose |
|------|------------|---------|
| `users/{uid}` | App + Functions | Profile, `matchingStatus`, `batchId`, optional `fcmTokens` (vendors) |
| `destinations/{id}` | Functions (seed) | Named places + `tags[]` for hobby overlap + random draw |
| `batches/{batchId}` | Functions | `memberIds`, `destinationId`, `status`, `personalityScoreApprox` |
| `vendorOffers/{vendorUid}/incoming/{batchId}` | Functions | Offer row per vendor; vendor app listens here |

## Status values

**`users.matchingStatus`**

- `idle` — default (not in pool)
- `queued` — user tapped “Join matching”; eligible for next job
- `in_batch` — assigned to a `batches/{batchId}` doc

**`batches.status`** (extend later)

- `vendor_pending` — destination chosen; waiting for a vendor

**`vendorOffers/.../status`**

- `pending` — vendor can accept (accept flow not scaffolded yet)

## Algorithm (MVP)

1. Query `users` where `matchingStatus == "queued"` (then filter `onboardingComplete` + `role == user` in memory).
2. Shuffle, form groups of **6** with **greedy** growth: each next traveller maximizes **average Jaccard** over hobbies vs current batch, subject to a **soft sex ratio** (`|woman − man| ≤ 2` when adding).
3. Load `destinations`; if empty, **seed** sample Indian destinations (Goa, Manali, …).
4. Pick a destination: prefer tags overlapping **any** batch hobby; else uniform random.
5. **Batch write**: create `batches/{id}`, set users to `in_batch` + `batchId`, create `vendorOffers/{vid}/incoming/{batchId}` for each `users.role == vendor`.
6. **FCM** (optional): if `users/{vendorUid}.fcmTokens` is a `string[]`, send a multicast notification.

## Triggers

| Function | Type | When |
|----------|------|------|
| `scheduledMatching` | Scheduler `0 */6 * * *` (Asia/Kolkata) | Every 6 hours |
| `manualRunMatching` | Callable HTTPS | You pass `{ "triggerKey": "…", "dryRun": true }` for tests |

### Manual run (development)

1. Deploy functions: `firebase deploy --only functions`
2. In Google Cloud Console → Cloud Functions → `manualRunMatching` → add env **`MATCHING_TRIGGER_KEY`** (or rely on default `dev-change-me-before-production` only on a **private** project).
3. From app / curl / Firebase console “test function”, call with JSON body including `triggerKey`.

**`dryRun: true`** — computes batches but **does not** write Firestore.

## Deploy

```bash
cd functions && npm install && npm run build && cd ..
firebase deploy --only functions,firestore:rules
```

Ensure Blaze plan if you use **scheduler** or outbound networking beyond free tier quotas.

## Flutter app

- **Join pool**: sets `matchingStatus: queued` + `queuedAt` on the signed-in user.
- **Listen**: `batches/{batchId}` when you know `batchId` from `users/{uid}` (add a listener after profile load).

## Next steps (product)

- Trip-window overlap filter before batching.
- Vendor **accept** transaction (first wins) + `batches.assignedVendorUid`.
- Replace default `triggerKey` with **App Check** + admin custom claims.
- Cloud Function to **reset** `queued` users who aged out.
- Richer personality (embeddings) via Vertex AI.
