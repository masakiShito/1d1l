import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/model/daily_log.dart';
import 'core/storage/log_repository.dart';
import 'core/utils/date_key.dart';
import 'features/calendar/calendar_page.dart';
import 'features/list/list_page.dart';
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
  Map<String, DailyLog> _logs = {};
  int _currentIndex = 0;
  String? _selectedDateKey;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await _repository.loadAll();
    setState(() {
      _logs = logs;
      _isLoading = false;
    });
  }

  Future<void> _saveTodayLog(
    String line1,
    String line2,
    String line3,
  ) async {
    final todayKey = dateKeyFromDate(DateTime.now());
    final log = DailyLog(
      line1: line1,
      line2: line2,
      line3: line3,
      updatedAt: DateTime.now(),
    );
    await _repository.upsert(todayKey, log);
    setState(() {
      _logs = {..._logs, todayKey: log};
      _selectedDateKey ??= todayKey;
    });
  }

  void _openLogDetail(String dateKey) {
    setState(() {
      _currentIndex = 2;
      _selectedDateKey = dateKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    final todayKey = dateKeyFromDate(DateTime.now());
    final todayLog = _logs[todayKey];

    return Scaffold(
      appBar: AppBar(
        title: const Text('3行日記'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _currentIndex,
              children: [
                WritePage(
                  todayLog: todayLog,
                  onSave: _saveTodayLog,
                ),
                CalendarPage(
                  logs: _logs,
                  onSelectLog: _openLogDetail,
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
