/// Sign-in / sign-up input carried from UI toward the repository layer.
final class AuthCredentials {
  const AuthCredentials({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}
