class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.nationalId,
    required this.balance,
  });

  final String id;
  final String name;
  final String phone;
  final String nationalId;
  final double balance;

  factory Customer.fromJson(Map<String, dynamic> json) {
    final source = json['customer'] is Map<String, dynamic>
        ? json['customer'] as Map<String, dynamic>
        : json;
    final wallet = json['wallet'] is Map<String, dynamic>
        ? json['wallet'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return Customer(
      id: '${source['id'] ?? source['_id'] ?? ''}',
      name: '${source['name'] ?? source['fullName'] ?? source['full_name'] ?? 'Customer'}',
      phone: '${source['phone'] ?? source['phoneNumber'] ?? source['phone_number'] ?? ''}',
      nationalId: '${source['nationalId'] ?? source['national_id'] ?? ''}',
      balance: _asDouble(source['balance'] ?? wallet['balance'] ?? json['balance']),
    );
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }
}
