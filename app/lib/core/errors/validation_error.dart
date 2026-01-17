class ValidationIssue {
  const ValidationIssue({
    required this.field,
    required this.code,
    required this.message,
  });

  final String field;
  final String code;
  final String message;
}

class ValidationResult {
  const ValidationResult(this.issues);

  final List<ValidationIssue> issues;

  bool get isValid => issues.isEmpty;

  String? firstMessageFor(String field) {
    for (final issue in issues) {
      if (issue.field == field) {
        return issue.message;
      }
    }
    return null;
  }
}
