import 'package:flutter/material.dart';

import '../../core/model/diary_template.dart';
import '../../core/model/question.dart';
import '../../core/storage/question_repository.dart';
import '../../core/storage/template_repository.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.initialQuestions,
    required this.initialTemplates,
    required this.questionRepository,
    required this.templateRepository,
    required this.onSaved,
  });

  final List<Question> initialQuestions;
  final List<DiaryTemplate> initialTemplates;
  final QuestionRepository questionRepository;
  final TemplateRepository templateRepository;
  final void Function(List<Question>, List<DiaryTemplate>) onSaved;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late List<Question> _questions;
  late List<DiaryTemplate> _templates;

  @override
  void initState() {
    super.initState();
    _questions = [...widget.initialQuestions];
    _templates = [...widget.initialTemplates];
  }

  List<DiaryTemplate> _sortedTemplates() {
    final templates = [..._templates]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return templates;
  }

  Future<void> _persist() async {
    await widget.questionRepository.saveAll(_questions);
    await widget.templateRepository.saveAll(_templates);
    widget.onSaved(_questions, _templates);
  }

  Future<void> _addQuestion() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final id = _nextQuestionId();
    final added = await showDialog<Question>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('質問を追加'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '質問文',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '入力してください';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(
                    Question(id: id, text: controller.text.trim()),
                  );
                }
              },
              child: const Text('追加'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (added != null) {
      setState(() => _questions = [..._questions, added]);
      await _persist();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('質問「${added.id}」を追加しました')),
        );
      }
    }
  }

  String _nextQuestionId() {
    final existing = _questions.map((question) => question.id).toSet();
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (final codeUnit in letters.codeUnits) {
      final candidate = String.fromCharCode(codeUnit);
      if (!existing.contains(candidate)) {
        return candidate;
      }
    }
    var index = _questions.length + 1;
    while (existing.contains('Q$index')) {
      index += 1;
    }
    return 'Q$index';
  }

  Future<void> _editTemplate(DiaryTemplate? template) async {
    final result = await Navigator.of(context).push<DiaryTemplate>(
      MaterialPageRoute(
        builder: (context) => TemplateEditorPage(
          template: template,
          questions: _questions,
          nextId: template?.id ?? _nextTemplateId(),
          nextSortOrder: template?.sortOrder ?? _nextSortOrder(),
        ),
      ),
    );
    if (result == null) {
      return;
    }
    setState(() {
      final updated = [..._templates];
      final index = updated.indexWhere((item) => item.id == result.id);
      if (index >= 0) {
        updated[index] = result;
      } else {
        updated.add(result);
      }
      _templates = _applyDefault(updated, result.id);
    });
    await _persist();
  }

  List<DiaryTemplate> _applyDefault(
    List<DiaryTemplate> templates,
    String updatedId,
  ) {
    final updated = [...templates];
    final updatedTemplate =
        updated.firstWhere((template) => template.id == updatedId);
    if (updatedTemplate.isDefault) {
      return updated
          .map(
            (template) => template.id == updatedId
                ? template
                : template.copyWith(isDefault: false),
          )
          .toList();
    }
    if (!updated.any((template) => template.isDefault)) {
      return updated
          .map(
            (template) => template.id == updatedId
                ? template.copyWith(isDefault: true)
                : template,
          )
          .toList();
    }
    return updated;
  }

  String _nextTemplateId() {
    final existing = _templates.map((template) => template.id).toSet();
    var index = _templates.length + 1;
    while (existing.contains('T$index')) {
      index += 1;
    }
    return 'T$index';
  }

  int _nextSortOrder() {
    if (_templates.isEmpty) {
      return 0;
    }
    return _templates.map((template) => template.sortOrder).reduce(
          (value, element) => value > element ? value : element,
        ) +
        1;
  }

  String _questionLabel(String id) {
    final match = _questions.where((question) => question.id == id);
    if (match.isEmpty) {
      return '未選択';
    }
    return match.first.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '質問バンク',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          ..._questions.map(
            (question) => Card(
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                title: Text(question.text),
                subtitle: Text('ID: ${question.id}'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add),
              label: const Text('質問を追加'),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'テンプレート',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          ..._sortedTemplates().map(
            (template) => Card(
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                title: Text(template.name),
                subtitle: Text(
                  '1行目: ${_questionLabel(template.slot1QuestionId)}\n'
                  '2行目: ${_questionLabel(template.slot2QuestionId)}\n'
                  '3行目: ${_questionLabel(template.slot3QuestionId)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _editTemplate(template),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => _editTemplate(null),
              icon: const Icon(Icons.add),
              label: const Text('テンプレートを追加'),
            ),
          ),
        ],
      ),
    );
  }
}

