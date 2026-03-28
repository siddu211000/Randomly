import '../models/profile_summary.dart';

abstract class ProfileRepository {
  Future<ProfileSummary> loadProfile();
}
