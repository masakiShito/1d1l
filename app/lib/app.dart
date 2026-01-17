import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/errors/app_error.dart';
import 'core/errors/app_error_mapper.dart';
import 'core/errors/app_error_presenter.dart';
import 'core/errors/app_error_reporter.dart';
import 'core/errors/validation_error.dart';
import 'core/model/daily_log.dart';
import 'core/storage/log_repository.dart';
import 'core/theme/app_colors.dart';
import 'core/utils/date_key.dart';
import 'core/utils/input_sanitizer.dart';
import 'core/validators/log_validator.dart';
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
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.primary,
          secondary: AppColors.primary,
          onSecondary: AppColors.onPrimary,
          secondaryContainer: AppColors.primaryContainer,
          onSecondaryContainer: AppColors.primary,
          tertiary: AppColors.primary,
          onTertiary: AppColors.onPrimary,
          tertiaryContainer: AppColors.primaryContainer,
          onTertiaryContainer: AppColors.primary,
          error: Color(0xFFDC2626),
          onError: Color(0xFFFFFFFF),
          errorContainer: Color(0xFFFEE2E2),
          onErrorContainer: Color(0xFF7F1D1D),
          background: AppColors.background,
          onBackground: AppColors.textPrimary,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          surfaceVariant: AppColors.background,
          onSurfaceVariant: AppColors.textSecondary,
          outline: AppColors.divider,
          outlineVariant: AppColors.divider,
          shadow: Color(0x1F000000),
          scrim: Color(0x33000000),
          inverseSurface: AppColors.textPrimary,
          onInverseSurface: AppColors.surface,
          inversePrimary: AppColors.primaryContainer,
          surfaceTint: AppColors.primary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: AppColors.textPrimary,
              displayColor: AppColors.textPrimary,
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.primary),
          actionsIconTheme: IconThemeData(color: AppColors.primary),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: AppColors.textHint),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.divider),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.primary,
          selectionColor: AppColors.primaryContainer,
          selectionHandleColor: AppColors.primary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            disabledBackgroundColor: AppColors.primaryContainer,
            disabledForegroundColor: AppColors.textSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedIconTheme: IconThemeData(color: AppColors.primary),
          unselectedIconTheme: IconThemeData(color: AppColors.textSecondary),
        ),
        dividerColor: AppColors.divider,
        cardTheme: CardThemeData(
          color: AppColors.surface,
          surfaceTintColor: Colors.transparent,
        ),
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
  final AppErrorMapper _errorMapper = const AppErrorMapper();
  final AppErrorReporter _errorReporter = const AppErrorReporter();
  final AppErrorPresenter _errorPresenter = const AppErrorPresenter();
  final LogValidator _logValidator = LogValidator();
  Map<String, DailyLog> _logs = {};
  int _currentIndex = 0;
  String? _selectedDateKey;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final logs = await _repository.loadAll();
      final todayKey = dateKeyFromDate(DateTime.now());
      final selectedKey = _selectedDateKey ?? todayKey;
      setState(() {
        _logs = logs;
        _selectedDateKey ??= selectedKey;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      final mapped = _errorMapper.map(error, stackTrace);
      _errorReporter.report(mapped);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorPresenter.messageFor(mapped))),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveLog(String dateKey, String text) async {
    if (_isSaving) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      final normalized = InputSanitizer.normalizeText(text);
      final validation = _logValidator.validate(normalized);
      if (!validation.isValid) {
        _showValidationErrors(validation);
        return;
      }
      final log = DailyLog(
        text: normalized,
        updatedAt: DateTime.now(),
      );
      await _repository.upsert(dateKey, log);
      if (!mounted) {
        return;
      }
      setState(() {
        _logs = {..._logs, dateKey: log};
        _selectedDateKey = dateKey;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存しました')),
      );
    } catch (error, stackTrace) {
      final mapped = _errorMapper.map(error, stackTrace);
      _errorReporter.report(mapped);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorPresenter.messageFor(mapped))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showValidationErrors(ValidationResult result) {
    if (!mounted || result.isValid) {
      return;
    }
    _errorReporter.report(
      AppError(
        type: AppErrorType.validation,
        userMessage: '入力内容を確認してください。',
        debugMessage: result.issues.map((issue) => issue.message).join(', '),
      ),
    );
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
                  onValidationFailed: _showValidationErrors,
                  isSaving: _isSaving,
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
