import 'package:flutter/material.dart';

import '../../core/storage/prompt_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.initialSettings,
    required this.storage,
    required this.onSaved,
  });

  final PromptSettings initialSettings;
  final PromptSettingsStorage storage;
  final ValueChanged<PromptSettings> onSaved;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const int _maxLength = 60;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _prompt1Controller;
  late final TextEditingController _prompt2Controller;
  late final TextEditingController _prompt3Controller;

  @override
  void initState() {
    super.initState();
    _prompt1Controller =
        TextEditingController(text: widget.initialSettings.prompt1);
    _prompt2Controller =
        TextEditingController(text: widget.initialSettings.prompt2);
    _prompt3Controller =
        TextEditingController(text: widget.initialSettings.prompt3);
  }

  @override
  void dispose() {
    _prompt1Controller.dispose();
    _prompt2Controller.dispose();
    _prompt3Controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final settings = PromptSettings(
      prompt1: _prompt1Controller.text.trim(),
      prompt2: _prompt2Controller.text.trim(),
      prompt3: _prompt3Controller.text.trim(),
    );
    await widget.storage.save(settings);
    widget.onSaved(settings);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('質問を保存しました')),
      );
    }
  }

  Future<void> _resetToDefault() async {
    const defaults = PromptSettings.defaults;
    setState(() {
      _prompt1Controller.text = defaults.prompt1;
      _prompt2Controller.text = defaults.prompt2;
      _prompt3Controller.text = defaults.prompt3;
    });
    await widget.storage.save(defaults);
    widget.onSaved(defaults);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('デフォルトに戻しました')),
      );
    }
  }

  String? _validatePrompt(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '必須項目です';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '質問をカスタマイズ',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              _PromptCard(
                label: '質問1',
                controller: _prompt1Controller,
                validator: _validatePrompt,
                maxLength: _maxLength,
              ),
              _PromptCard(
                label: '質問2',
                controller: _prompt2Controller,
                validator: _validatePrompt,
                maxLength: _maxLength,
              ),
              _PromptCard(
                label: '質問3',
                controller: _prompt3Controller,
                validator: _validatePrompt,
                maxLength: _maxLength,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _resetToDefault,
                      icon: const Icon(Icons.refresh),
                      label: const Text('デフォルトに戻す'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('保存する'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.label,
    required this.controller,
    required this.validator,
    required this.maxLength,
  });

  final String label;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final int maxLength;

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
          child: TextFormField(
            controller: controller,
            maxLength: maxLength,
            decoration: InputDecoration(
              labelText: label,
              border: InputBorder.none,
            ),
            validator: validator,
          ),
        ),
      ),
    );
  }
}
