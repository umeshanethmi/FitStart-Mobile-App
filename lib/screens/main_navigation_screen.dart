import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/screens/home_screen.dart';
import 'package:fitstart_mobile_app/screens/progress_analytics_screen.dart';
import 'package:fitstart_mobile_app/screens/expert_support_screen.dart';
import 'package:fitstart_mobile_app/screens/workout_schedule_screen.dart';
import 'package:fitstart_mobile_app/screens/reminders_screen.dart';
import 'package:fitstart_mobile_app/widgets/workout_navigation_scope.dart';
import 'package:fitstart_mobile_app/widgets/workout_page.dart';

class MainNavigationScreen extends StatefulWidget {
  final Widget Function(WorkoutTab)? destinationBuilder;

  const MainNavigationScreen({super.key, this.destinationBuilder});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final _navigator = GlobalKey<NavigatorState>();
  final _selected = ValueNotifier<int>(0);
  final _pages = List<Widget?>.filled(WorkoutTab.values.length, null);

  Widget _page(WorkoutTab tab) =>
      widget.destinationBuilder?.call(tab) ??
      switch (tab) {
        WorkoutTab.home => const HomeScreen(),
        WorkoutTab.schedule => const WorkoutScheduleScreen(),
        WorkoutTab.reminders => const RemindersScreen(),
        WorkoutTab.progress => const ProgressAnalyticsScreen(),
        WorkoutTab.support => const ExpertSupportScreen(),
      };

  @override
  void initState() {
    super.initState();
    _pages[0] = _page(WorkoutTab.home);
  }

  @override
  void dispose() {
    _selected.dispose();
    super.dispose();
  }

  void _select(WorkoutTab tab) {
    FocusManager.instance.primaryFocus?.unfocus();
    _navigator.currentState?.popUntil((route) => route.isFirst);
    _pages[tab.index] ??= _page(tab);
    _selected.value = tab.index;
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: WorkoutPage.theme(context),
    child: WorkoutNavigationScope(
      onSelect: _select,
      child: ValueListenableBuilder<int>(
        valueListenable: _selected,
        builder: (context, selected, _) => Scaffold(
          body: NavigatorPopHandler<Object?>(
            onPopWithResult: (result) => _navigator.currentState!.pop(result),
            child: Navigator(
              key: _navigator,
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (_) => ValueListenableBuilder<int>(
                  valueListenable: _selected,
                  builder: (_, index, _) => IndexedStack(
                    index: index,
                    children: [
                      for (
                        var pageIndex = 0;
                        pageIndex < _pages.length;
                        pageIndex++
                      )
                        TickerMode(
                          enabled: pageIndex == index,
                          child: _pages[pageIndex] ?? const SizedBox.shrink(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: WorkoutPage.line)),
            ),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                labelTextStyle: WidgetStateProperty.resolveWith(
                  (states) => Theme.of(context).textTheme.labelMedium!.copyWith(
                    fontSize: 12,
                    fontWeight: states.contains(WidgetState.selected)
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: states.contains(WidgetState.selected)
                        ? WorkoutPage.green
                        : WorkoutPage.muted,
                  ),
                ),
              ),
              child: NavigationBar(
                selectedIndex: selected,
                onDestinationSelected: (index) =>
                    _select(WorkoutTab.values[index]),
                height: 72,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                indicatorColor: const Color(0xFFE1F1E8),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.calendar_month_outlined),
                    selectedIcon: Icon(Icons.calendar_month),
                    label: 'Schedule',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.notifications_outlined),
                    selectedIcon: Icon(Icons.notifications),
                    label: 'Reminders',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.insights_outlined),
                    selectedIcon: Icon(Icons.insights),
                    label: 'Progress',
                    tooltip: 'Progress & Analytics',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.support_agent_outlined),
                    selectedIcon: Icon(Icons.support_agent),
                    label: 'Support',
                    tooltip: 'Expert Support',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
