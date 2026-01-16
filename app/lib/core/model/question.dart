class Question {
  const Question({
    required this.id,
    required this.text,
  });

  final String id;
  final String text;

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: (json['id'] as String?) ?? '',
      text: (json['text'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
    };
  }

  Question copyWith({
    String? id,
    String? text,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
    );
  }
}
