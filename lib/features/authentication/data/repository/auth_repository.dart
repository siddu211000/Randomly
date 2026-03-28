import '../models/auth_credentials.dart';

abstract class AuthRepository {
  Future<void> signIn(AuthCredentials credentials);
  Future<void> signOut();
}
