import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits/auth/auth_cubit.dart';
import 'cubits/auth/auth_state.dart';
import 'cubits/bookings/bookings_cubit.dart';
import 'cubits/venues/venues_cubit.dart';
import 'screens/home_screen.dart';
import 'screens/user_select_screen.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = ApiService();

  runApp(
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
}

class QuickSlotApp extends StatelessWidget {
  const QuickSlotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickSlot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B7A4E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: false),
      ),
      home: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) =>
            state.user == null ? const UserSelectScreen() : const HomeScreen(),
      ),
    );
  }
}
