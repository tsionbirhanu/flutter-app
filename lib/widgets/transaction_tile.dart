import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  TransactionTile({super.key, required this.transaction});

  final WalletTransaction transaction;
  final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  final NumberFormat _currency = NumberFormat.currency(symbol: 'ETB ');

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final color = isCredit ? const Color(0xFF15803D) : const Color(0xFFB91C1C);
    final label = switch (transaction.type) {
      TransactionType.deposit => 'Deposit',
      TransactionType.withdrawal => 'Withdrawal',
      TransactionType.transfer => 'Transfer',
      TransactionType.unknown => 'Transaction',
    };

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            color: color,
          ),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          '${transaction.description.isEmpty ? label : transaction.description}\n${_dateFormat.format(transaction.createdAt)}',
        ),
        isThreeLine: true,
        trailing: Text(
          '${isCredit ? '+' : '-'}${_currency.format(transaction.amount.abs())}',
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
