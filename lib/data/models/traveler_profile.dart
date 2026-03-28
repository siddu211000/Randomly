import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app/app_role.dart';

/// Fields collected for personality / trip matching (Firestore `users/{uid}`).
class TravelerProfile {
  const TravelerProfile({
    required this.uid,
    this.role = AppRole.user,
    this.displayName,
    this.hobbies = const [],
    this.personalityNote,
    this.tripWindowStart,
    this.tripWindowEnd,
    this.budgetMin,
    this.budgetMax,
    this.maxTravelDistanceKm,
    this.ageComfortMin = 18,
    this.ageComfortMax = 45,
    this.genderIdentity,
    this.onboardingComplete = false,
    this.matchingStatus,
    this.batchId,
    this.queuedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final AppRole role;
  final String? displayName;
  final List<String> hobbies;
  final String? personalityNote;
  final DateTime? tripWindowStart;
  final DateTime? tripWindowEnd;
  final double? budgetMin;
  final double? budgetMax;
  final double? maxTravelDistanceKm;
  final int ageComfortMin;
  final int ageComfortMax;
  final String? genderIdentity;
  final bool onboardingComplete;
  /// Server values: `idle` | `queued` | `in_batch` (omit / null treated as idle).
  final String? matchingStatus;
  final String? batchId;
  final DateTime? queuedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TravelerProfile copyWith({
    String? uid,
    AppRole? role,
    String? displayName,
    List<String>? hobbies,
    String? personalityNote,
    DateTime? tripWindowStart,
    DateTime? tripWindowEnd,
    double? budgetMin,
    double? budgetMax,
    double? maxTravelDistanceKm,
    int? ageComfortMin,
    int? ageComfortMax,
    String? genderIdentity,
    bool? onboardingComplete,
    String? matchingStatus,
    String? batchId,
    DateTime? queuedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TravelerProfile(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      hobbies: hobbies ?? this.hobbies,
      personalityNote: personalityNote ?? this.personalityNote,
      tripWindowStart: tripWindowStart ?? this.tripWindowStart,
      tripWindowEnd: tripWindowEnd ?? this.tripWindowEnd,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      maxTravelDistanceKm: maxTravelDistanceKm ?? this.maxTravelDistanceKm,
      ageComfortMin: ageComfortMin ?? this.ageComfortMin,
      ageComfortMax: ageComfortMax ?? this.ageComfortMax,
      genderIdentity: genderIdentity ?? this.genderIdentity,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      matchingStatus: matchingStatus ?? this.matchingStatus,
      batchId: batchId ?? this.batchId,
      queuedAt: queuedAt ?? this.queuedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'role': role.name,
      'displayName': displayName,
      'hobbies': hobbies,
      'personalityNote': personalityNote,
      'tripWindowStart': tripWindowStart != null
          ? Timestamp.fromDate(tripWindowStart!)
          : null,
      'tripWindowEnd':
          tripWindowEnd != null ? Timestamp.fromDate(tripWindowEnd!) : null,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'maxTravelDistanceKm': maxTravelDistanceKm,
      'ageComfortMin': ageComfortMin,
      'ageComfortMax': ageComfortMax,
      'genderIdentity': genderIdentity,
      'onboardingComplete': onboardingComplete,
      if (matchingStatus != null) 'matchingStatus': matchingStatus,
      if (batchId != null) 'batchId': batchId,
      if (queuedAt != null) 'queuedAt': Timestamp.fromDate(queuedAt!),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static TravelerProfile fromMap(String uid, Map<String, dynamic> map) {
    DateTime? tsToDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      return null;
    }

    return TravelerProfile(
      uid: uid,
      role: appRoleFromWire(map['role'] as String?) ?? AppRole.user,
      displayName: map['displayName'] as String?,
      hobbies: List<String>.from(map['hobbies'] as List<dynamic>? ?? const []),
      personalityNote: map['personalityNote'] as String?,
      tripWindowStart: tsToDate(map['tripWindowStart']),
      tripWindowEnd: tsToDate(map['tripWindowEnd']),
      budgetMin: (map['budgetMin'] as num?)?.toDouble(),
      budgetMax: (map['budgetMax'] as num?)?.toDouble(),
      maxTravelDistanceKm: (map['maxTravelDistanceKm'] as num?)?.toDouble(),
      ageComfortMin: (map['ageComfortMin'] as num?)?.toInt() ?? 18,
      ageComfortMax: (map['ageComfortMax'] as num?)?.toInt() ?? 45,
      genderIdentity: map['genderIdentity'] as String?,
      onboardingComplete: map['onboardingComplete'] as bool? ?? false,
      matchingStatus: map['matchingStatus'] as String?,
      batchId: map['batchId'] as String?,
      queuedAt: tsToDate(map['queuedAt']),
      createdAt: tsToDate(map['createdAt']),
      updatedAt: tsToDate(map['updatedAt']),
    );
  }
}
