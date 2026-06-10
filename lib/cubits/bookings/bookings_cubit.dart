import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/api_service.dart';
import '../../utils/date_utils.dart';
import 'bookings_state.dart';

class BookingsCubit extends Cubit<BookingsState> {
  BookingsCubit(this._api) : super(const BookingsState());

  final ApiService _api;

  Future<void> load(String userId) async {
    emit(state.copyWith(status: ViewStatus.loading, clearError: true));
    try {
      final bookings = await _api.fetchUserBookings(userId);
      emit(BookingsState(status: ViewStatus.success, bookings: bookings));
    } catch (e) {
      emit(state.copyWith(
        status: ViewStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<bool> cancel({
    required String userId,
    required int bookingId,
  }) async {
    emit(state.copyWith(cancellingId: bookingId));
    try {
      await _api.cancelBooking(userId: userId, bookingId: bookingId);
      await load(userId);
      return true;
    } catch (e) {
      emit(state.copyWith(
        clearCancellingId: true,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }
}
