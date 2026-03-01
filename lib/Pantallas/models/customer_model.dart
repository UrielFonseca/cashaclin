class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int totalOrders;
  final double totalSpent;
  final DateTime joinDate;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.totalOrders,
    required this.totalSpent,
    required this.joinDate,
  });
}