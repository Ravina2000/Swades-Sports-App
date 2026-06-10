import 'package:flutter/material.dart';

import '../models/slot.dart';

class SlotGrid extends StatelessWidget {
  const SlotGrid({
    super.key,
    required this.slots,
    required this.onSlotTap,
    this.bookingHour,
  });

  final List<Slot> slots;
  final ValueChanged<Slot> onSlotTap;
  final int? bookingHour;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.4,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isBooking = bookingHour == slot.startHour;
        return _SlotTile(
          slot: slot,
          isLoading: isBooking,
          onTap: slot.isAvailable && !isBooking ? () => onSlotTap(slot) : null,
        );
      },
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.slot,
    required this.onTap,
    this.isLoading = false,
  });

  final Slot slot;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (bg, fg, border, label) = _colors(theme, slot.status);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      slot.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(color: fg),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  (Color, Color, Color, String) _colors(ThemeData theme, SlotStatus status) {
    return switch (status) {
      SlotStatus.available => (
          theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
          theme.colorScheme.onPrimaryContainer,
          theme.colorScheme.primary.withValues(alpha: 0.3),
          'Available',
        ),
      SlotStatus.bookedByYou => (
          theme.colorScheme.secondaryContainer,
          theme.colorScheme.onSecondaryContainer,
          theme.colorScheme.secondary,
          'Your booking',
        ),
      SlotStatus.booked => (
          theme.colorScheme.surfaceContainerHighest,
          theme.colorScheme.onSurfaceVariant,
          theme.colorScheme.outlineVariant,
          'Booked',
        ),
    };
  }
}

class SlotLegend extends StatelessWidget {
  const SlotLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: const [
        _LegendItem(color: Colors.green, label: 'Available'),
        _LegendItem(color: Colors.grey, label: 'Booked'),
        _LegendItem(color: Colors.blue, label: 'Yours'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
