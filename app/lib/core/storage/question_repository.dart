import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../model/question.dart';

class QuestionRepository {
  QuestionRepository({this.fileName = 'questions.json'});

  final String fileName;

  static const List<Question> defaultQuestions = [
    Question(id: 'A', text: '今日頑張ったことは？'),
    Question(id: 'B', text: '今日嬉しかったことは？'),
    Question(id: 'C', text: '今日学んだことは？'),
    Question(id: 'D', text: '明日やりたいことは？'),
    Question(id: 'E', text: '今日感謝したいことは？'),
  ];

  Future<File> _resolveFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File(p.join(directory.path, fileName));
  }

  Future<List<Question>> loadAll() async {
    final file = await _resolveFile();
    if (!await file.exists()) {
      await saveAll(defaultQuestions);
      return defaultQuestions;
    }
    final contents = await file.readAsString();
    if (contents.trim().isEmpty) {
      await saveAll(defaultQuestions);
      return defaultQuestions;
    }
    final decoded = jsonDecode(contents) as List<dynamic>;
    return decoded
        .map((entry) => Question.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<Question> questions) async {
    final file = await _resolveFile();
    await file.writeAsString(
      jsonEncode(questions.map((question) => question.toJson()).toList()),
    );
  }
}
