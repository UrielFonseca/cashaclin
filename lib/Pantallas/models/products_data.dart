import 'product_model.dart';

List<Product> mockProducts = [
  Product(
    id: "1",
    name: "Detergente Líquido",
    sku: "DET-001",
    category: "Lavandería",
    image: "https://m.media-amazon.com/images/I/71YyP9f1UfL._AC_SL1500_.jpg",
    description: "Limpieza profunda para todo tipo de ropa con aroma fresco.",
    price: 150.0,
    stock: 25,
  ),
  Product(
    id: "2",
    name: "Limpiador de Pisos",
    sku: "PIS-002",
    category: "Pisos",
    image: "https://m.media-amazon.com/images/I/61H4hT+0SXL._AC_SL1000_.jpg",
    description: "Elimina grasa y mugre dejando un brillo duradero.",
    price: 85.0,
    stock: 12,
  ),
  Product(
    id: "3",
    name: "Desinfectante Spray",
    sku: "DES-003",
    category: "Desinfección",
    image: "https://m.media-amazon.com/images/I/61-m68kXpPL._AC_SL1500_.jpg",
    description: "Mata el 99.9% de virus y bacterias en superficies.",
    price: 95.0,
    stock: 8,
  ),
];
