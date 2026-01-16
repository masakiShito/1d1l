import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../model/daily_log.dart';

class DailyLogEntry {
  const DailyLogEntry({required this.dateKey, required this.log});

  final String dateKey;
  final DailyLog log;
}

class LogRepository {
  // JSON persistence for daily logs.
  LogRepository({this.fileName = 'logs.json'});

  final String fileName;

  Future<File> _resolveFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File(p.join(directory.path, fileName));
  }

  Future<Map<String, DailyLog>> loadAll() async {
    final file = await _resolveFile();
    if (!await file.exists()) {
      return {};
    }
    final contents = await file.readAsString();
    if (contents.trim().isEmpty) {
      return {};
    }
    final decoded = jsonDecode(contents) as Map<String, dynamic>;
    var needsMigration = false;
    final logs = decoded.map(
      (key, value) {
        final data = value as Map<String, dynamic>;
        final hasLegacy = data.containsKey('line1') ||
            data.containsKey('line2') ||
            data.containsKey('line3');
        if (hasLegacy || !data.containsKey('text')) {
          needsMigration = true;
        }
        return MapEntry(key, DailyLog.fromJson(data));
      },
    );
    if (needsMigration) {
      await _persistAll(logs);
    }
    return logs;
  }

  Future<DailyLog?> get(String dateKey) async {
    final logs = await loadAll();
    return logs[dateKey];
  }

  Future<void> upsert(String dateKey, DailyLog log) async {
    final logs = await loadAll();
    logs[dateKey] = log;
    await _persistAll(logs);
  }

  Future<List<DailyLogEntry>> listSortedDesc() async {
    final logs = await loadAll();
    final entries = logs.entries
        .map((entry) => DailyLogEntry(dateKey: entry.key, log: entry.value))
        .toList();
    entries.sort((a, b) => b.dateKey.compareTo(a.dateKey));
    return entries;
  }

  Future<void> _persistAll(Map<String, DailyLog> logs) async {
    final file = await _resolveFile();
    await file.writeAsString(jsonEncode(
      logs.map((key, value) => MapEntry(key, value.toJson())),
    ));
  }
}
