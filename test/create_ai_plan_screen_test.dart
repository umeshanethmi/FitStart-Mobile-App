import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitstart_mobile_app/screens/create_ai_plan_screen.dart';

void main() {
  for (final size in [const Size(320, 640), const Size(1200, 800)]) {
    testWidgets('preferences form fits $size and accepts selections', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: CreateAiPlanScreen()));
      expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(3));
      expect(find.byType(DropdownButtonFormField<int>), findsNWidgets(2));
      await tester.tap(find.text('Stay Fit').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Build Muscle').last);
      await tester.pumpAndSettle();
      expect(find.text('Build Muscle'), findsOneWidget);
      await tester.ensureVisible(find.text('Generate Plan'));
      expect(tester.takeException(), isNull);
    });
  }
}
