import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:app/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders home shell', (WidgetTester tester) async {
    await initializeDateFormatting('ja');

    await tester.pumpWidget(const OneDayOneLogApp());
    await tester.pumpAndSettle();

    expect(find.text('1D1L'), findsWidgets);
  });
}
