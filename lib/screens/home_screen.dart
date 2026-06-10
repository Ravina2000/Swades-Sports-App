import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';
import 'my_bookings_screen.dart';
import 'venues_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user = authState.user;
        if (user == null) {
          return const SizedBox.shrink();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_index == 0 ? 'Venues' : 'My Bookings'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  avatar: CircleAvatar(
                    radius: 12,
                    child: Text(
                      user.name[0],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  label: Text(user.name.split(' ').first),
                  onPressed: () => _switchUser(context),
                ),
              ),
            ],
          ),
          body: IndexedStack(
            index: _index,
            children: const [
              VenuesScreen(),
              MyBookingsScreen(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.stadium_outlined),
                selectedIcon: Icon(Icons.stadium),
                label: 'Venues',
              ),
              NavigationDestination(
                icon: Icon(Icons.event_note_outlined),
                selectedIcon: Icon(Icons.event_note),
                label: 'My Bookings',
              ),
            ],
          ),
        );
      },
    );
  }

  void _switchUser(BuildContext context) {
    context.read<AuthCubit>().logout();
  }
}
