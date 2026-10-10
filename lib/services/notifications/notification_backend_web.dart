import 'dart:async';
import 'dart:js_interop';

import 'notification_backend.dart';

@JS('globalThis.Notification')
external JSAny? get _notificationType;

@JS('Notification')
extension type BrowserNotification._(JSObject _) implements JSObject {
  external factory BrowserNotification(
    String title,
    NotificationOptions options,
  );
  external static JSString get permission;
  external static JSPromise<JSString> requestPermission();
}

@JS()
extension type NotificationOptions._(JSObject _) implements JSObject {
  external factory NotificationOptions({String body, String tag});
}

NotificationBackend createNotificationBackend() => BrowserNotificationBackend();

class BrowserNotificationBackend implements NotificationBackend {
  Timer? _timer;
  final _pending = <WorkoutNotification>[];

  @override
  Future<bool> requestPermission() async {
    if (_notificationType == null) {
      throw StateError('This browser does not support notifications.');
    }
    if (BrowserNotification.permission.toDart == 'granted') return true;
    final result = await BrowserNotification.requestPermission().toDart;
    return result.toDart == 'granted';
  }

  @override
  Future<void> replace(List<WorkoutNotification> notifications) async {
    _timer?.cancel();
    _pending.clear();
    if (notifications.isEmpty) return;
    if (_notificationType == null ||
        BrowserNotification.permission.toDart != 'granted') {
      throw StateError(
        'Allow browser notifications to receive your reminders.',
      );
    }
    _pending.addAll(notifications);
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      final now = DateTime.now();
      final due = _pending
          .where((notification) => !notification.date.isAfter(now))
          .toList();
      for (final notification in due) {
        _pending.remove(notification);
        BrowserNotification(
          notification.title,
          NotificationOptions(body: notification.body, tag: notification.id),
        );
      }
      if (_pending.isEmpty) _timer?.cancel();
    });
  }
}
