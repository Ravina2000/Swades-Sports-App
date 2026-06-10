import 'package:equatable/equatable.dart';

import '../../models/venue.dart';
import '../../utils/date_utils.dart';

class VenuesState extends Equatable {
  const VenuesState({
    this.status = ViewStatus.initial,
    this.venues = const [],
    this.errorMessage,
  });

  final ViewStatus status;
  final List<Venue> venues;
  final String? errorMessage;

  VenuesState copyWith({
    ViewStatus? status,
    List<Venue>? venues,
    String? errorMessage,
    bool clearError = false,
  }) =>
      VenuesState(
        status: status ?? this.status,
        venues: venues ?? this.venues,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props => [status, venues, errorMessage];
}
