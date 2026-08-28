class WalletNotification {
  const WalletNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  WalletNotification copyWith({bool? isRead}) {
    return WalletNotification(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  factory WalletNotification.fromJson(Map<String, dynamic> json) {
    return WalletNotification(
      id: '${json['id'] ?? json['_id'] ?? ''}',
      title: '${json['title'] ?? 'Wallet update'}',
      body: '${json['body'] ?? json['message'] ?? ''}',
      createdAt: DateTime.tryParse(
            '${json['createdAt'] ?? json['created_at'] ?? json['date'] ?? ''}',
          ) ??
          DateTime.now(),
      isRead: json['read'] == true ||
          json['isRead'] == true ||
          json['is_read'] == true,
    );
  }
}
