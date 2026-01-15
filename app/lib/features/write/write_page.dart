import 'package:flutter/material.dart';

import '../../core/model/daily_log.dart';
import '../../core/utils/date_key.dart';

class WritePage extends StatefulWidget {
  // Editing view for today's log.
  const WritePage({super.key, required this.todayLog, required this.onSave});

  final DailyLog? todayLog;
  final Future<void> Function(String line1, String line2, String line3) onSave;

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final TextEditingController _line1Controller = TextEditingController();
  final TextEditingController _line2Controller = TextEditingController();
  final TextEditingController _line3Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _applyLog(widget.todayLog);
  }

  @override
  void didUpdateWidget(covariant WritePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.todayLog != widget.todayLog) {
      _applyLog(widget.todayLog);
    }
  }

  void _applyLog(DailyLog? log) {
    _line1Controller.text = log?.line1 ?? '';
    _line2Controller.text = log?.line2 ?? '';
    _line3Controller.text = log?.line3 ?? '';
  }

  @override
  void dispose() {
    _line1Controller.dispose();
    _line2Controller.dispose();
    _line3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dateLabel = formatDisplayDate(today);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日の日記',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            dateLabel,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.blueGrey.shade600,
                ),
          ),
          const SizedBox(height: 20),
          _InputCard(
            label: '1行目',
            hintText: '今日あった良いことは？',
            controller: _line1Controller,
          ),
          _InputCard(
            label: '2行目',
            hintText: '今日学んだことは？',
            controller: _line2Controller,
          ),
          _InputCard(
            label: '3行目',
            hintText: '明日やりたいことは？',
            controller: _line3Controller,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await widget.onSave(
                  _line1Controller.text,
                  _line2Controller.text,
                  _line3Controller.text,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('保存しました')),
                  );
                }
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('✓ 保存する'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.label,
    required this.hintText,
    required this.controller,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextField(
            controller: controller,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: label,
              hintText: hintText,
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
