import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../api/api_exception.dart';
import '../api/auth_api.dart';
import '../models/app_user.dart';
import 'services.dart';

/// Handles the patient session against the backend: phone+password sign-in,
/// OTP-gated sign-up and password reset, token persistence and sign-out.
///
/// All the action methods return `null` on success or a human-friendly error
/// message on failure, matching how the auth screens already consume them.
class AuthProvider extends ChangeNotifier {
  final Services _services;

  AppUser? _user;
  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;

  /// The last dev OTP returned by the backend (non-production only). Shown as a
  /// demo hint on the OTP screen so testers don't need a real SMS.
  String? _lastDevCode;
  String? get lastDevCode => _lastDevCode;

  AuthProvider(this._services) {
    _services.api.onUnauthorized = _onUnauthorized;
  }

  /// Restore a persisted session (token + cached user) on launch.
  Future<void> init() async {
    final token = _services.settings.token;
    final raw = _services.settings.sessionUserJson;
    if (token == null || raw == null) return;
    try {
      _user = AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      _services.api.token = token;
    } catch (_) {
      await _services.settings.clearSession();
    }
    notifyListeners();
  }

  /// Sign in with phone + password. Returns an error message, or null.
  Future<String?> signIn({
    required String phone,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final result = await _services.auth.login(phone, password);
      await _applySession(result, persist: rememberMe);
      return null;
    } on ApiException catch (e) {
      return _friendly(e, on401: 'Incorrect phone number or password.');
    }
  }

  /// Request a sign-up OTP for a new number. The backend rejects numbers that
  /// already have an account. Returns an error message, or null.
  Future<String?> requestSignupOtp(String phone) =>
      _requestOtp(phone, OtpPurpose.signup);

  /// Request a password-reset OTP for an existing number. Returns an error, or
  /// null.
  Future<String?> requestResetOtp(String phone) =>
      _requestOtp(phone, OtpPurpose.reset);

  Future<String?> _requestOtp(String phone, String purpose) async {
    try {
      _lastDevCode = await _services.auth.requestOtp(
        phone: phone,
        purpose: purpose,
      );
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return _friendly(e);
    }
  }

  /// Check a code against the backend (does not consume it). Returns an error
  /// message when the code is wrong/expired, or null when valid.
  Future<String?> verifyOtp({
    required String phone,
    required String purpose,
    required String code,
  }) async {
    try {
      final valid = await _services.auth.verifyOtp(
        phone: phone,
        purpose: purpose,
        code: code,
      );
      return valid ? null : 'Incorrect or expired code. Please try again.';
    } on ApiException catch (e) {
      return _friendly(e);
    }
  }

  /// Register a new account (with a verified OTP) and sign in. Returns an error
  /// message, or null.
  Future<String?> signUp({
    required String username,
    required String phone,
    required String password,
    required String otp,
  }) async {
    try {
      final result = await _services.auth.signup(
        username: username,
        phone: phone,
        password: password,
        otp: otp,
      );
      await _applySession(result, persist: true);
      return null;
    } on ApiException catch (e) {
      return _friendly(e);
    }
  }

  /// Reset an existing account's password (with a verified OTP). Returns an
  /// error message, or null.
  Future<String?> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _services.auth.resetPassword(
        phone: phone,
        otp: otp,
        newPassword: newPassword,
      );
      return null;
    } on ApiException catch (e) {
      return _friendly(e);
    }
  }

  Future<void> signOut() async {
    await _services.settings.clearSession();
    _services.api.token = null;
    _user = null;
    _lastDevCode = null;
    notifyListeners();
  }

  Future<void> _applySession(AuthResult result, {required bool persist}) async {
    _user = result.user;
    _services.api.token = result.token;
    _lastDevCode = null;
    if (persist) {
      await _services.settings.setToken(result.token);
      await _services.settings.setSessionUserJson(jsonEncode(result.user.toJson()));
    }
    notifyListeners();
  }

  void _onUnauthorized() {
    // Session expired server-side — drop it so the UI returns to sign-in.
    if (_user != null) signOut();
  }

  String _friendly(ApiException e, {String? on401}) {
    if (e.isNetwork) return e.message;
    if (e.status == 401 && on401 != null) return on401;
    return e.message;
  }
}
