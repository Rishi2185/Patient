import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';

/// Persists the small amount of app settings/session state in
/// `shared_preferences`: the JWT, the cached signed-in user (JSON), and the
/// (overridable) backend base URL.
class SettingsStore {
  static const _kToken = 'authToken';
  static const _kBaseUrl = 'baseUrl';
  static const _kSessionUser = 'sessionUser';

  /// The default backend, used until the user overrides it.
  static const String defaultBaseUrl = kDefaultBaseUrl;

  final SharedPreferences _prefs;
  SettingsStore._(this._prefs);

  static Future<SettingsStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsStore._(prefs);
  }

  // ---- base URL ----
  String get baseUrl => _prefs.getString(_kBaseUrl) ?? defaultBaseUrl;
  Future<void> setBaseUrl(String v) => _prefs.setString(_kBaseUrl, v.trim());

  // ---- auth token ----
  String? get token => _prefs.getString(_kToken);
  Future<void> setToken(String? v) async {
    if (v == null) {
      await _prefs.remove(_kToken);
    } else {
      await _prefs.setString(_kToken, v);
    }
  }

  // ---- cached session user (raw JSON) ----
  String? get sessionUserJson => _prefs.getString(_kSessionUser);
  Future<void> setSessionUserJson(String? v) async {
    if (v == null) {
      await _prefs.remove(_kSessionUser);
    } else {
      await _prefs.setString(_kSessionUser, v);
    }
  }

  /// Clear the persisted session (token + cached user) on sign-out.
  Future<void> clearSession() async {
    await _prefs.remove(_kToken);
    await _prefs.remove(_kSessionUser);
  }
}
