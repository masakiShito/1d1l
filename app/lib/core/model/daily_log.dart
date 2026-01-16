class DailyLog {
  const DailyLog({
    required this.text,
    required this.updatedAt,
  });

  final String text;
  final DateTime updatedAt;

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    final text = (json['text'] as String?) ??
        _legacyText(
          json['line1'] as String?,
          json['line2'] as String?,
          json['line3'] as String?,
        );
    return DailyLog(
      text: text ?? '',
      updatedAt: DateTime.parse(
        (json['updatedAt'] as String?) ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  DailyLog copyWith({
    String? text,
    DateTime? updatedAt,
  }) {
    return DailyLog(
      text: text ?? this.text,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String? _legacyText(String? line1, String? line2, String? line3) {
    if (line1 == null && line2 == null && line3 == null) {
      return null;
    }
    return [
      line1 ?? '',
      line2 ?? '',
      line3 ?? '',
    ].join('\n');
  }
}
