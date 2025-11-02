import 'package:intl/intl.dart';

class TimezoneService {
  // Offset dari UTC
  static const Map<String, int> timezoneOffsets = {
    'WIB': 7,  // UTC+7
    'WITA': 8, // UTC+8
    'WIT': 9,  // UTC+9
    'London': 0, // UTC+0 (GMT)
  };
  
  // Konversi dari satu timezone ke timezone lain
  static DateTime convertTimezone(
    DateTime sourceTime,
    String sourceTimezone,
    String targetTimezone,
  ) {
    // Konversi ke UTC dulu
    final sourceOffset = timezoneOffsets[sourceTimezone] ?? 7;
    final utcTime = sourceTime.subtract(Duration(hours: sourceOffset));
    
    // Konversi ke target timezone
    final targetOffset = timezoneOffsets[targetTimezone] ?? 7;
    return utcTime.add(Duration(hours: targetOffset));
  }
  
  // Format waktu dengan timezone
  static String formatTime(DateTime time, String timezone) {
    return '${DateFormat('HH:mm').format(time)} $timezone';
  }
  
  // Parse time string dengan timezone
  static DateTime parseTime(String dateStr, String timeStr, String timezone) {
    // Parse tanggal
    final date = DateFormat('MM/dd/yyyy').parse(dateStr);
    
    // Parse waktu (format: HH:mm)
    final timeParts = timeStr.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    // Gabungkan
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
  
  // Get current time in timezone
  static DateTime getCurrentTime(String timezone) {
    final utcNow = DateTime.now().toUtc();
    final offset = timezoneOffsets[timezone] ?? 7;
    return utcNow.add(Duration(hours: offset));
  }
  
  // Format untuk display dengan timezone
  static String formatTimeWithZone(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
}