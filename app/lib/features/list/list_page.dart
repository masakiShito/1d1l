import 'package:flutter/material.dart';

import '../../core/model/daily_log.dart';
import '../../core/utils/date_key.dart';

class ListPage extends StatefulWidget {
  // List and detail view for saved logs.
  const ListPage({super.key, required this.logs, required this.selectedDateKey});

  final Map<String, DailyLog> logs;
  final String? selectedDateKey;

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  String? _selectedKey;

  @override
  void initState() {
    super.initState();
    _selectedKey = widget.selectedDateKey ?? _latestKey();
  }

  @override
  void didUpdateWidget(covariant ListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDateKey != null &&
        widget.selectedDateKey != _selectedKey) {
      setState(() => _selectedKey = widget.selectedDateKey);
    } else if (_selectedKey != null &&
        !widget.logs.containsKey(_selectedKey)) {
      setState(() => _selectedKey = _latestKey());
    }
  }

  String? _latestKey() {
    final keys = widget.logs.keys.toList()..sort((a, b) => b.compareTo(a));
    return keys.isNotEmpty ? keys.first : null;
  }

  List<String> _sortedKeys() {
    final keys = widget.logs.keys.toList()..sort((a, b) => b.compareTo(a));
    return keys;
  }

  @override
  Widget build(BuildContext context) {
    final keys = _sortedKeys();
    final selectedLog = _selectedKey == null ? null : widget.logs[_selectedKey!];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: keys.isEmpty
                ? const Center(child: Text('まだ日記がありません'))
                : ListView.separated(
                    itemCount: keys.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final key = keys[index];
                      final date = dateFromKey(key);
                      final isSelected = key == _selectedKey;
                      return Card(
                        color: isSelected
                            ? Colors.blueGrey.shade50
                            : Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.blueGrey.shade200
                                : Colors.transparent,
                          ),
                        ),
                        child: ListTile(
                          title: Text(formatDisplayDate(date)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => setState(() => _selectedKey = key),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          if (selectedLog != null)
            _DetailSection(dateKey: _selectedKey!, log: selectedLog),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.dateKey, required this.log});

  final String dateKey;
  final DailyLog log;

  @override
  Widget build(BuildContext context) {
    final date = dateFromKey(dateKey);

    return Card(
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
              formatDisplayDate(date),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _LineCard(label: '1行目', text: log.line1),
            _LineCard(label: '2行目', text: log.line2),
            _LineCard(label: '3行目', text: log.line3),
          ],
        ),
      ),
    );
  }
}

class _LineCard extends StatelessWidget {
  const _LineCard({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final displayText = text.isEmpty ? '(未記入)' : text;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.blueGrey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.blueGrey,
                  ),
            ),
            const SizedBox(height: 4),
            Text(displayText),
          ],
        ),
      ),
    );
  }
}
