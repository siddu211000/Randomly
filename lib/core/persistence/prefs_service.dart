/// Key–value persistence. Backed by [shared_preferences] in production.
abstract class PrefsService {
  Future<bool> getBool(String key, {bool defaultValue = false});
  Future<void> setBool(String key, bool value);

  Future<String?> getString(String key);
  Future<void> setString(String key, String value);

  Future<int?> getInt(String key);
  Future<void> setInt(String key, int value);

  Future<void> remove(String key);
}
