import 'package:flutter/material.dart';

import '../../core/errors/validation_error.dart';
import '../../core/model/daily_log.dart';
import '../../core/utils/date_key.dart';
import '../../core/utils/input_sanitizer.dart';
import '../../core/validators/log_validator.dart';
import '../../core/widgets/cloud_error_toast.dart';

class WritePage extends StatefulWidget {
  const WritePage({
    super.key,
    required this.dateKey,
    required this.log,
    required this.onSave,
    required this.onValidationFailed,
    required this.isSaving,
  });

  final String dateKey;
  final DailyLog? log;
  final Future<void> Function(String dateKey, String text) onSave;
  final ValueChanged<ValidationResult> onValidationFailed;
  final bool isSaving;

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  final LogValidator _validator = LogValidator();
  bool _isLogEmpty = true;

  @override
  void initState() {
    super.initState();
    _applyLog(widget.log);
  }

  @override
  void didUpdateWidget(covariant WritePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dateKey != widget.dateKey || oldWidget.log != widget.log) {
      setState(() => _applyLog(widget.log));
    }
  }

  void _applyLog(DailyLog? log) {
    final text = log?.text ?? '';
    _textController.text = text;
    _isLogEmpty = _isTextEmpty(text);
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  bool _isTextEmpty(String value) {
    return InputSanitizer.normalizeText(value).trim().isEmpty;
  }

  void _handleTextChange(String value) {
    final isEmpty = _isTextEmpty(value);
    if (_isLogEmpty != isEmpty) {
      setState(() => _isLogEmpty = isEmpty);
    }
  }

  void _showCloudError(String message) {
    CloudErrorToast.show(
      context,
      message: message,
    );
  }

  Future<void> _handleSave() async {
    if (widget.isSaving) {
      return;
    }
    final normalized = InputSanitizer.normalizeText(_textController.text);
    final result = _validator.validate(normalized);
    if (!result.isValid) {
      widget.onValidationFailed(result);
      _showCloudError(result.firstMessageFor('text') ?? 'ログが空欄だよ');
      _textFocusNode.requestFocus();
      return;
    }
    await widget.onSave(widget.dateKey, normalized);
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
                  focusNode: _textFocusNode,
                  onChanged: _handleTextChange,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleSave(),
                  decoration: InputDecoration(
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
              onPressed:
                  widget.isSaving || _isLogEmpty ? null : _handleSave,
              child: widget.isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('保存する'),
            ),
          ),
        ],
      ),
    );
  }
}
