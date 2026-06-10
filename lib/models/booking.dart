class Booking {
  const Booking({
    required this.id,
    required this.userId,
    required this.venueId,
    required this.venueName,
    required this.date,
    required this.startHour,
    required this.endHour,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final String userId;
  final int venueId;
  final String venueName;
  final String date;
  final int startHour;
  final int endHour;
  final String startTime;
  final String endTime;
  final String status;
  final String createdAt;

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as int,
        userId: json['user_id'] as String,
        venueId: json['venue_id'] as int,
        venueName: json['venue_name'] as String,
        date: json['date'] as String,
        startHour: json['start_hour'] as int,
        endHour: json['end_hour'] as int,
        startTime: json['start_time'] as String,
        endTime: json['end_time'] as String,
        status: json['status'] as String,
        createdAt: json['created_at'] as String,
      );

  String get timeLabel => '$startTime – $endTime';
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.message, {this.body});

  final int statusCode;
  final String message;
  final String? body;

  bool get isSlotTaken => statusCode == 409;

  @override
  String toString() => message;
}
