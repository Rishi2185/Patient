import '../models/app_user.dart';
import 'api_client.dart';

/// OTP purposes understood by the backend (`/auth/otp/*`, signup, reset).
class OtpPurpose {
  static const String signup = 'signup';
  static const String reset = 'reset';
}

/// The result of a successful login/signup: a JWT plus the patient record.
class AuthResult {
  final String token;
  final AppUser user;
  const AuthResult({required this.token, required this.user});
}

/// Patient authentication endpoints: phone+password login, OTP-gated signup and
/// password reset, plus the phone-exists helper.
class AuthApi {
  final ApiClient _client;
  AuthApi(this._client);

  /// POST /auth/login  { phone, password } -> { token, user }
  Future<AuthResult> login(String phone, String password) async {
    final data = await _client.post('/auth/login', body: {
      'phone': phone,
      'password': password,
    }) as Map<String, dynamic>;
    return _result(data);
  }

  /// POST /auth/signup  { username, phone, password, otp } -> { token, user }
  Future<AuthResult> signup({
    required String username,
    required String phone,
    required String password,
    required String otp,
  }) async {
    final data = await _client.post('/auth/signup', body: {
      'username': username,
      'phone': phone,
      'password': password,
      'otp': otp,
    }) as Map<String, dynamic>;
    return _result(data);
  }

  /// POST /auth/otp/request  { phone, purpose } -> { sent, expiresInMinutes, devCode? }
  /// Returns the `devCode` (only present in non-production) for the demo hint.
  Future<String?> requestOtp({
    required String phone,
    required String purpose,
  }) async {
    final data = await _client.post('/auth/otp/request', body: {
      'phone': phone,
      'purpose': purpose,
    }) as Map<String, dynamic>;
    return data['devCode'] as String?;
  }

  /// POST /auth/otp/verify  { phone, purpose, code } -> { valid }
  Future<bool> verifyOtp({
    required String phone,
    required String purpose,
    required String code,
  }) async {
    final data = await _client.post('/auth/otp/verify', body: {
      'phone': phone,
      'purpose': purpose,
      'code': code,
    }) as Map<String, dynamic>;
    return (data['valid'] ?? false) as bool;
  }

  /// POST /auth/reset-password  { phone, otp, newPassword } -> { reset }
  Future<void> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    await _client.post('/auth/reset-password', body: {
      'phone': phone,
      'otp': otp,
      'newPassword': newPassword,
    });
  }

  /// GET /auth/check-phone?phone= -> { exists }
  Future<bool> checkPhone(String phone) async {
    final data = await _client.get('/auth/check-phone', query: {'phone': phone})
        as Map<String, dynamic>;
    return (data['exists'] ?? false) as bool;
  }

  /// GET /auth/me -> { id, username, phone }
  Future<AppUser> me() async =>
      AppUser.fromJson(await _client.get('/auth/me') as Map<String, dynamic>);

  AuthResult _result(Map<String, dynamic> data) => AuthResult(
        token: (data['token'] ?? '') as String,
        user: AppUser.fromJson((data['user'] ?? const {}) as Map<String, dynamic>),
      );
}
