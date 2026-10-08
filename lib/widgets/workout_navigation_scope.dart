import 'package:flutter/material.dart';

enum WorkoutTab { home, schedule, reminders, progress, support }

class WorkoutNavigationScope extends InheritedWidget {
  final ValueChanged<WorkoutTab> onSelect;

  const WorkoutNavigationScope({
    super.key,
    required this.onSelect,
    required super.child,
  });

  static bool select(BuildContext context, WorkoutTab tab) {
    final scope = context
        .getInheritedWidgetOfExactType<WorkoutNavigationScope>();
    if (scope == null) return false;
    scope.onSelect(tab);
    return true;
  }

  @override
  bool updateShouldNotify(WorkoutNavigationScope oldWidget) => false;
}
