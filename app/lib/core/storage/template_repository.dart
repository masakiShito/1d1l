import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../model/diary_template.dart';

class TemplateRepository {
  TemplateRepository({this.fileName = 'templates.json'});

  final String fileName;

  static const List<DiaryTemplate> defaultTemplates = [
    DiaryTemplate(
      id: 'default',
      name: 'ベーシック',
      slot1QuestionId: 'A',
      slot2QuestionId: 'C',
      slot3QuestionId: 'D',
      sortOrder: 0,
      isDefault: true,
    ),
  ];

  Future<File> _resolveFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File(p.join(directory.path, fileName));
  }

  Future<List<DiaryTemplate>> loadAll() async {
    final file = await _resolveFile();
    if (!await file.exists()) {
      await saveAll(defaultTemplates);
      return defaultTemplates;
    }
    final contents = await file.readAsString();
    if (contents.trim().isEmpty) {
      await saveAll(defaultTemplates);
      return defaultTemplates;
    }
    final decoded = jsonDecode(contents) as List<dynamic>;
    final templates = decoded
        .map((entry) =>
            DiaryTemplate.fromJson(entry as Map<String, dynamic>))
        .toList();
    if (templates.isEmpty) {
      await saveAll(defaultTemplates);
      return defaultTemplates;
    }
    return templates;
  }

  Future<void> saveAll(List<DiaryTemplate> templates) async {
    final file = await _resolveFile();
    await file.writeAsString(
      jsonEncode(templates.map((template) => template.toJson()).toList()),
    );
  }
}
