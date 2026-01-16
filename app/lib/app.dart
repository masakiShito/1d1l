import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/model/daily_log.dart';
import 'core/storage/log_repository.dart';
import 'core/utils/date_key.dart';
import 'features/calendar/calendar_page.dart';
import 'features/list/list_page.dart';
import 'features/write/write_page.dart';

class OneDayOneLogApp extends StatelessWidget {
  const OneDayOneLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '1D1L',
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
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final logs = await _repository.loadAll();
    final todayKey = dateKeyFromDate(DateTime.now());
    final selectedKey = _selectedDateKey ?? todayKey;
    setState(() {
      _logs = logs;
      _selectedDateKey ??= selectedKey;
      _isLoading = false;
    });
  }

  Future<void> _saveLog(String dateKey, String text) async {
    final log = DailyLog(
      text: text,
      updatedAt: DateTime.now(),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final todayKey = dateKeyFromDate(DateTime.now());
    final selectedKey = _selectedDateKey ?? todayKey;
    final selectedLog = _logs[selectedKey];

    return Scaffold(
      appBar: AppBar(
        title: const Text('1D1L'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _currentIndex,
              children: [
                WritePage(
                  dateKey: selectedKey,
                  log: selectedLog,
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
