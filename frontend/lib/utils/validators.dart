/// Form validation helpers + password-strength scoring.
class Validators {
  Validators._();

  /// Indian-style 10-digit phone validation (demo).
  static String? phone(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\d{10}$').hasMatch(v)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? username(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Username is required';
    if (v.length < 3) return 'Username must be at least 3 characters';
    return null;
  }

  static String? password(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Use at least 8 characters';
    return null;
  }

  static String? confirmPassword(String value, String original) {
    if (value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }
}

/// Password strength levels with label + 0..1 progress + indicative color tier.
enum PasswordStrength { empty, weak, fair, good, strong }

extension PasswordStrengthX on PasswordStrength {
  String get label {
    switch (this) {
      case PasswordStrength.empty:
        return '';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.fair:
        return 'Fair';
      case PasswordStrength.good:
        return 'Good';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  double get progress {
    switch (this) {
      case PasswordStrength.empty:
        return 0;
      case PasswordStrength.weak:
        return 0.25;
      case PasswordStrength.fair:
        return 0.5;
      case PasswordStrength.good:
        return 0.75;
      case PasswordStrength.strong:
        return 1;
    }
  }
}

PasswordStrength scorePassword(String password) {
  if (password.isEmpty) return PasswordStrength.empty;
  var score = 0;
  if (password.length >= 8) score++;
  if (password.length >= 12) score++;
  if (RegExp(r'[A-Z]').hasMatch(password) &&
      RegExp(r'[a-z]').hasMatch(password)) {
    score++;
  }
  if (RegExp(r'\d').hasMatch(password)) score++;
  if (RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(password)) score++;

  if (score <= 1) return PasswordStrength.weak;
  if (score == 2) return PasswordStrength.fair;
  if (score == 3 || score == 4) return PasswordStrength.good;
  return PasswordStrength.strong;
}
