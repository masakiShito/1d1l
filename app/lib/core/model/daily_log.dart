class DailyLog {
  const DailyLog({
    required this.line1,
    required this.line2,
    required this.line3,
    required this.updatedAt,
  });

  final String line1;
  final String line2;
  final String line3;
  final DateTime updatedAt;

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    return DailyLog(
      line1: (json['line1'] as String?) ?? '',
      line2: (json['line2'] as String?) ?? '',
      line3: (json['line3'] as String?) ?? '',
      updatedAt: DateTime.parse(
        (json['updatedAt'] as String?) ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'line1': line1,
      'line2': line2,
      'line3': line3,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  DailyLog copyWith({
    String? line1,
    String? line2,
    String? line3,
    DateTime? updatedAt,
  }) {
    return DailyLog(
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      line3: line3 ?? this.line3,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
