# Workout Reminders

## Try a reminder

1. Restart the Flutter app after installing the new notification dependency.
2. Sign in and schedule a workout a few minutes in the future.
3. Open Reminders from the dashboard, or expand the scheduled workout and tap its bell icon.
4. Add a reminder, choose At workout time, and save.
5. Allow notifications when the browser or device asks.

The reminder switch disables notifications without losing the chosen lead time.
The trash icon deletes the reminder but keeps the scheduled workout.
Changing the workout date/time also changes its reminder time. If the new
reminder time is already past, it will not be scheduled; adjust the lead time.

## Storage and permissions

Reminder settings are stored on the user's `workout_schedules` document:

```text
reminder:
  minutesBefore: 10
  enabled: true
```

Deleting a reminder removes this field. Deleting the scheduled workout also
removes its reminder. The existing schedule read/update permissions apply;
there is no separate reminders collection to enable in Firestore.

## Delivery limits

- Chrome notifications require the app tab to stay open. Closing the tab stops
  delivery; reopen the app to register remaining future reminders. Browser
  background throttling can delay reminders.
- Android/iOS notifications are scheduled locally on the device. Android uses
  inexact alarms and the operating system may delay delivery.
- Notification permission must be granted on each device/browser.
- Changes made on another device are synchronized when this app is running.
  A closed mobile app cannot receive Firestore changes to cancel or reschedule
  its already registered local notifications until it is opened again.
- The next 64 future reminders are registered, with an on-screen warning when
  that limit is exceeded. This accommodates the iOS pending-notification limit.
- Signing out cancels this app's pending notifications on the current device.

Native notification delivery still needs testing on actual Android/iOS devices.
See the [local notifications plugin documentation](https://pub.dev/packages/flutter_local_notifications/versions/19.5.0)
for native scheduling setup and platform restrictions.
