import 'package:flutter_test/flutter_test.dart';
import 'package:sihijau_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SiHijauApp());

    // Verify that the app starts without errors.
    expect(find.byType(SiHijauApp), findsOneWidget);
  });
}
