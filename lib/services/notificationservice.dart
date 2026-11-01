import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Timezone init
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Karachi'));
    } catch (_) {}

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(settings);

    // Cross-version safe permission request
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final dynamic dynamicAndroid = android;
        try {
          await dynamicAndroid.requestNotificationsPermission();
        } catch (_) {
          try {
            await dynamicAndroid.requestPermission();
          } catch (_) {}
        }
      }
    } catch (_) {}
  }

  static Future<void> showInstantTest() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'lawyer_channel',
      'Case Reminders',
      channelDescription: 'Hearing date reminders for lawyer diary',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(
      9999,
      '🔔 TEST SUCCESS',
      'Lawyer Diary Notification working perfectly!',
      details,
    );
  }

  static Future<void> scheduleAlert({
    required int id,
    required String title,
    required String court,
    required DateTime hearingDate,
    required String reminderTime,
  }) async {
    final parts = reminderTime.split(':');
    final int hour = int.tryParse(parts.isNotEmpty ? parts[0] : '20') ?? 20;
    final int minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    // 1 day before hearing date at chosen time
    DateTime alertDate = DateTime(
      hearingDate.year,
      hearingDate.month,
      hearingDate.day,
      hour,
      minute,
    ).subtract(const Duration(days: 1));

    // If time already passed -> trigger after 15 seconds (for testing / past dates)
    if (alertDate.isBefore(DateTime.now())) {
      alertDate = DateTime.now().add(const Duration(seconds: 15));
    }

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      alertDate,
      tz.local,
    );

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'lawyer_channel',
      'Case Reminders',
      channelDescription: 'Hearing date reminders for lawyer diary',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.zonedSchedule(
      id,
      '🔔 Kal Aapka Case Hai!',
      '$title\nCourt: $court',
      scheduledDate,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}