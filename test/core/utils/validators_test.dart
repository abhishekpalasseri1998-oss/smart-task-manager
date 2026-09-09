import 'package:flutter_test/flutter_test.dart';
import 'package:smart_task_manager/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('validateEmail returns null for valid email', () {
      expect(Validators.validateEmail('user@example.com'), isNull);
    });

    test('validateEmail returns error for invalid email', () {
      expect(Validators.validateEmail('invalid-email'), equals('Please enter a valid email address'));
      expect(Validators.validateEmail(''), equals('Email is required'));
      expect(Validators.validateEmail(null), equals('Email is required'));
    });

    test('validatePassword returns null for password >= 6 chars', () {
      expect(Validators.validatePassword('123456'), isNull);
    });

    test('validatePassword returns error for password < 6 chars', () {
      expect(Validators.validatePassword('12345'), equals('Password must be at least 6 characters'));
      expect(Validators.validatePassword(''), equals('Password is required'));
      expect(Validators.validatePassword(null), equals('Password is required'));
    });

    test('validateName returns null for valid name', () {
      expect(Validators.validateName('John Doe'), isNull);
    });

    test('validateName returns error for short or empty name', () {
      expect(Validators.validateName('A'), equals('Name must be at least 2 characters'));
      expect(Validators.validateName(''), equals('Name is required'));
      expect(Validators.validateName(null), equals('Name is required'));
    });
  });
}
