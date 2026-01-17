class InputSanitizer {
  static String normalizeText(String value) {
    return value.replaceAll('\r\n', '\n').trimRight();
  }
}
