import '../errors/validation_error.dart';

class LogValidator {
  static const int minLength = 1;
  static const int maxLength = 500;

  ValidationResult validate(String text) {
    final issues = <ValidationIssue>[];
    final normalized = text.trim();

    if (normalized.isEmpty) {
      issues.add(
        const ValidationIssue(
          field: 'text',
          code: 'required',
          message: '今日はまだ書かれてないみたい',
        ),
      );
      return ValidationResult(issues);
    }

    if (normalized.length < minLength) {
      issues.add(
        const ValidationIssue(
          field: 'text',
          code: 'minLength',
          message: 'もう少しだけ言葉を足してみよう',
        ),
      );
    }

    if (normalized.length > maxLength) {
      issues.add(
        const ValidationIssue(
          field: 'text',
          code: 'maxLength',
          message: '少し長いかも。500文字以内におさめよう',
        ),
      );
    }

    if (normalized.contains('\u0000')) {
      issues.add(
        const ValidationIssue(
          field: 'text',
          code: 'invalidChars',
          message: 'この文字は今は使えないみたい',
        ),
      );
    }

    return ValidationResult(issues);
  }
}
