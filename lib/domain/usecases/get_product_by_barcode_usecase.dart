import 'package:smart_order/domain/entities/product.dart';
import 'package:smart_order/domain/repositories/product_repository.dart';

/// Use case: Find a product by its barcode string.
class GetProductByBarcodeUseCase {
  final ProductRepository _repository;

  GetProductByBarcodeUseCase(this._repository);

  Future<Product?> call(String barcode) =>
      _repository.getProductByBarcode(barcode);
}
