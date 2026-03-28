import type { DocumentData } from "firebase-admin/firestore";

export type MatchingStatus = "idle" | "queued" | "in_batch";

export interface UserDoc {
  id: string;
  hobbies: string[];
  genderIdentity?: string;
  role?: string;
  onboardingComplete?: boolean;
  matchingStatus?: string;
  batchId?: string;
  raw: DocumentData;
}

export interface DestinationDoc {
  id: string;
  name: string;
  tags: string[];
  region?: string;
}
