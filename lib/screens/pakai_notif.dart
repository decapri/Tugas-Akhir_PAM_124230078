import 'package:proyek_akhir_app/services/notifikasi_service.dart';

/// ===============================================================
/// 1. NOTIFIKASI LANGSUNG (Instant)
/// ===============================================================

void exampleAfterSavePeriod() async {
  await NotificationService().showPeriodTrackedNotification();
}

void exampleAfterSaveDonation() async {
  await NotificationService().showDonationTrackedNotification();
  await NotificationService().scheduleDrinkWaterReminder();
}

/// ===============================================================
/// 2. NOTIFIKASI TERJADWAL
/// ===============================================================

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

/// ===============================================================
/// 3. NOTIFIKASI CUSTOM
/// ===============================================================

void exampleCustomNotification() async {
  final reminderDate = DateTime.now().add(const Duration(days: 7));

  await NotificationService().scheduleNotification(
    id: 999,
    title: '🎉 Custom Reminder',
    body: 'Ini adalah notifikasi custom Anda!',
    scheduledDate: reminderDate,
  );
}

/// ===============================================================
/// 4. CANCEL NOTIFIKASI
/// ===============================================================

void exampleCancelNotification() async {
  await NotificationService().cancelNotification(100);
  await NotificationService().cancelPeriodReminders();
  await NotificationService().cancelDonationReminders();
  await NotificationService().cancelAllNotifications();
}

/// ===============================================================
/// 5. CEK NOTIFIKASI YANG PENDING
/// ===============================================================

void exampleCheckPendingNotifications() async {
  final pending = await NotificationService().getPendingNotifications();

  print('Total pending notifications: ${pending.length}');
  for (var notif in pending) {
    print('ID: ${notif.id}, Title: ${notif.title}');
  }
}

/// ===============================================================
/// 6. IMPLEMENTASI DI ADD_MENSTRUAL_PAGE
/// ===============================================================
/// Sudah otomatis kirim notifikasi harian sesuai durasi haid

/*
Future<void> _save() async {
  // Validasi dan simpan data ke database...

  final record = MenstrualRecord(
    userId: widget.userId,
    startDate: _selectedDate,
    duration: _duration,
  );

  final result = await DatabaseHelper.instance.addMenstrualRecord(record);

  if (result > 0) {
    // ✅ Notifikasi langsung
    await NotificationService().showPeriodTrackedNotification();

    // ✅ Reminder haid berikutnya (28 hari dari tanggal awal)
    final nextDate = _selectedDate.add(const Duration(days: 28));
    await NotificationService().scheduleNextPeriodReminder(nextDate);
    await NotificationService().scheduleFirstDayPeriodReminder(nextDate);

    // ✅ Notifikasi harian selama masa haid
    await NotificationService()
        .scheduleDailyMenstruationNotifications(_selectedDate, _duration);

    Navigator.pop(context, true);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gagal menyimpan data')),
    );
  }
}
*/

/// ===============================================================
/// 7. IMPLEMENTASI DI ADD_DONATION_PAGE
/// ===============================================================

/*
Future<void> _save() async {
  final record = DonationRecord(...);
  await DatabaseHelper.instance.addDonationRecord(record);

  await NotificationService().showDonationTrackedNotification();
  await NotificationService().scheduleDrinkWaterReminder();

  final canDonateDate = donationDateTime.add(const Duration(days: 60));
  await NotificationService().scheduleCanDonateReminder(canDonateDate);
  await NotificationService().scheduleDonationReminder(canDonateDate);

  Navigator.pop(context, true);
}
*/

/// ===============================================================
/// 8. NOTIFIKASI HARIAN UMUM
/// ===============================================================

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

/// ===============================================================
/// 9. TIPS
/// ===============================================================
/// 100–199 : Reminder Haid
/// 200–299 : Reminder Donor
/// 300–399 : Notifikasi Instant
/// 400–499 : Notifikasi Custom & Harian Haid
/// 500–599 : Notifikasi Harian Umum
