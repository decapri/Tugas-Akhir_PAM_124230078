import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // 🔹 Inisialisasi Notifikasi
  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        print('📲 Notification tapped: ${details.payload}');
      },
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // 🔔 Notifikasi langsung (muncul saat itu juga)
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_channel',
      'Instant Notifications',
      channelDescription: 'Notifikasi langsung muncul',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // ⏰ Notifikasi terjadwal satu kali
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return; // hindari waktu lampau

    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Notifikasi yang dijadwalkan',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  // 🔁 Notifikasi harian berulang (jam tetap tiap hari)
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel',
          'Daily Notifications',
          channelDescription: 'Notifikasi harian berulang',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // ❌ Cancel satu notifikasi
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // ❌ Cancel semua notifikasi
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // ========== FITUR BLOODON APP ========== //

  // 🩸 Reminder haid akan datang (3 hari sebelum)
  Future<void> scheduleNextPeriodReminder(DateTime nextPeriodDate) async {
    final reminderDate = nextPeriodDate.subtract(const Duration(days: 3));
    await scheduleNotification(
      id: 100,
      title: '🩸 Reminder Haid',
      body: 'Haid Anda diprediksi akan datang dalam 3 hari. Jaga kesehatan ya!',
      scheduledDate: reminderDate.add(const Duration(hours: 9)),
    );
  }

  // 🩸 Hari pertama haid
  Future<void> scheduleFirstDayPeriodReminder(DateTime firstDayDate) async {
    await scheduleNotification(
      id: 101,
      title: '🩸 Hari Pertama Haid',
      body: 'Jangan lupa catat tanggal haid Anda di aplikasi!',
      scheduledDate: firstDayDate.add(const Duration(hours: 8)),
    );
  }

  // 💉 Reminder donor darah
  Future<void> scheduleCanDonateReminder(DateTime canDonateDate) async {
    await scheduleNotification(
      id: 200,
      title: '💉 Sudah Bisa Donor Lagi!',
      body: 'Anda sudah bisa melakukan donor darah. Yuk berbagi untuk sesama!',
      scheduledDate: canDonateDate.add(const Duration(hours: 10)),
    );
  }

  // 💉 Reminder donor 3 hari lagi
  Future<void> scheduleDonationReminder(DateTime nextDonationDate) async {
    final reminderDate = nextDonationDate.subtract(const Duration(days: 3));
    await scheduleNotification(
      id: 201,
      title: '💉 Reminder Donor Darah',
      body: '3 hari lagi Anda sudah bisa donor darah. Cek lokasi PMI terdekat!',
      scheduledDate: reminderDate.add(const Duration(hours: 9)),
    );
  }

  // ✅ Setelah donor darah
  Future<void> showDonationTrackedNotification() async {
    await showInstantNotification(
      id: 301,
      title: '✅ Donor Darah Berhasil',
      body: 'Terima kasih sudah mendonorkan darah! Reward Anda telah ditambahkan.',
    );
  }

  // 🩸 Setelah input menstruasi
  Future<void> showPeriodTrackedNotification() async {
    await showInstantNotification(
      id: 300,
      title: '🩸 Data Menstruasi Disimpan',
      body: 'Catatan menstruasi berhasil disimpan. Terima kasih telah melacaknya!',
    );
  }

  // 💧 Reminder minum air setelah donor (2 jam kemudian)
  Future<void> scheduleDrinkWaterReminder() async {
    final reminderTime = DateTime.now().add(const Duration(hours: 2));

    await scheduleNotification(
      id: 302,
      title: '💧 Minum Air Putih Yuk!',
      body: 'Setelah donor, pastikan kamu minum air yang cukup untuk pemulihan 💪',
      scheduledDate: reminderTime,
    );
  }

  // ❌ Cancel reminder haid & donor
  Future<void> cancelPeriodReminders() async {
    await cancelNotification(100);
    await cancelNotification(101);
    for (int i = 400; i <= 500; i++) {
      await cancelNotification(i);
    }
  }

  Future<void> cancelDonationReminders() async {
    await cancelNotification(200);
    await cancelNotification(201);
  }

  // 🩸 Jadwal notifikasi setiap hari selama masa haid
  Future<void> scheduleDailyPeriodNotifications({
    required DateTime startDate,
    required int durationDays,
  }) async {
    // Batalkan dulu reminder haid sebelumnya
    for (int i = 400; i <= 500; i++) {
      await cancelNotification(i);
    }

    for (int i = 0; i < durationDays; i++) {
      final scheduledDate = startDate.add(Duration(days: i));
      final scheduledTime = DateTime(
          scheduledDate.year, scheduledDate.month, scheduledDate.day, 9, 0);
      final dayNumber = i + 1;

      await scheduleNotification(
        id: 400 + i,
        title: '🩸 Hari ke-$dayNumber Haid',
        body:
            'Hari ke-$dayNumber masa haidmu. Minum air putih dan cukup istirahat 💧',
        scheduledDate: scheduledTime,
      );
    }

    // 🔚 Notifikasi penutup di akhir
    final endDate = startDate.add(Duration(days: durationDays, hours: 8));
    await scheduleNotification(
      id: 500,
      title: '🩸 Masa Haid Selesai',
      body: 'Selamat! Tubuhmu sudah pulih. Yuk tetap sehat 💪',
      scheduledDate: endDate,
    );
  }
}
