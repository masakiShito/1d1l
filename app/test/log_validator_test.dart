import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/validators/log_validator.dart';

void main() {
  group('LogValidator', () {
    test('accepts empty text', () {
      final validator = LogValidator();

      final result = validator.validate('');

      expect(result.isValid, isTrue);
      expect(result.firstMessageFor('text'), isNull);
    });

    test('returns max length error when text is too long', () {
      final validator = LogValidator();
      final longText = List.filled(LogValidator.maxLength + 1, 'a').join();

      final result = validator.validate(longText);

      expect(result.isValid, isFalse);
      expect(result.firstMessageFor('text'), '本文は500文字以内で入力してください。');
    });

    test('accepts valid text', () {
      final validator = LogValidator();

      final result = validator.validate('今日のログ');

      expect(result.isValid, isTrue);
      expect(result.firstMessageFor('text'), isNull);
    });
  });
}
