import 'package:flutter_test/flutter_test.dart';

import 'package:fitstart_mobile_app/main.dart';
import 'package:fitstart_mobile_app/screens/welcome_screen.dart';

void main() {
  testWidgets('App opens onboarding and advances to the next page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('FitStart'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Continue'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
