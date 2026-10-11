import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitstart_mobile_app/models/workout_plan.dart';
import 'package:fitstart_mobile_app/models/scheduled_workout.dart';
import 'package:fitstart_mobile_app/screens/home_screen.dart';
import 'package:fitstart_mobile_app/screens/create_ai_plan_screen.dart';
import 'package:fitstart_mobile_app/screens/ai_workout_plan_screen.dart';
import 'package:fitstart_mobile_app/screens/workout_schedule_screen.dart';
import 'package:fitstart_mobile_app/screens/reminders_screen.dart';
import 'package:fitstart_mobile_app/widgets/workout_page.dart';

const _exercises = [
  {'name': 'Goblet squat', 'sets': 3, 'reps': 8, 'restSeconds': 90},
  {'name': 'Dumbbell floor press', 'sets': 3, 'reps': 8, 'restSeconds': 90},
  {'name': 'Dumbbell row', 'sets': 3, 'reps': 8, 'restSeconds': 90},
];

void main() {
  testWidgets('Planning colors are scoped and leave Home styling unchanged', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(ListView))).colorScheme.primary,
      WorkoutPage.green,
    );
    await tester.pumpWidget(const MaterialApp(home: CreateAiPlanScreen()));
    await tester.pumpAndSettle();
    final theme = Theme.of(tester.element(find.byType(ListView)));
    expect(theme.colorScheme.primary, WorkoutPage.blue);
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF6F8FD));
    expect(
      theme.inputDecorationTheme.focusedBorder?.borderSide.color,
      WorkoutPage.blue,
    );
    expect(tester.takeException(), isNull);
  });

  for (final size in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(1200, 800),
  ]) {
    testWidgets(
      'Workout UI fits $size with accessible text and active controls',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final plan = WorkoutPlan.fromMap('plan', {
          'title': 'Morning Strength',
          'preferences': {
            'goal': 'Build Muscle',
            'experience': 'Intermediate',
            'equipment': 'Dumbbells',
            'daysPerWeek': 4,
            'durationMinutes': 45,
          },
          'exercises': _exercises,
        });
        final booking = ScheduledWorkout.fromMap('booking', {
          'planId': 'plan',
          'title': plan.title,
          'scheduledAt': Timestamp.fromDate(DateTime(2027, 1, 12, 8, 30)),
          'exercises': _exercises,
          'reminder': {'minutesBefore': 15, 'enabled': true},
        });
        Future<void> show(Widget screen) async {
          await tester.pumpWidget(
            MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(size.width == 320 ? 1.4 : 1),
                ),
                child: child!,
              ),
              home: screen,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        await show(const HomeScreen());
        await tester.scrollUntilVisible(
          find.text('Reminders'),
          150,
          scrollable: find.byType(Scrollable).first,
        );
        expect(tester.takeException(), isNull);
        await show(const CreateAiPlanScreen());
        expect(find.text('Generate Plan').hitTestable(), findsOneWidget);
        await tester.ensureVisible(find.byTooltip('Increase Days per week'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Increase Days per week'));
        await tester.pumpAndSettle();
        expect(find.text('4'), findsOneWidget);

        var edited = false;
        await show(
          WorkoutPage(
            title: 'My Workout Plans',
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                WorkoutPlanDetails(
                  plan: plan,
                  onEdit: (_) => edited = true,
                  onDelete: () {},
                  onSchedule: () {},
                ),
              ],
            ),
          ),
        );
        await tester.ensureVisible(find.byTooltip('Edit exercise').first);
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Edit exercise').first);
        expect(edited, isTrue);
        await show(
          WorkoutPage(
            title: 'Workout Schedule',
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ScheduledWorkoutDetails(
                  workout: booking,
                  onReschedule: () {},
                  onDelete: () {},
                  onReminder: () {},
                ),
              ],
            ),
          ),
        );
        await tester.tap(find.text(plan.title));
        await tester.pumpAndSettle();
        expect(find.byTooltip('Reschedule workout'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await show(
          WorkoutPage(
            title: 'Reminders',
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                WorkoutReminderTile(
                  workout: booking,
                  onEdit: () {},
                  onDelete: () {},
                  onToggle: (_) {},
                ),
              ],
            ),
          ),
        );
        await tester.tap(find.byType(Switch));
        expect(tester.takeException(), isNull);
        final longPlan = WorkoutPlan.fromMap('long-plan', {
          'title': 'Morning Strength and Conditioning for a Full Body Workout',
          'preferences': plan.preferences,
          'exercises': _exercises,
        });
        await show(
          WorkoutPage(
            title: 'My Workout Plans',
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                WorkoutPlanDetails(
                  plan: longPlan,
                  onEdit: (_) {},
                  onDelete: () {},
                  onSchedule: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
