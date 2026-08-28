import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import '../providers/app_providers.dart';
import '../widgets/app_state_view.dart';
import '../widgets/transaction_tile.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen> {
  static const _pageSize = 20;

  final _scrollController = ScrollController();
  final List<WalletTransaction> _items = [];
  var _page = 1;
  var _isLoading = true;
  var _isLoadingMore = false;
  var _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
    _scrollController.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (_scrollController.position.pixels >
            _scrollController.position.maxScrollExtent - 240 &&
        !_isLoadingMore &&
        _hasMore) {
      _load();
    }
  }

  Future<void> _load({bool reset = false}) async {
    setState(() {
      if (reset) {
        _page = 1;
        _items.clear();
        _hasMore = true;
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
      _error = null;
    });

    try {
      final list = await ref
          .read(apiServiceProvider)
          .getList('/me/transactions?page=$_page&limit=$_pageSize');
      final parsed = list
          .whereType<Map<String, dynamic>>()
          .map(WalletTransaction.fromJson)
          .toList();
      if (!mounted) return;
      setState(() {
        _items.addAll(parsed);
        _page += 1;
        _hasMore = parsed.length == _pageSize;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: RefreshIndicator(
        onRefresh: () => _load(reset: true),
        child: Builder(
          builder: (context) {
            if (_isLoading) return const LoadingState();
            if (_error != null && _items.isEmpty) {
              return ErrorState(message: _error!, onRetry: () => _load(reset: true));
            }
            if (_items.isEmpty) {
              return const EmptyState(
                title: 'No transactions found',
                message: 'Your complete wallet activity will show up here.',
                icon: Icons.history_rounded,
              );
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: _items.length + 1,
              itemBuilder: (context, index) {
                if (index < _items.length) {
                  return TransactionTile(transaction: _items[index]);
                }
                if (_isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (_error != null) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: OutlinedButton(
                      onPressed: _load,
                      child: const Text('Try loading more again'),
                    ),
                  );
                }
                if (!_hasMore) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'You are all caught up',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton(
                    onPressed: _load,
                    child: const Text('Load more'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
