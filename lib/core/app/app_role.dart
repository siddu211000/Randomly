/// Portal / experience type. Start with [user]; vendor and admin reuse the same core stack.
enum AppRole {
  user,
  vendor,
  admin,
}

AppRole? appRoleFromWire(String? value) {
  if (value == null) return null;
  for (final r in AppRole.values) {
    if (r.name == value) return r;
  }
  return null;
}
