import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitstart_mobile_app/widgets/delete_workout_plan_dialog.dart';

Future<void> openConfirmation(
  WidgetTester tester,
  Future<void> Function() onDelete,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => DeleteWorkoutPlanDialog(
                title: 'Build Muscle Plan',
                onDelete: onDelete,
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('cancel leaves the plan untouched', (tester) async {
    var deletions = 0;
    await openConfirmation(tester, () async {
      deletions++;
    });
    expect(
      find.text(
        'Delete "Build Muscle Plan" and all its exercises? This cannot be undone.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(deletions, 0);
    expect(find.byType(DeleteWorkoutPlanDialog), findsNothing);
  });

  testWidgets('confirmation deletes once and blocks commands while pending', (
    tester,
  ) async {
    var deletions = 0;
    final pending = Completer<void>();
    await openConfirmation(tester, () {
      deletions++;
      return pending.future;
    });
    await tester.tap(find.text('Delete'));
    await tester.pump();
    expect(deletions, 1);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Cancel'))
          .onPressed,
      isNull,
    );
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.byType(DeleteWorkoutPlanDialog), findsNothing);
  });

  testWidgets('failed deletion allows retry', (tester) async {
    var attempts = 0;
    await openConfirmation(tester, () async {
      attempts++;
      if (attempts == 1) throw Exception('offline');
    });
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(
      find.text('Could not delete the plan. Please try again.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.byType(DeleteWorkoutPlanDialog), findsNothing);
  });
}
