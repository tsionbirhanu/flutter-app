import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/app_providers.dart';
import '../widgets/app_state_view.dart';

class NotificationsScreen extends ConsumerWidget {
  NotificationsScreen({super.key});

  final DateFormat _dateFormat = DateFormat('MMM d, h:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationsProvider.notifier).load(),
        child: notifications.when(
          loading: () => const LoadingState(),
          error: (error, _) => ErrorState(
            message: '$error',
            onRetry: () => ref.read(notificationsProvider.notifier).load(),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const EmptyState(
                title: 'No notifications',
                message: 'Important account updates will appear here.',
                icon: Icons.notifications_none_rounded,
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  color: item.isRead
                      ? Theme.of(context).cardColor
                      : Theme.of(context).colorScheme.primaryContainer,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    leading: Icon(
                      item.isRead
                          ? Icons.notifications_none_rounded
                          : Icons.notifications_active_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('${item.body}\n${_dateFormat.format(item.createdAt)}'),
                    ),
                    isThreeLine: true,
                    onTap: () async {
                      await ref.read(notificationsProvider.notifier).markRead(item);
                    },
                  ),
                );
              },
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemCount: items.length,
            );
          },
        ),
      ),
    );
  }
}
