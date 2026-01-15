import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Japanese date formats.
  await initializeDateFormatting('ja');
  runApp(const ThreeLineDiaryApp());
}
