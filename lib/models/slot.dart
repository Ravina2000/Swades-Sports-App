enum SlotStatus { available, booked, bookedByYou }

class Slot {
  const Slot({
    required this.startHour,
    required this.endHour,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.bookedBy,
  });

  final int startHour;
  final int endHour;
  final String startTime;
  final String endTime;
  final SlotStatus status;
  final String? bookedBy;

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
        startHour: json['start_hour'] as int,
        endHour: json['end_hour'] as int,
        startTime: json['start_time'] as String,
        endTime: json['end_time'] as String,
        status: _parseStatus(json['status'] as String),
        bookedBy: json['booked_by'] as String?,
      );

  static SlotStatus _parseStatus(String raw) => switch (raw) {
        'available' => SlotStatus.available,
        'booked_by_you' => SlotStatus.bookedByYou,
        _ => SlotStatus.booked,
      };

  String get label => '$startTime – $endTime';

  bool get isAvailable => status == SlotStatus.available;
}

class VenueSlots {
  const VenueSlots({
    required this.venueId,
    required this.venueName,
    required this.date,
    required this.slots,
  });

  final int venueId;
  final String venueName;
  final String date;
  final List<Slot> slots;

  factory VenueSlots.fromJson(Map<String, dynamic> json) => VenueSlots(
        venueId: json['venue_id'] as int,
        venueName: json['venue_name'] as String,
        date: json['date'] as String,
        slots: (json['slots'] as List<dynamic>)
            .map((e) => Slot.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
