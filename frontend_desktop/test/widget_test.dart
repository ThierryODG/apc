import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_desktop/app.dart';

void main() {
  testWidgets('App smoke test — renders ApcApp', (WidgetTester tester) async {
    await tester.pumpWidget(const ApcApp());
    expect(find.byType(ApcApp), findsOneWidget);
  });
}
