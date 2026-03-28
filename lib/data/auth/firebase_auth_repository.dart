import 'package:firebase_auth/firebase_auth.dart';

/// Anonymous sign-in for early prototypes; swap for phone/email + KYC later.
class FirebaseAuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Ensures a signed-in [User] (anonymous if none).
  Future<User> ensureSignedIn() async {
    final existing = _auth.currentUser;
    if (existing != null) return existing;
    final cred = await _auth.signInAnonymously();
    final user = cred.user;
    if (user == null) {
      throw StateError('Anonymous sign-in returned no user');
    }
    return user;
  }

  Future<void> signOut() => _auth.signOut();
}
