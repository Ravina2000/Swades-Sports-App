import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../cubits/auth/auth_cubit.dart';
import '../cubits/bookings/bookings_cubit.dart';
import '../cubits/venue_slots/venue_slots_cubit.dart';
import '../cubits/venue_slots/venue_slots_state.dart';
import '../models/slot.dart';
import '../models/venue.dart';
import '../services/api_service.dart';
import '../widgets/async_state_view.dart';
import '../widgets/slot_grid.dart';

class VenueDetailScreen extends StatelessWidget {
  const VenueDetailScreen({super.key, required this.venue});

  final Venue venue;

  static void open(BuildContext context, Venue venue) {
    final authState = context.read<AuthCubit>().state;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => BlocProvider(
          create: (_) => VenueSlotsCubit(
            api: ctx.read<ApiService>(),
            venueId: venue.id,
            userId: authState.user?.id,
          )..loadSlots(),
          child: VenueDetailScreen(venue: venue),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(venue.name)),
      body: BlocBuilder<VenueSlotsCubit, VenueSlotsState>(
        builder: (context, state) {
          final selectedDate = state.selectedDate ?? DateTime.now();

          return RefreshIndicator(
            onRefresh: () => context.read<VenueSlotsCubit>().loadSlots(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _VenueHeader(venue: venue),
                const SizedBox(height: 20),
                _DatePickerRow(
                  date: selectedDate,
                  onPick: () => _pickDate(context, selectedDate),
                ),
                const SizedBox(height: 12),
                const SlotLegend(),
                const SizedBox(height: 16),
                AsyncStateView(
                  status: state.status,
                  data: state.slots,
                  errorMessage: state.errorMessage,
                  loadingMessage: 'Loading slots…',
                  onRetry: () => context.read<VenueSlotsCubit>().loadSlots(),
                  builder: (data) => SlotGrid(
                    slots: data.slots,
                    bookingHour: state.bookingHour,
                    onSlotTap: (slot) => _confirmAndBook(context, slot),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null && context.mounted) {
      context.read<VenueSlotsCubit>().selectDate(picked);
    }
  }

  Future<void> _confirmAndBook(BuildContext context, Slot slot) async {
    final slotsState = context.read<VenueSlotsCubit>().state;
    final date = slotsState.selectedDate ?? DateTime.now();
    final dateString = DateFormat('EEE, d MMM').format(date);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm booking'),
        content: Text(
          'Book ${venue.name}\n$dateString · ${slot.label}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Book'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final result = await context.read<VenueSlotsCubit>().bookSlot(
          startHour: slot.startHour,
        );

    if (!context.mounted) return;

    final userId = context.read<AuthCubit>().state.user?.id;
    if (userId != null) {
      context.read<BookingsCubit>().load(userId);
    }

    if (result.success) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: const Text('Booking confirmed!'),
          content: Text('Your slot ${slot.label} is reserved.'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done'),
            ),
          ],
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message ?? 'Booking failed'),
        backgroundColor: result.isSlotTaken
            ? Theme.of(context).colorScheme.error
            : null,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}

class _VenueHeader extends StatelessWidget {
  const _VenueHeader({required this.venue});

  final Venue venue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Chip(label: Text(venue.type.toUpperCase())),
            const SizedBox(width: 8),
            Icon(Icons.location_on_outlined,
                size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(venue.location),
          ],
        ),
        if (venue.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            venue.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _DatePickerRow extends StatelessWidget {
  const _DatePickerRow({required this.date, required this.onPick});

  final DateTime date;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('EEEE, d MMMM yyyy').format(date);
    return OutlinedButton.icon(
      onPressed: onPick,
      icon: const Icon(Icons.calendar_month),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
