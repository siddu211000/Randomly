import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore } from "firebase-admin/firestore";
import { runMatchingJob } from "./matching/runMatchingJob";

/** Runs matching every 6 hours (Asia/Kolkata). Adjust in Firebase Console if needed. */
export const scheduledMatching = onSchedule(
  {
    schedule: "0 */6 * * *",
    timeZone: "Asia/Kolkata",
    memory: "512MiB",
    timeoutSeconds: 300,
  },
  async () => {
    const db = getFirestore();
    await runMatchingJob(db);
  },
);
