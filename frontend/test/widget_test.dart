// Smoke tests for the Aarvy patient app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aarvy_patient/utils/validators.dart';
import 'package:aarvy_patient/widgets/avatar.dart';

void main() {
  group('Validators', () {
    test('rejects invalid phone numbers', () {
      expect(Validators.phone(''), isNotNull);
      expect(Validators.phone('123'), isNotNull);
      expect(Validators.phone('9999999999'), isNull);
    });

    test('enforces minimum password length', () {
      expect(Validators.password('short'), isNotNull);
      expect(Validators.password('longenough1'), isNull);
    });

    test('confirm password must match', () {
      expect(Validators.confirmPassword('abc', 'abc'), isNull);
      expect(Validators.confirmPassword('abc', 'xyz'), isNotNull);
    });

    test('password strength scales with complexity', () {
      expect(scorePassword(''), PasswordStrength.empty);
      expect(scorePassword('aaaa').index,
          lessThan(scorePassword('Aa1!aa9Zx2#').index));
    });
  });

  testWidgets('Avatar shows initials when no image provided', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Avatar(name: 'Dr. Ananya Sharma')),
    ));
    expect(find.text('AS'), findsOneWidget);
  });
}
