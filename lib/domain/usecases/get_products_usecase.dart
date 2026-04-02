import 'package:smart_order/domain/entities/product.dart';
import 'package:smart_order/domain/repositories/product_repository.dart';

/// Use case: Fetch all products from the repository.
class GetProductsUseCase {
  final ProductRepository _repository;

  GetProductsUseCase(this._repository);

  Future<List<Product>> call() => _repository.getProducts();
}
