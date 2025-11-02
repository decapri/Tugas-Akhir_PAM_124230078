class MenstrualRecord {
  final int? id;
  final int userId;
  final DateTime startDate;
  final int duration; // dalam hari
  final DateTime createdAt;

  MenstrualRecord({
    this.id,
    required this.userId,
    required this.startDate,
    required this.duration,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Hitung tanggal selesai haid
  DateTime get endDate => startDate.add(Duration(days: duration - 1));

  // Prediksi haid berikutnya (28 hari dari tanggal pertama)
  DateTime get nextPeriodDate => startDate.add(const Duration(days: 28));

  // Cek apakah tanggal tertentu adalah masa haid
  bool isInPeriod(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final endOnly = DateTime(endDate.year, endDate.month, endDate.day);
    
    return dateOnly.isAtSameMomentAs(startOnly) ||
           dateOnly.isAtSameMomentAs(endOnly) ||
           (dateOnly.isAfter(startOnly) && dateOnly.isBefore(endOnly));
  }

  factory MenstrualRecord.fromMap(Map<String, dynamic> map) {
    return MenstrualRecord(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      startDate: DateTime.parse(map['start_date'] as String),
      duration: map['duration'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'start_date': startDate.toIso8601String(),
      'duration': duration,
      'created_at': createdAt.toIso8601String(),
    };
  }

  MenstrualRecord copyWith({
    int? id,
    int? userId,
    DateTime? startDate,
    int? duration,
    DateTime? createdAt,
  }) {
    return MenstrualRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'MenstrualRecord{id: $id, userId: $userId, startDate: $startDate, duration: $duration}';
  }
}