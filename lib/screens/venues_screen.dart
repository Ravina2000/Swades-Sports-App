import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/venues/venues_cubit.dart';
import '../cubits/venues/venues_state.dart';
import '../widgets/async_state_view.dart';
import '../widgets/venue_card.dart';
import 'venue_detail_screen.dart';

class VenuesScreen extends StatelessWidget {
  const VenuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VenuesCubit, VenuesState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () => context.read<VenuesCubit>().load(),
          child: AsyncStateView(
            status: state.status,
            data: state.venues,
            errorMessage: state.errorMessage,
            loadingMessage: 'Loading venues…',
            emptyTitle: 'No venues found',
            emptyMessage: 'Pull down to refresh.',
            isEmpty: (venues) => venues.isEmpty,
            onRetry: () => context.read<VenuesCubit>().load(),
            builder: (venues) => ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: venues.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final venue = venues[index];
                return VenueCard(
                  venue: venue,
                  onTap: () => VenueDetailScreen.open(context, venue),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
