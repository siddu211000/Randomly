import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/traveler_profile.dart';

/// Firestore: `users/{uid}` — same collection can later branch by `role`.
class TravelerProfileRepository {
  TravelerProfileRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<TravelerProfile?> fetchProfile(String uid) async {
    final snap = await _users.doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return TravelerProfile.fromMap(uid, snap.data()!);
  }

  Stream<TravelerProfile?> watchProfile(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return TravelerProfile.fromMap(uid, snap.data()!);
    });
  }

  Future<void> saveProfile(TravelerProfile profile) async {
    final data = profile.toMap();
    if (profile.createdAt == null) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    await _users.doc(profile.uid).set(data, SetOptions(merge: true));
  }

  /// Enters the server-side matching queue (`scheduledMatching` / manual job).
  Future<void> joinMatchingPool(String uid) async {
    await _users.doc(uid).set(
      {
        'matchingStatus': 'queued',
        'queuedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Stream<Map<String, dynamic>?> watchBatchDoc(String batchId) {
    return _db.collection('batches').doc(batchId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return snap.data();
    });
  }
}
