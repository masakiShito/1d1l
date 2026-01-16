import 'package:flutter/material.dart';

import '../../core/model/daily_log.dart';
import '../../core/utils/date_key.dart';

class WritePage extends StatefulWidget {
  const WritePage({
    super.key,
    required this.dateKey,
    required this.log,
    required this.onSave,
  });

  final String dateKey;
  final DailyLog? log;
  final Future<void> Function(String dateKey, String text) onSave;

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _applyLog(widget.log);
  }

  @override
  void didUpdateWidget(covariant WritePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dateKey != widget.dateKey || oldWidget.log != widget.log) {
      _applyLog(widget.log);
    }
  }

  void _applyLog(DailyLog? log) {
    _textController.text = log?.text ?? '';
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date = dateFromKey(widget.dateKey);
    final dateLabel = formatDisplayDate(date);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '1D1L',
            style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '1日1ログ。短くてもいい。',
            style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            dateLabel,
            style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.08),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: colorScheme.primary, width: 3),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  minLines: 4,
                  decoration: const InputDecoration(
                    hintText: '今日のログを残す…',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await widget.onSave(widget.dateKey, _textController.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('保存しました')),
                  );
                }
              },
              child: const Text('保存する'),
            ),
          ),
        ],
      ),
    );
  }
}
