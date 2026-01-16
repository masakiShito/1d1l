class DailyLog {
  const DailyLog({
    required this.line1,
    required this.line2,
    required this.line3,
    required this.updatedAt,
    this.templateId,
    this.slot1QuestionId,
    this.slot2QuestionId,
    this.slot3QuestionId,
  });

  final String line1;
  final String line2;
  final String line3;
  final DateTime updatedAt;
  final String? templateId;
  final String? slot1QuestionId;
  final String? slot2QuestionId;
  final String? slot3QuestionId;

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    return DailyLog(
      line1: (json['line1'] as String?) ?? '',
      line2: (json['line2'] as String?) ?? '',
      line3: (json['line3'] as String?) ?? '',
      updatedAt: DateTime.parse(
        (json['updatedAt'] as String?) ?? DateTime.now().toIso8601String(),
      ),
      templateId: json['templateId'] as String?,
      slot1QuestionId: json['slot1QuestionId'] as String?,
      slot2QuestionId: json['slot2QuestionId'] as String?,
      slot3QuestionId: json['slot3QuestionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'line1': line1,
      'line2': line2,
      'line3': line3,
      'updatedAt': updatedAt.toIso8601String(),
    };
    if (templateId != null) {
      data['templateId'] = templateId;
    }
    if (slot1QuestionId != null) {
      data['slot1QuestionId'] = slot1QuestionId;
    }
    if (slot2QuestionId != null) {
      data['slot2QuestionId'] = slot2QuestionId;
    }
    if (slot3QuestionId != null) {
      data['slot3QuestionId'] = slot3QuestionId;
    }
    return data;
  }

  DailyLog copyWith({
    String? line1,
    String? line2,
    String? line3,
    DateTime? updatedAt,
    String? templateId,
    String? slot1QuestionId,
    String? slot2QuestionId,
    String? slot3QuestionId,
  }) {
    return DailyLog(
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      line3: line3 ?? this.line3,
      updatedAt: updatedAt ?? this.updatedAt,
      templateId: templateId ?? this.templateId,
      slot1QuestionId: slot1QuestionId ?? this.slot1QuestionId,
      slot2QuestionId: slot2QuestionId ?? this.slot2QuestionId,
      slot3QuestionId: slot3QuestionId ?? this.slot3QuestionId,
    );
  }
}
