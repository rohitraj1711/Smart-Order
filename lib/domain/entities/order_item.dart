import 'package:smart_order/core/enums/customer_type.dart';
import 'package:smart_order/domain/entities/product.dart';

/// Represents a single order line item.
class OrderItem {
  final Product product;
  int quantity;

  OrderItem({required this.product, this.quantity = 0});

  /// Compute line total for a given [customerType].
  double lineTotal(CustomerType customerType) {
    final price = customerType == CustomerType.dealer
        ? product.dealerPrice
        : product.retailerPrice;
    return price * quantity;
  }

  /// Whether the current quantity satisfies the MOQ.
  bool get isMoqSatisfied => quantity >= product.moq;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItem && other.product.id == product.id;

  @override
  int get hashCode => product.id.hashCode;
}