class TemplateEditorPage extends StatefulWidget {
  const TemplateEditorPage({
    super.key,
    required this.template,
    required this.questions,
    required this.nextId,
    required this.nextSortOrder,
  });

  final DiaryTemplate? template;
  final List<Question> questions;
  final String nextId;
  final int nextSortOrder;

  @override
  State<TemplateEditorPage> createState() => _TemplateEditorPageState();
}

class _TemplateEditorPageState extends State<TemplateEditorPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _slot1Id;
  late String _slot2Id;
  late String _slot3Id;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    final template = widget.template;
    _nameController = TextEditingController(text: template?.name ?? '');
    _slot1Id = template?.slot1QuestionId ?? _firstQuestionId();
    _slot2Id = template?.slot2QuestionId ?? _firstQuestionId();
    _slot3Id = template?.slot3QuestionId ?? _firstQuestionId();
    _isDefault = template?.isDefault ?? false;
  }

  String _firstQuestionId() {
    return widget.questions.isNotEmpty ? widget.questions.first.id : '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _questionText(String id) {
    final match = widget.questions.where((question) => question.id == id);
    if (match.isEmpty) {
      return '質問を選択してください';
    }
    return match.first.text;
  }

  Future<void> _pickQuestion(ValueChanged<String> onSelected) async {
    final selected = await showModalBottomSheet<Question>(
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
                  '質問を選択',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: widget.questions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final question = widget.questions[index];
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          title: Text(question.text),
                          subtitle: Text('ID: ${question.id}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).pop(question),
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
      onSelected(selected.id);
    }
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final template = DiaryTemplate(
      id: widget.template?.id ?? widget.nextId,
      name: _nameController.text.trim(),
      slot1QuestionId: _slot1Id,
      slot2QuestionId: _slot2Id,
      slot3QuestionId: _slot3Id,
      sortOrder: widget.template?.sortOrder ?? widget.nextSortOrder,
      isDefault: _isDefault,
    );
    Navigator.of(context).pop(template);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template == null ? 'テンプレート追加' : 'テンプレート編集'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'テンプレート名',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _SlotCard(
                label: '1行目',
                questionText: _questionText(_slot1Id),
                onTap: widget.questions.isEmpty
                    ? null
                    : () => _pickQuestion(
                          (id) => setState(() => _slot1Id = id),
                        ),
              ),
              _SlotCard(
                label: '2行目',
                questionText: _questionText(_slot2Id),
                onTap: widget.questions.isEmpty
                    ? null
                    : () => _pickQuestion(
                          (id) => setState(() => _slot2Id = id),
                        ),
              ),
              _SlotCard(
                label: '3行目',
                questionText: _questionText(_slot3Id),
                onTap: widget.questions.isEmpty
                    ? null
                    : () => _pickQuestion(
                          (id) => setState(() => _slot3Id = id),
                        ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('デフォルトに設定'),
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('保存する'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({
    required this.label,
    required this.questionText,
    required this.onTap,
  });

  final String label;
  final String questionText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          title: Text(label),
          subtitle: Text(questionText),
          trailing: const Icon(Icons.edit),
          onTap: onTap,
        ),
      ),
    );
  }
}
