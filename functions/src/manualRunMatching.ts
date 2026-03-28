import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore } from "firebase-admin/firestore";
import { runMatchingJob } from "./matching/runMatchingJob";

/**
 * Callable for testing / admin tools.
 * Pass { "triggerKey": "<same as MATCHING_TRIGGER_KEY>", "dryRun": true|false }
 *
 * Set secret before deploy:
 *   firebase functions:secrets:set MATCHING_TRIGGER_KEY
 * Or use .env with firebase-functions v2 params (see Firebase docs).
 *
 * Default dev key below — change in production via environment config.
 */
export const manualRunMatching = onCall(async (request) => {
  const expected =
    process.env.MATCHING_TRIGGER_KEY ?? "dev-change-me-before-production";
  const key = request.data?.triggerKey as string | undefined;
  if (key !== expected) {
    throw new HttpsError(
      "permission-denied",
      "Invalid or missing triggerKey. Set MATCHING_TRIGGER_KEY env on the function.",
    );
  }
  const dryRun = request.data?.dryRun === true;
  const db = getFirestore();
  const result = await runMatchingJob(db, { dryRun });
  return result;
});
