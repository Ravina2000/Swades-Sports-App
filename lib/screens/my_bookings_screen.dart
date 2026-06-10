import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/auth/auth_cubit.dart';
import '../cubits/bookings/bookings_cubit.dart';
import '../cubits/bookings/bookings_state.dart';
import '../models/booking.dart';
import '../widgets/async_state_view.dart';
import '../widgets/booking_card.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingsCubit, BookingsState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () {
            final userId = context.read<AuthCubit>().state.user!.id;
            return context.read<BookingsCubit>().load(userId);
          },
          child: AsyncStateView<List<Booking>>(
            status: state.status,
            data: state.bookings,
            errorMessage: state.errorMessage,
            loadingMessage: 'Loading your bookings…',
            emptyIcon: Icons.event_busy_outlined,
            emptyTitle: 'No bookings yet',
            emptyMessage: 'Book a slot from the Venues tab.',
            isEmpty: (bookings) => bookings.isEmpty,
            onRetry: () {
              final userId = context.read<AuthCubit>().state.user!.id;
              context.read<BookingsCubit>().load(userId);
            },
            builder: (bookings) => ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return BookingCard(
                  booking: booking,
                  isCancelling: state.cancellingId == booking.id,
                  onCancel: state.cancellingId != null
                      ? null
                      : () => _confirmCancel(context, booking),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmCancel(BuildContext context, Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: Text(
          'Cancel ${booking.venueName} on ${booking.date} (${booking.timeLabel})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Cancel booking'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final userId = context.read<AuthCubit>().state.user!.id;
    final success = await context.read<BookingsCubit>().cancel(
          userId: userId,
          bookingId: booking.id,
        );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Booking cancelled' : 'Could not cancel booking',
        ),
      ),
    );
  }
}
