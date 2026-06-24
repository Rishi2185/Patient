import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';

/// Handles sign-up, sign-in, OTP (simulated), session persistence and
/// "remember me". All data is local — no backend.
class AuthProvider extends ChangeNotifier {
  static const _kUsers = 'registered_users';
  static const _kSessionPhone = 'session_phone';

  /// Fixed demo OTP used everywhere a code is requested.
  static const String demoOtp = '1234';

  AppUser? _user;
  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;

  // phone -> {username, password}
  Map<String, Map<String, String>> _users = {};

  SharedPreferences? _prefs;

  /// Load persisted accounts + restore a "remember me" session.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    final raw = _prefs!.getString(_kUsers);
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _users = decoded.map(
        (k, v) => MapEntry(k, Map<String, String>.from(v as Map)),
      );
    }

    // Seed a ready-to-use demo account on first launch.
    if (!_users.containsKey('9999999999')) {
      _users['9999999999'] = {
        'username': 'Demo Patient',
        'password': 'demo1234',
      };
      await _persistUsers();
    }

    final sessionPhone = _prefs!.getString(_kSessionPhone);
    if (sessionPhone != null && _users.containsKey(sessionPhone)) {
      _user = AppUser(
        username: _users[sessionPhone]!['username']!,
        phone: sessionPhone,
      );
    }
    notifyListeners();
  }

  bool phoneExists(String phone) => _users.containsKey(phone);

  Future<void> _persistUsers() async {
    await _prefs?.setString(_kUsers, jsonEncode(_users));
  }

  /// Register a new account. Returns an error message, or null on success.
  Future<String?> signUp({
    required String username,
    required String phone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (_users.containsKey(phone)) {
      return 'An account with this number already exists.';
    }
    _users[phone] = {'username': username, 'password': password};
    await _persistUsers();
    return null;
  }

  /// Sign in with phone + password. Returns an error message, or null.
  Future<String?> signIn({
    required String phone,
    required String password,
    required bool rememberMe,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final record = _users[phone];
    if (record == null) {
      return 'No account found for this number.';
    }
    if (record['password'] != password) {
      return 'Incorrect password. Please try again.';
    }
    _user = AppUser(username: record['username']!, phone: phone);
    if (rememberMe) {
      await _prefs?.setString(_kSessionPhone, phone);
    } else {
      await _prefs?.remove(_kSessionPhone);
    }
    notifyListeners();
    return null;
  }

  /// Simulate sending an OTP to a phone number.
  Future<void> sendOtp(String phone) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    // In a real app this triggers an SMS. Here the code is always [demoOtp].
  }

  bool verifyOtp(String code) => code.trim() == demoOtp;

  /// Reset password for an existing account (after OTP).
  Future<String?> resetPassword({
    required String phone,
    required String newPassword,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!_users.containsKey(phone)) {
      return 'No account found for this number.';
    }
    _users[phone]!['password'] = newPassword;
    await _persistUsers();
    return null;
  }

  Future<void> signOut() async {
    _user = null;
    await _prefs?.remove(_kSessionPhone);
    notifyListeners();
  }
}
