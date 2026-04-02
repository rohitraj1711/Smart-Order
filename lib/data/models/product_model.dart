import 'package:smart_order/domain/entities/product.dart';

/// Data-layer model with JSON serialization / deserialization.
/// Extends the domain [Product] entity so the presentation layer
/// only depends on the entity, never on the model directly.
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrl,
    required super.dealerPrice,
    required super.retailerPrice,
    required super.moq,
    required super.unit,
    required super.category,
    required super.barcode,
  });

  /// Factory constructor from a decoded JSON map.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      dealerPrice: (json['dealerPrice'] as num).toDouble(),
      retailerPrice: (json['retailerPrice'] as num).toDouble(),
      moq: json['moq'] as int,
      unit: json['unit'] as String,
      category: json['category'] as String,
      barcode: json['barcode'] as String,
    );
  }

  /// Serialise back to JSON (useful for caching, testing, etc.).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'dealerPrice': dealerPrice,
      'retailerPrice': retailerPrice,
      'moq': moq,
      'unit': unit,
      'category': category,
      'barcode': barcode,
    };
  }
}
