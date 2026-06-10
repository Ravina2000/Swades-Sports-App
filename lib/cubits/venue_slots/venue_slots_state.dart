import 'package:equatable/equatable.dart';

import '../../models/slot.dart';
import '../../utils/date_utils.dart';

class VenueSlotsState extends Equatable {
  const VenueSlotsState({
    required this.venueId,
    this.status = ViewStatus.initial,
    this.selectedDate,
    this.slots,
    this.errorMessage,
    this.bookingHour,
  });

  final int venueId;
  final ViewStatus status;
  final DateTime? selectedDate;
  final VenueSlots? slots;
  final String? errorMessage;
  final int? bookingHour;

  VenueSlotsState copyWith({
    ViewStatus? status,
    DateTime? selectedDate,
    VenueSlots? slots,
    String? errorMessage,
    int? bookingHour,
    bool clearError = false,
    bool clearBookingHour = false,
  }) =>
      VenueSlotsState(
        venueId: venueId,
        status: status ?? this.status,
        selectedDate: selectedDate ?? this.selectedDate,
        slots: slots ?? this.slots,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        bookingHour:
            clearBookingHour ? null : (bookingHour ?? this.bookingHour),
      );

  @override
  List<Object?> get props =>
      [venueId, status, selectedDate, slots, errorMessage, bookingHour];
}
