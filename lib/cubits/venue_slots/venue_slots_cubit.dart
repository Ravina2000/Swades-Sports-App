import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/booking.dart';
import '../../services/api_service.dart';
import '../../utils/date_utils.dart';
import 'venue_slots_state.dart';

class VenueSlotsCubit extends Cubit<VenueSlotsState> {
  VenueSlotsCubit({
    required ApiService api,
    required int venueId,
    required String? userId,
  })  : _api = api,
        _userId = userId,
        super(VenueSlotsState(venueId: venueId, selectedDate: todayDate()));

  final ApiService _api;
  final String? _userId;

  Future<void> loadSlots() async {
    final date = state.selectedDate ?? todayDate();
    emit(state.copyWith(status: ViewStatus.loading, clearError: true));

    try {
      final slots = await _api.fetchSlots(
        venueId: state.venueId,
        date: formatApiDate(date),
        userId: _userId,
      );
      emit(state.copyWith(status: ViewStatus.success, slots: slots));
    } catch (e) {
      emit(state.copyWith(
        status: ViewStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void selectDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
    loadSlots();
  }

  Future<BookingResult> bookSlot({required int startHour}) async {
    if (_userId == null) {
      return BookingResult.failure('Not signed in');
    }

    final date = state.selectedDate ?? todayDate();
    emit(state.copyWith(bookingHour: startHour));

    try {
      await _api.createBooking(
        userId: _userId,
        venueId: state.venueId,
        date: formatApiDate(date),
        startHour: startHour,
      );
      await loadSlots();
      emit(state.copyWith(clearBookingHour: true));
      return BookingResult.success();
    } on ApiException catch (e) {
      await loadSlots();
      emit(state.copyWith(clearBookingHour: true));
      return BookingResult.failure(e.message, isSlotTaken: e.isSlotTaken);
    } catch (e) {
      emit(state.copyWith(clearBookingHour: true));
      return BookingResult.failure(e.toString());
    }
  }
}

class BookingResult {
  const BookingResult._({
    required this.success,
    this.message,
    this.isSlotTaken = false,
  });

  factory BookingResult.success() => const BookingResult._(success: true);

  factory BookingResult.failure(String message, {bool isSlotTaken = false}) =>
      BookingResult._(
        success: false,
        message: message,
        isSlotTaken: isSlotTaken,
      );

  final bool success;
  final String? message;
  final bool isSlotTaken;
}
