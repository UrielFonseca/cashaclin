import 'customer_model.dart';

List<Customer> mockCustomers = [
  Customer(
    id: "1",
    name: "Juan Pérez",
    email: "juan@email.com",
    phone: "555-1234",
    totalOrders: 5,
    totalSpent: 320.50,
    joinDate: DateTime(2024, 1, 10),
  ),
  Customer(
    id: "2",
    name: "Ana López",
    email: "ana@email.com",
    phone: "555-5678",
    totalOrders: 3,
    totalSpent: 210.00,
    joinDate: DateTime(2024, 2, 5),
  ),
  Customer(
    id: "3",
    name: "Carlos Ramírez",
    email: "carlos@email.com",
    phone: "555-9999",
    totalOrders: 8,
    totalSpent: 540.75,
    joinDate: DateTime(2024, 3, 2),
  ),
];
