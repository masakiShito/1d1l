import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/model/daily_log.dart';
import '../../core/utils/date_key.dart';

class CalendarPage extends StatefulWidget {
  // Calendar view with log markers.
  const CalendarPage({
    super.key,
    required this.logs,
    required this.selectedDateKey,
    required this.onSelectDate,
  });

  final Map<String, DailyLog> logs;
  final String selectedDateKey;
  final ValueChanged<DateTime> onSelectDate;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = dateFromKey(widget.selectedDateKey);
    _focusedDay = _selectedDay ?? DateTime.now();
  }

  @override
  void didUpdateWidget(covariant CalendarPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDateKey != widget.selectedDateKey) {
      setState(() {
        _selectedDay = dateFromKey(widget.selectedDateKey);
        _focusedDay = _selectedDay ?? DateTime.now();
      });
    }
  }

  bool _hasLog(DateTime day) {
    final key = dateKeyFromDate(day);
    return widget.logs.containsKey(key);
  }

  @override
  Widget build(BuildContext context) {
    final selectedLog = _selectedDay == null
        ? null
        : widget.logs[dateKeyFromDate(_selectedDay!)];
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TableCalendar(
              locale: 'ja_JP',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                widget.onSelectDate(selectedDay);
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: (day) => _hasLog(day) ? [1] : [],
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: colorScheme.primary,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: colorScheme.primary,
                ),
                titleTextStyle: Theme.of(context).textTheme.titleMedium!,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                selectedDecoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  border: Border.all(
                    color: colorScheme.primary,
                    width: 1.5,
                  ),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                markerDecoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: TextStyle(color: colorScheme.onSurface),
                weekendTextStyle:
                    TextStyle(color: colorScheme.onSurfaceVariant),
                outsideTextStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (selectedLog != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatDisplayDate(_selectedDay!),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _PreviewText(text: selectedLog.text),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PreviewText extends StatelessWidget {
  const _PreviewText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final displayText = text.isEmpty ? '(未記入)' : text;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        displayText,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
