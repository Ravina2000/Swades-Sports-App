import 'package:flutter/material.dart';

import '../utils/date_utils.dart';

class AsyncStateView<T> extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.status,
    required this.builder,
    this.data,
    this.errorMessage,
    this.isEmpty,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage,
    this.onRetry,
    this.loadingMessage,
  });

  final ViewStatus status;
  final T? data;
  final String? errorMessage;
  final Widget Function(T data) builder;
  final bool Function(T data)? isEmpty;
  final IconData emptyIcon;
  final String emptyTitle;
  final String? emptyMessage;
  final VoidCallback? onRetry;
  final String? loadingMessage;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      ViewStatus.initial || ViewStatus.loading => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (loadingMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  loadingMessage!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        ),
      ViewStatus.failure => _ErrorView(
          message: errorMessage ?? 'Something went wrong',
          onRetry: onRetry,
        ),
      ViewStatus.success => () {
          final value = data;
          if (value == null) {
            return _ErrorView(message: 'No data', onRetry: onRetry);
          }
          if (isEmpty != null && isEmpty!(value)) {
            return _EmptyView(
              icon: emptyIcon,
              title: emptyTitle,
              message: emptyMessage,
              onRetry: onRetry,
            );
          }
          return builder(value);
        }(),
    };
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({
    required this.icon,
    required this.title,
    this.message,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleMedium),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
