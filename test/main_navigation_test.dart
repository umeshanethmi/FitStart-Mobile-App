import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitstart_mobile_app/screens/main_navigation_screen.dart';
import 'package:fitstart_mobile_app/screens/home_screen.dart';
import 'package:fitstart_mobile_app/screens/create_ai_plan_screen.dart';
import 'package:fitstart_mobile_app/widgets/workout_navigation_scope.dart';

class _TestPage extends StatefulWidget {
  final WorkoutTab tab;
  const _TestPage(this.tab);

  @override
  State<_TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<_TestPage> {
  var count = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('${widget.tab.name} page')),
    body: ListView(
      children: [
        Text('Count $count'),
        TextButton(
          onPressed: () => setState(() => count++),
          child: const Text('Increment'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('Detail')),
                body: const Text('Detail content'),
              ),
            ),
          ),
          child: const Text('Open detail'),
        ),
        for (var index = 0; index < 30; index++)
          ListTile(title: Text('Row $index')),
      ],
    ),
  );
}

void main() {
  testWidgets('Tabs initialize lazily and retain state and scroll position', (
    tester,
  ) async {
    final built = <WorkoutTab>[];
    await tester.pumpWidget(
      MaterialApp(
        home: MainNavigationScreen(
          destinationBuilder: (tab) {
            built.add(tab);
            return _TestPage(tab);
          },
        ),
      ),
    );
    expect(built, [WorkoutTab.home]);
    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Increment'));
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    final offset = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .pixels;
    await tester.tap(find.text('Reminders'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();
    expect(built.where((tab) => tab == WorkoutTab.schedule).length, 1);
    expect(
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .pixels,
      offset,
    );
    await tester.drag(find.byType(ListView), const Offset(0, 700));
    await tester.pumpAndSettle();
    expect(find.text('Count 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Details keep the bar, Back pops details, and tab changes return to root',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainNavigationScreen(destinationBuilder: _TestPage.new),
        ),
      );
      await tester.tap(find.text('Schedule'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open detail'));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Detail content'), findsNothing);
      expect(find.text('schedule page'), findsOneWidget);
      await tester.tap(find.text('Open detail'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();
      expect(find.text('Detail content'), findsNothing);
      expect(find.text('reminders page'), findsOneWidget);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        2,
      );
      expect(tester.takeException(), isNull);
      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(
        bar.destinations.cast<NavigationDestination>().map(
          (destination) => destination.label,
        ),
        ['Home', 'Schedule', 'Reminders', 'Progress', 'Support'],
      );
      await tester.tap(find.text('Support'));
      await tester.pumpAndSettle();
      expect(find.text('support page'), findsOneWidget);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        4,
      );
    },
  );

  for (final size in [
    const Size(320, 480),
    const Size(390, 844),
    const Size(1200, 800),
  ]) {
    testWidgets(
      'Home shortcuts and the plan form work with navigation at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.3)),
              child: child!,
            ),
            home: MainNavigationScreen(
              destinationBuilder: (tab) =>
                  tab == WorkoutTab.home ? const HomeScreen() : _TestPage(tab),
            ),
          ),
        );
        expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
        expect(find.byTooltip('Settings & Privacy'), findsOneWidget);
        expect(find.byTooltip('Log out'), findsOneWidget);
        final logoRect = tester.getRect(find.byIcon(Icons.bolt_rounded));
        final logoutRect = tester.getRect(find.byTooltip('Log out'));
        final titleRect = tester.getRect(find.text('FitStart'));
        expect(logoRect.right, lessThan(titleRect.left));
        expect(titleRect.right, lessThanOrEqualTo(logoutRect.left));
        expect(logoRect.left, greaterThanOrEqualTo(0));
        expect(logoRect.right, lessThanOrEqualTo(size.width));
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(
          find.text('Progress & Analytics'),
          150,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Progress & Analytics'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<NavigationBar>(find.byType(NavigationBar))
              .selectedIndex,
          3,
        );
        expect(find.text('progress page'), findsOneWidget);
        await tester.tap(find.text('Home'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Create Workout Plan'),
          -150,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Create Workout Plan'));
        await tester.pumpAndSettle();
        expect(find.byType(CreateAiPlanScreen), findsOneWidget);
        expect(find.text('Generate Plan').hitTestable(), findsOneWidget);
        expect(find.byType(NavigationBar), findsOneWidget);
        await tester.tap(find.text('Schedule'));
        await tester.pumpAndSettle();
        expect(find.byType(CreateAiPlanScreen), findsNothing);
        expect(find.text('schedule page'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
