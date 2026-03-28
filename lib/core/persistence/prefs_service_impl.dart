import 'package:shared_preferences/shared_preferences.dart';

import 'prefs_service.dart';

class PrefsServiceImpl implements PrefsService {
  PrefsServiceImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<bool> getBool(String key, {bool defaultValue = false}) async =>
      _prefs.getBool(key) ?? defaultValue;

  @override
  Future<void> setBool(String key, bool value) async => _prefs.setBool(key, value);

  @override
  Future<String?> getString(String key) async => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) async =>
      _prefs.setString(key, value);

  @override
  Future<int?> getInt(String key) async {
    final v = _prefs.getInt(key);
    return v;
  }

  @override
  Future<void> setInt(String key, int value) async => _prefs.setInt(key, value);

  @override
  Future<void> remove(String key) async => _prefs.remove(key);
}
