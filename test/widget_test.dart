import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:swades_sports_app/cubits/auth/auth_cubit.dart';
import 'package:swades_sports_app/cubits/bookings/bookings_cubit.dart';
import 'package:swades_sports_app/cubits/venues/venues_cubit.dart';
import 'package:swades_sports_app/main.dart';
import 'package:swades_sports_app/services/api_service.dart';

void main() {
  testWidgets('shows user select screen on launch', (tester) async {
    final apiService = ApiService();

    await tester.pumpWidget(
      RepositoryProvider(
        create: (_) => apiService,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => AuthCubit()),
            BlocProvider(create: (_) => VenuesCubit(apiService)),
            BlocProvider(create: (_) => BookingsCubit(apiService)),
          ],
          child: const QuickSlotApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('QuickSlot'), findsOneWidget);
    expect(find.text('Alice Sharma'), findsOneWidget);
  });
}
