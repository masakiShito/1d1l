import 'package:shared_preferences/shared_preferences.dart';

class PromptSettings {
  const PromptSettings({
    required this.prompt1,
    required this.prompt2,
    required this.prompt3,
  });

  static const String defaultPrompt1 = '今日あった良いことは？';
  static const String defaultPrompt2 = '今日学んだことは？';
  static const String defaultPrompt3 = '明日やりたいことは？';

  static const PromptSettings defaults = PromptSettings(
    prompt1: defaultPrompt1,
    prompt2: defaultPrompt2,
    prompt3: defaultPrompt3,
  );

  final String prompt1;
  final String prompt2;
  final String prompt3;

  List<String> asList() => [prompt1, prompt2, prompt3];
}

class PromptSettingsStorage {
  const PromptSettingsStorage(this._prefs);

  static const String _prompt1Key = 'prompt1';
  static const String _prompt2Key = 'prompt2';
  static const String _prompt3Key = 'prompt3';

  final SharedPreferences _prefs;

  static Future<PromptSettingsStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PromptSettingsStorage(prefs);
  }

  Future<PromptSettings> load() async {
    return PromptSettings(
      prompt1: _prefs.getString(_prompt1Key) ?? PromptSettings.defaultPrompt1,
      prompt2: _prefs.getString(_prompt2Key) ?? PromptSettings.defaultPrompt2,
      prompt3: _prefs.getString(_prompt3Key) ?? PromptSettings.defaultPrompt3,
    );
  }

  Future<void> save(PromptSettings settings) async {
    await _prefs.setString(_prompt1Key, settings.prompt1);
    await _prefs.setString(_prompt2Key, settings.prompt2);
    await _prefs.setString(_prompt3Key, settings.prompt3);
  }

  Future<void> reset() async {
    await save(PromptSettings.defaults);
  }
}
