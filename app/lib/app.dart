import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/model/daily_log.dart';
import 'core/model/diary_template.dart';
import 'core/model/question.dart';
import 'core/storage/log_repository.dart';
import 'core/storage/question_repository.dart';
import 'core/storage/template_repository.dart';
import 'core/utils/date_key.dart';
import 'features/calendar/calendar_page.dart';
import 'features/list/list_page.dart';
import 'features/settings/settings_page.dart';
import 'features/write/write_page.dart';

class ThreeLineDiaryApp extends StatelessWidget {
  // Root widget for the diary app.
  const ThreeLineDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3行日記',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        useMaterial3: true,
      ),
      locale: const Locale('ja', 'JP'),
      supportedLocales: const [Locale('ja', 'JP')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  // Keeps tab state and shared logs.
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final LogRepository _repository = LogRepository();
  final QuestionRepository _questionRepository = QuestionRepository();
  final TemplateRepository _templateRepository = TemplateRepository();
  Map<String, DailyLog> _logs = {};
  List<Question> _questions = [];
  List<DiaryTemplate> _templates = [];
  DiaryTemplate? _selectedTemplate;
  int _currentIndex = 0;
  String? _selectedDateKey;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final logs = await _repository.loadAll();
    final questions = await _questionRepository.loadAll();
    final templates = await _templateRepository.loadAll();
    final todayKey = dateKeyFromDate(DateTime.now());
    final selectedKey = _selectedDateKey ?? todayKey;
    final selectedTemplate = _templateForLog(templates, logs[selectedKey]);
    setState(() {
      _logs = logs;
      _questions = questions;
      _templates = templates;
      _selectedTemplate = selectedTemplate;
      _selectedDateKey ??= selectedKey;
      _isLoading = false;
    });
  }

  DiaryTemplate _templateForLog(
    List<DiaryTemplate> templates,
    DailyLog? log,
  ) {
    final templateId = log?.templateId;
    if (templateId != null) {
      final matched = templates.where((template) => template.id == templateId);
      if (matched.isNotEmpty) {
        return matched.first;
      }
    }
    return templates.firstWhere(
      (template) => template.isDefault,
      orElse: () => templates.first,
    );
  }

  Future<void> _saveLog(
    String dateKey,
    String line1,
    String line2,
    String line3,
    String templateId,
  ) async {
    final log = DailyLog(
      line1: line1,
      line2: line2,
      line3: line3,
      updatedAt: DateTime.now(),
      templateId: templateId,
    );
    await _repository.upsert(dateKey, log);
    setState(() {
      _logs = {..._logs, dateKey: log};
      _selectedDateKey = dateKey;
    });
  }

  void _handleCalendarSelection(DateTime selectedDate) {
    final key = dateKeyFromDate(selectedDate);
    setState(() {
      _selectedDateKey = key;
      _currentIndex = 0;
      _selectedTemplate = _templateForLog(_templates, _logs[key]);
    });
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          initialQuestions: _questions,
          initialTemplates: _templates,
          questionRepository: _questionRepository,
          templateRepository: _templateRepository,
          onSaved: (questions, templates) {
            final selectedKey =
                _selectedDateKey ?? dateKeyFromDate(DateTime.now());
            setState(() {
              _questions = questions;
              _templates = templates;
              _selectedTemplate =
                  _templateForLog(templates, _logs[selectedKey]);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayKey = dateKeyFromDate(DateTime.now());
    final selectedKey = _selectedDateKey ?? todayKey;
    final selectedLog = _logs[selectedKey];
    final selectedTemplate = _selectedTemplate ??
        (_templates.isNotEmpty
            ? _templateForLog(_templates, selectedLog)
            : null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('3行日記'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _openSettings,
            icon: const Icon(Icons.settings_outlined),
            tooltip: '設定',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _currentIndex,
              children: [
                WritePage(
                  dateKey: selectedKey,
                  log: selectedLog,
                  questions: _questions,
                  templates: _templates,
                  selectedTemplate: selectedTemplate,
                  onTemplateChanged: (template) {
                    setState(() => _selectedTemplate = template);
                  },
                  onSave: _saveLog,
                ),
                CalendarPage(
                  logs: _logs,
                  selectedDateKey: selectedKey,
                  onSelectDate: _handleCalendarSelection,
                ),
                ListPage(
                  logs: _logs,
                  selectedDateKey: _selectedDateKey,
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: '書く',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'カレンダー',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: '一覧',
          ),
        ],
      ),
    );
  }
}
