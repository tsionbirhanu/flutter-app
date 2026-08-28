import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../widgets/app_state_view.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_history_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(meProvider);
    ref.invalidate(recentTransactionsProvider);
    await Future.wait([
      ref.read(meProvider.future),
      ref.read(recentTransactionsProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider);
    final transactions = ref.watch(recentTransactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            me.when(
              loading: () => const SizedBox(height: 190, child: LoadingState()),
              error: (error, _) => SizedBox(
                height: 190,
                child: ErrorState(
                  message: '$error',
                  onRetry: () => ref.invalidate(meProvider),
                ),
              ),
              data: (customer) => BalanceCard(balance: customer.balance),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Recent Transactions',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const TransactionHistoryScreen(),
                      ),
                    );
                  },
                  child: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            transactions.when(
              loading: () => const SizedBox(height: 220, child: LoadingState()),
              error: (error, _) => SizedBox(
                height: 220,
                child: ErrorState(
                  message: '$error',
                  onRetry: () => ref.invalidate(recentTransactionsProvider),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const SizedBox(
                    height: 220,
                    child: EmptyState(
                      title: 'No transactions yet',
                      message: 'Your latest deposits and withdrawals will appear here.',
                      icon: Icons.receipt_long_outlined,
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final transaction in items) TransactionTile(transaction: transaction),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
