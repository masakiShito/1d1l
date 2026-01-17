import '../errors/validation_error.dart';

class LogValidator {
  static const int minLength = 1;
  static const int maxLength = 500;

  ValidationResult validate(String text) {
    final issues = <ValidationIssue>[];
    final normalized = text.trim();

    if (normalized.isEmpty) {
      return const ValidationResult([]);
    }

    if (normalized.length < minLength) {
      issues.add(
        const ValidationIssue(
          field: 'text',
          code: 'minLength',
          message: '本文は1文字以上で入力してください。',
        ),
      );
    }

    if (normalized.length > maxLength) {
      issues.add(
        const ValidationIssue(
          field: 'text',
          code: 'maxLength',
          message: '本文は500文字以内で入力してください。',
        ),
      );
    }

    if (normalized.contains('\u0000')) {
      issues.add(
        const ValidationIssue(
          field: 'text',
          code: 'invalidChars',
          message: '使用できない文字が含まれています。',
        ),
      );
    }

    return ValidationResult(issues);
  }
}
