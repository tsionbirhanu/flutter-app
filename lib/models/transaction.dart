enum TransactionType { deposit, withdrawal, transfer, unknown }

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.createdAt,
    required this.description,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final DateTime createdAt;
  final String description;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    final rawType =
        '${json['type'] ?? json['transactionType'] ?? json['transaction_type'] ?? ''}'
            .toLowerCase();

    return WalletTransaction(
      id: '${json['id'] ?? json['_id'] ?? ''}',
      type: switch (rawType) {
        'deposit' || 'credit' => TransactionType.deposit,
        'withdrawal' || 'withdraw' || 'debit' => TransactionType.withdrawal,
        'transfer' => TransactionType.transfer,
        _ => TransactionType.unknown,
      },
      amount: _asDouble(json['amount']),
      createdAt: DateTime.tryParse(
            '${json['createdAt'] ?? json['created_at'] ?? json['date'] ?? ''}',
          ) ??
          DateTime.now(),
      description: '${json['description'] ?? json['memo'] ?? rawType}',
    );
  }

  bool get isCredit => type == TransactionType.deposit;

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }
}
