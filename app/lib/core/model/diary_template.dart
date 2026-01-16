class DiaryTemplate {
  const DiaryTemplate({
    required this.id,
    required this.name,
    required this.slot1QuestionId,
    required this.slot2QuestionId,
    required this.slot3QuestionId,
    required this.sortOrder,
    required this.isDefault,
  });

  final String id;
  final String name;
  final String slot1QuestionId;
  final String slot2QuestionId;
  final String slot3QuestionId;
  final int sortOrder;
  final bool isDefault;

  factory DiaryTemplate.fromJson(Map<String, dynamic> json) {
    return DiaryTemplate(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      slot1QuestionId: (json['slot1QuestionId'] as String?) ?? '',
      slot2QuestionId: (json['slot2QuestionId'] as String?) ?? '',
      slot3QuestionId: (json['slot3QuestionId'] as String?) ?? '',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isDefault: (json['isDefault'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slot1QuestionId': slot1QuestionId,
      'slot2QuestionId': slot2QuestionId,
      'slot3QuestionId': slot3QuestionId,
      'sortOrder': sortOrder,
      'isDefault': isDefault,
    };
  }

  DiaryTemplate copyWith({
    String? id,
    String? name,
    String? slot1QuestionId,
    String? slot2QuestionId,
    String? slot3QuestionId,
    int? sortOrder,
    bool? isDefault,
  }) {
    return DiaryTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      slot1QuestionId: slot1QuestionId ?? this.slot1QuestionId,
      slot2QuestionId: slot2QuestionId ?? this.slot2QuestionId,
      slot3QuestionId: slot3QuestionId ?? this.slot3QuestionId,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
