import 'package:flutter/material.dart';

import '../../core/model/daily_log.dart';
import '../../core/model/diary_template.dart';
import '../../core/model/question.dart';
import '../../core/utils/date_key.dart';

class WritePage extends StatefulWidget {
  // Editing view for selected day's log.
  const WritePage({
    super.key,
    required this.dateKey,
    required this.log,
    required this.questions,
    required this.templates,
    required this.selectedTemplate,
    required this.onTemplateChanged,
    required this.onSave,
  });

  final String dateKey;
  final DailyLog? log;
  final List<Question> questions;
  final List<DiaryTemplate> templates;
  final DiaryTemplate? selectedTemplate;
  final ValueChanged<DiaryTemplate> onTemplateChanged;
  final Future<void> Function(
    String dateKey,
    String line1,
    String line2,
    String line3,
    String templateId,
  ) onSave;

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
    final date = dateFromKey(widget.dateKey);
    final dateLabel = formatDisplayDate(date);
    final template = widget.selectedTemplate;
    final questionsById = {
      for (final question in widget.questions) question.id: question
    };
    final prompts = template == null
        ? const <String>[
            '質問を選択してください',
            '質問を選択してください',
            '質問を選択してください',
          ]
        : <String>[
            questionsById[template.slot1QuestionId]?.text ??
                '質問を選択してください',
            questionsById[template.slot2QuestionId]?.text ??
                '質問を選択してください',
            questionsById[template.slot3QuestionId]?.text ??
                '質問を選択してください',
          ];
    final templateName = template?.name ?? 'テンプレート未選択';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '日記を書く',
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
          const SizedBox(height: 12),
          _TemplateSelectorCard(
            templateName: templateName,
            onTap: widget.templates.isEmpty
                ? null
                : () => _showTemplateSheet(context, template),
          ),
          const SizedBox(height: 20),
          _InputCard(
            label: '1行目',
            hintText: prompts[0],
            controller: _line1Controller,
          ),
          _InputCard(
            label: '2行目',
            hintText: prompts[1],
            controller: _line2Controller,
          ),
          _InputCard(
            label: '3行目',
            hintText: prompts[2],
            controller: _line3Controller,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (template == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('テンプレートを選択してください')),
                  );
                  return;
                }
                await widget.onSave(
                  widget.dateKey,
                  _line1Controller.text,
                  _line2Controller.text,
                  _line3Controller.text,
                  template.id,
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

  Future<void> _showTemplateSheet(
    BuildContext context,
    DiaryTemplate? currentTemplate,
  ) async {
    final templates = [...widget.templates]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final selected = await showModalBottomSheet<DiaryTemplate>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'テンプレートを選択',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: templates.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final template = templates[index];
                      final isSelected = template.id == currentTemplate?.id;
                      return Card(
                        color: isSelected
                            ? Colors.blueGrey.shade50
                            : Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.blueGrey.shade300
                                : Colors.transparent,
                          ),
                        ),
                        child: ListTile(
                          title: Text(template.name),
                          subtitle:
                              template.isDefault ? const Text('デフォルト') : null,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).pop(template),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null) {
      widget.onTemplateChanged(selected);
    }
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

class _TemplateSelectorCard extends StatelessWidget {
  const _TemplateSelectorCard({
    required this.templateName,
    required this.onTap,
  });

  final String templateName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: const Text('テンプレート'),
        subtitle: Text(templateName),
        trailing: const Icon(Icons.swap_horiz),
        onTap: onTap,
      ),
    );
  }
}
