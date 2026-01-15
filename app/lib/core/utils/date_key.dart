import 'package:intl/intl.dart';

String dateKeyFromDate(DateTime date) {
  final localDate = DateTime(date.year, date.month, date.day);
  return DateFormat('yyyy-MM-dd').format(localDate);
}

DateTime dateFromKey(String key) {
  return DateTime.parse(key);
}

String formatDisplayDate(DateTime date) {
  return DateFormat('yyyy年M月d日（E）', 'ja').format(date);
}
