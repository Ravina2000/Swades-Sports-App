import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/auth/auth_cubit.dart';
import '../cubits/bookings/bookings_cubit.dart';
import '../cubits/venues/venues_cubit.dart';
import '../models/app_user.dart';
class UserSelectScreen extends StatelessWidget {
  const UserSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.sports, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'QuickSlot',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Book badminton courts & turf grounds',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Select a user to continue',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              ...AppUser.options.map(
                (user) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _UserTile(
                    user: user,
                    onTap: () => _selectUser(context, user),
                  ),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  void _selectUser(BuildContext context, AppUser user) {
    context.read<AuthCubit>().selectUser(user);
    context.read<VenuesCubit>().load();
    context.read<BookingsCubit>().load(user.id);
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.onTap});

  final AppUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(user.name[0])),
        title: Text(user.name),
        subtitle: Text(user.id),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
