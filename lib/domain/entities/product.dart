/// Domain entity – pure Dart, no framework dependency.
/// Represents a product in the catalog.
class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double dealerPrice;
  final double retailerPrice;
  final int moq;
  final String unit;
  final String category;
  final String barcode;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.dealerPrice,
    required this.retailerPrice,
    required this.moq,
    required this.unit,
    required this.category,
    required this.barcode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Product(id: $id, name: $name)';
}
