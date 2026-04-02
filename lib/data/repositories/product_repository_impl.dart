import 'package:smart_order/data/services/product_service.dart';
import 'package:smart_order/domain/entities/product.dart';
import 'package:smart_order/domain/repositories/product_repository.dart';

/// Concrete implementation of [ProductRepository].
///
/// Delegates data fetching to [ProductService] and converts
/// data-layer models to domain entities automatically (they
/// already extend [Product]).
class ProductRepositoryImpl implements ProductRepository {
  final ProductService _service;

  /// Cached product list to avoid repeated asset reads.
  List<Product>? _cache;

  ProductRepositoryImpl(this._service);

  @override
  Future<List<Product>> getProducts() async {
    if (_cache != null) return _cache!;
    _cache = await _service.fetchProducts();
    return _cache!;
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    final products = await getProducts();
    try {
      return products.firstWhere((p) => p.barcode == barcode);
    } catch (_) {
      return null;
    }
  }

  /// Clears the internal cache so the next fetch goes to the source.
  void invalidateCache() => _cache = null;
}
