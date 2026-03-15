import 'package:flutter_test/flutter_test.dart';
import 'package:moviebox_mg/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MovieMGApp());
  });
}