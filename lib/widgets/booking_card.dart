import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/booking.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    required this.onCancel,
    this.isCancelling = false,
  });

  final Booking booking;
  final VoidCallback? onCancel;
  final bool isCancelling;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat('EEE, d MMM yyyy').format(
      DateTime.parse(booking.date),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.venueName,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (isCancelling)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close),
                    tooltip: 'Cancel booking',
                    color: theme.colorScheme.error,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.calendar_today_outlined, text: dateLabel),
            const SizedBox(height: 4),
            _InfoRow(icon: Icons.schedule, text: booking.timeLabel),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
