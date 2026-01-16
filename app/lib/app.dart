import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/model/daily_log.dart';
import 'core/storage/log_repository.dart';
import 'core/storage/prompt_settings.dart';
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
  PromptSettingsStorage? _promptStorage;
  Map<String, DailyLog> _logs = {};
  PromptSettings _promptSettings = PromptSettings.defaults;
  int _currentIndex = 0;
  String? _selectedDateKey;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final storage = await PromptSettingsStorage.create();
    final logs = await _repository.loadAll();
    final prompts = await storage.load();
    setState(() {
      _promptStorage = storage;
      _logs = logs;
      _promptSettings = prompts;
      _selectedDateKey ??= dateKeyFromDate(DateTime.now());
      _isLoading = false;
    });
  }

  Future<void> _saveLog(
    String dateKey,
    String line1,
    String line2,
    String line3,
  ) async {
    final log = DailyLog(
      line1: line1,
      line2: line2,
      line3: line3,
      updatedAt: DateTime.now(),
    );
    await _repository.upsert(dateKey, log);
    setState(() {
      _logs = {..._logs, dateKey: log};
      _selectedDateKey = dateKey;
    });
  }

  void _handleCalendarSelection(DateTime selectedDate) {
    setState(() {
      _selectedDateKey = dateKeyFromDate(selectedDate);
      _currentIndex = 0;
    });
  }

  void _openSettings() {
    final storage = _promptStorage;
    if (storage == null) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          initialSettings: _promptSettings,
          storage: storage,
          onSaved: (settings) => setState(() => _promptSettings = settings),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayKey = dateKeyFromDate(DateTime.now());
    final selectedKey = _selectedDateKey ?? todayKey;
    final selectedLog = _logs[selectedKey];

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
                  promptSettings: _promptSettings,
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
