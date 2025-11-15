import 'package:intl/intl.dart';

class TimezoneService {

  static const Map<String, int> timezoneOffsets = {
    'WIB': 7,  
    'WITA': 8, 
    'WIT': 9,  
    'London': 0, 
  };
  
 
  static DateTime convertTimezone(
    DateTime sourceTime,
    String sourceTimezone,
    String targetTimezone,
  ) {
    
    final sourceOffset = timezoneOffsets[sourceTimezone] ?? 7;
    final utcTime = sourceTime.subtract(Duration(hours: sourceOffset));
    
   
    final targetOffset = timezoneOffsets[targetTimezone] ?? 7;
    return utcTime.add(Duration(hours: targetOffset));
  }
  
  
  static String formatTime(DateTime time, String timezone) {
    return '${DateFormat('HH:mm').format(time)} $timezone';
  }
  
  
  static DateTime parseTime(String dateStr, String timeStr, String timezone) {
    
    final date = DateFormat('MM/dd/yyyy').parse(dateStr);
    
    final timeParts = timeStr.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    return DateTime(date.year, date.month, date.day, hour, minute);
  }
  
 
  static DateTime getCurrentTime(String timezone) {
    final utcNow = DateTime.now().toUtc();
    final offset = timezoneOffsets[timezone] ?? 7;
    return utcNow.add(Duration(hours: offset));
  }
  

  static String formatTimeWithZone(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
}