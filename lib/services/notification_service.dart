import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(settings);

    // Pedir permisos Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showNotification(
    String title,
    String body,
  ) async {

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'gymtrack_channel',
      'GymTrack Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  Future<void> checkMembershipStatus(List members) async {

    for (var member in members) {

      final DateTime endDate = member.endDate;

      final int daysLeft =
          endDate.difference(DateTime.now()).inDays;

      // 7 días
      if (daysLeft == 7) {

        await showNotification(
          'Membresía por vencer',
          '${member.name} vence en 7 días',
        );
      }

      // 3 días
      else if (daysLeft == 3) {

        await showNotification(
          'Membresía por vencer',
          '${member.name} vence en 3 días',
        );
      }

      // mañana
      else if (daysLeft == 1) {

        await showNotification(
          'Membresía por vencer',
          '${member.name} vence mañana',
        );
      }

      // hoy
      else if (daysLeft == 0) {

        await showNotification(
          'Membresía vencida',
          '${member.name} vence hoy',
        );
      }

      // vencido
      else if (daysLeft < 0) {

        await showNotification(
          'Membresía vencida',
          '${member.name} tiene membresía vencida',
        );
      }
    }
  }
}