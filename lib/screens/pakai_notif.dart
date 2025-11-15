import 'package:proyek_akhir_app/services/notifikasi_service.dart';


void exampleAfterSavePeriod() async {
  await NotificationService().showPeriodTrackedNotification();
}

void exampleAfterSaveDonation() async {
  await NotificationService().showDonationTrackedNotification();
  await NotificationService().scheduleDrinkWaterReminder();
}



void exampleSetPeriodReminder() async {
  final nextPeriodDate = DateTime.now().add(const Duration(days: 28));

  await NotificationService().scheduleNextPeriodReminder(nextPeriodDate);
  await NotificationService().scheduleFirstDayPeriodReminder(nextPeriodDate);
}

void exampleSetDonationReminder() async {
  final canDonateDate = DateTime.now().add(const Duration(days: 60));

  await NotificationService().scheduleDonationReminder(canDonateDate);
  await NotificationService().scheduleCanDonateReminder(canDonateDate);
}



void exampleCustomNotification() async {
  final reminderDate = DateTime.now().add(const Duration(days: 7));

  await NotificationService().scheduleNotification(
    id: 999,
    title: '🎉 Custom Reminder',
    body: 'Ini adalah notifikasi custom Anda!',
    scheduledDate: reminderDate,
  );
}


void exampleCancelNotification() async {
  await NotificationService().cancelNotification(100);
  await NotificationService().cancelPeriodReminders();
  await NotificationService().cancelDonationReminders();
  await NotificationService().cancelAllNotifications();
}



void exampleCheckPendingNotifications() async {
  final pending = await NotificationService().getPendingNotifications();

  print('Total pending notifications: ${pending.length}');
  for (var notif in pending) {
    print('ID: ${notif.id}, Title: ${notif.title}');
  }
}

void exampleDailyNotification() async {
  await NotificationService().scheduleDailyNotification(
    id: 500,
    title: '🌅 Selamat Pagi!',
    body: 'Jangan lupa cek siklus haid Anda hari ini 💕',
    hour: 8,
    minute: 0,
  );

  await NotificationService().scheduleDailyNotification(
    id: 501,
    title: '🌙 Selamat Malam',
    body: 'Istirahat cukup biar tubuh tetap fit 💪',
    hour: 21,
    minute: 0,
  );
}

// Note!!!
// 100–199 : Reminder Haid
// 200–299 : Reminder Donor
// 300–399 : Notifikasi Instant
// 500–599 : Notifikasi Harian Umum
