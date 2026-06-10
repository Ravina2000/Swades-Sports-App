import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/api_service.dart';
import '../../utils/date_utils.dart';
import 'venues_state.dart';

class VenuesCubit extends Cubit<VenuesState> {
  VenuesCubit(this._api) : super(const VenuesState());

  final ApiService _api;

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading, clearError: true));
    try {
      final venues = await _api.fetchVenues();
      emit(VenuesState(status: ViewStatus.success, venues: venues));
    } catch (e) {
      emit(state.copyWith(
        status: ViewStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
