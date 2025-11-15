class DonationRecord {
  final int? id;
  final int userId;
  final DateTime donationDate;
  final String timezone; 
  final String location;
  final String? notes;
  final DateTime createdAt;

  DonationRecord({
    this.id,
    required this.userId,
    required this.donationDate,
    this.timezone = 'WIB',
    required this.location,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();


  DateTime get nextDonationDate => donationDate.add(const Duration(days: 60));


  bool canDonateAgain(DateTime date) {
    return date.isAfter(nextDonationDate) || 
           date.isAtSameMomentAs(nextDonationDate);
  }


  int daysUntilNextDonation() {
    final now = DateTime.now();
    if (canDonateAgain(now)) return 0;
    return nextDonationDate.difference(now).inDays;
  }

  factory DonationRecord.fromMap(Map<String, dynamic> map) {
    return DonationRecord(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      donationDate: DateTime.parse(map['donation_date'] as String),
      timezone: map['timezone'] as String? ?? 'WIB',
      location: map['location'] as String? ?? '',
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'donation_date': donationDate.toIso8601String(),
      'timezone': timezone,
      'location': location,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DonationRecord copyWith({
    int? id,
    int? userId,
    DateTime? donationDate,
    String? timezone,
    String? location,
    String? notes,
    DateTime? createdAt,
  }) {
    return DonationRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      donationDate: donationDate ?? this.donationDate,
      timezone: timezone ?? this.timezone,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'DonationRecord{id: $id, userId: $userId, donationDate: $donationDate}';
  }
}