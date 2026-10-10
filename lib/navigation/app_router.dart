import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fitstart_mobile_app/features/workout/screens/custom_workout_plan_screen.dart';
import 'package:fitstart_mobile_app/features/workout/screens/my_workouts_screen.dart';
import 'package:fitstart_mobile_app/features/workout/screens/workout_form_screen.dart';
import 'package:fitstart_mobile_app/screens/home_screen.dart';
import 'package:fitstart_mobile_app/screens/welcome_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(
        location: state.uri.path,
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/workouts',
          builder: (context, state) => const MyWorkoutsScreen(),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => const WorkoutFormScreen(),
            ),
            GoRoute(
              path: ':workoutId/edit',
              builder: (context, state) => WorkoutFormScreen(
                workoutId: state.pathParameters['workoutId']!,
              ),
            ),
            GoRoute(
              path: ':workoutId/plan',
              builder: (context, state) => CustomWorkoutPlanScreen(
                workoutId: state.pathParameters['workoutId']!,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = location.startsWith('/workouts') ? 1 : 0;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_rounded),
            label: 'Workouts',
          ),
        ],
        onDestinationSelected: (index) {
          context.go(index == 0 ? '/dashboard' : '/workouts');
        },
      ),
    );
  }
}
