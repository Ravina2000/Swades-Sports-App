import 'package:equatable/equatable.dart';

import '../../models/booking.dart';
import '../../utils/date_utils.dart';

class BookingsState extends Equatable {
  const BookingsState({
    this.status = ViewStatus.initial,
    this.bookings = const [],
    this.errorMessage,
    this.cancellingId,
  });

  final ViewStatus status;
  final List<Booking> bookings;
  final String? errorMessage;
  final int? cancellingId;

  BookingsState copyWith({
    ViewStatus? status,
    List<Booking>? bookings,
    String? errorMessage,
    int? cancellingId,
    bool clearError = false,
    bool clearCancellingId = false,
  }) =>
      BookingsState(
        status: status ?? this.status,
        bookings: bookings ?? this.bookings,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        cancellingId:
            clearCancellingId ? null : (cancellingId ?? this.cancellingId),
      );

  @override
  List<Object?> get props => [status, bookings, errorMessage, cancellingId];
}
