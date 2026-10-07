class WorkoutNotification {
  final String id;
  final String title;
  final DateTime date;
  final String body;

  const WorkoutNotification({
    required this.id,
    required this.title,
    required this.date,
    required this.body,
  });
}

abstract class NotificationBackend {
  Future<bool> requestPermission();
  Future<void> replace(List<WorkoutNotification> notifications);
}
