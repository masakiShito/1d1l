import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/model/daily_log.dart';
import '../../core/utils/date_key.dart';

class CalendarPage extends StatefulWidget {
  // Calendar view with log markers.
  const CalendarPage({super.key, required this.logs, required this.onSelectLog});

  final Map<String, DailyLog> logs;
  final ValueChanged<String> onSelectLog;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
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
              final key = dateKeyFromDate(selectedDay);
              if (widget.logs.containsKey(key)) {
                widget.onSelectLog(key);
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) => _hasLog(day) ? [1] : [],
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: const Icon(Icons.chevron_left),
              rightChevronIcon: const Icon(Icons.chevron_right),
              titleTextStyle: Theme.of(context).textTheme.titleMedium!,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueGrey.shade200,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blueGrey.shade600,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.blueGrey,
                shape: BoxShape.circle,
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
                    _PreviewLine(text: selectedLog.line1),
                    _PreviewLine(text: selectedLog.line2),
                    _PreviewLine(text: selectedLog.line3),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PreviewLine extends StatelessWidget {
  const _PreviewLine({required this.text});

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
