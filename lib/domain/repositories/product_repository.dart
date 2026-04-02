import 'package:smart_order/domain/entities/product.dart';

/// Abstract contract for fetching products – the domain layer depends on this
/// interface, not concrete implementations.
abstract class ProductRepository {
  /// Fetches all available products from the data source.
  Future<List<Product>> getProducts();

  /// Fetches a single product by its [barcode].
  Future<Product?> getProductByBarcode(String barcode);
}
