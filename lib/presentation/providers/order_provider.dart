import 'package:flutter/foundation.dart';
import 'package:smart_order/core/enums/customer_type.dart';
import 'package:smart_order/core/utils/helpers.dart';
import 'package:smart_order/domain/entities/order_item.dart';
import 'package:smart_order/domain/entities/product.dart';
import 'package:smart_order/domain/usecases/get_product_by_barcode_usecase.dart';
import 'package:smart_order/domain/usecases/get_products_usecase.dart';

/// Centralised state for the order flow.
///
/// Holds product list, order items, customer type, loading/error states.
/// All business logic lives here — the UI simply calls methods and reads state.
class OrderProvider extends ChangeNotifier {
  final GetProductsUseCase _getProducts;
  final GetProductByBarcodeUseCase _getProductByBarcode;

  OrderProvider({
    required GetProductsUseCase getProducts,
    required GetProductByBarcodeUseCase getProductByBarcode,
  })  : _getProducts = getProducts,
        _getProductByBarcode = getProductByBarcode;

  // ── State fields ──────────────────────────────────────────────────────
  List<Product> _products = [];
  List<Product> get products => _products;

  final Map<String, OrderItem> _orderItems = {};
  List<OrderItem> get orderItems => _orderItems.values.toList();

  /// Only items that have quantity > 0.
  List<OrderItem> get activeOrderItems =>
      _orderItems.values.where((item) => item.quantity > 0).toList();

  CustomerType _customerType = CustomerType.dealer;
  CustomerType get customerType => _customerType;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Last scanned barcode result message.
  String? _scanMessage;
  String? get scanMessage => _scanMessage;
  bool _scanSuccess = false;
  bool get scanSuccess => _scanSuccess;

  // ── Computed values ───────────────────────────────────────────────────
  double get grandTotal {
    double total = 0;
    for (final item in _orderItems.values) {
      total += item.lineTotal(_customerType);
    }
    return total;
  }

  int get totalItemsInCart =>
      _orderItems.values.fold(0, (sum, item) => sum + item.quantity);

  // ── Actions ───────────────────────────────────────────────────────────

  /// Load products from the repository.
  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _getProducts();
      // Initialise order items map
      for (final product in _products) {
        _orderItems.putIfAbsent(
          product.id,
          () => OrderItem(product: product),
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to load products. Please try again.';
      debugPrint('OrderProvider.loadProducts error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Switch between Dealer and Retailer.
  void setCustomerType(CustomerType type) {
    _customerType = type;
    notifyListeners();
  }

  /// Update quantity for a product. Clamps to 0 minimum.
  void updateQuantity(String productId, int quantity) {
    final item = _orderItems[productId];
    if (item == null) return;
    item.quantity = quantity < 0 ? 0 : quantity;
    notifyListeners();
  }

  /// Increment quantity by 1.
  void incrementQuantity(String productId) {
    final item = _orderItems[productId];
    if (item == null) return;
    item.quantity++;
    notifyListeners();
  }

  /// Decrement quantity by 1 (min 0).
  void decrementQuantity(String productId) {
    final item = _orderItems[productId];
    if (item == null) return;
    if (item.quantity > 0) item.quantity--;
    notifyListeners();
  }

  /// Validate all order items' MOQ. Returns list of error messages.
  List<String> validateOrder() {
    final errors = <String>[];
    for (final item in activeOrderItems) {
      if (!Helpers.isMoqSatisfied(item.quantity, item.product.moq)) {
        errors.add(
          Helpers.moqErrorMessage(
            item.product.name,
            item.product.moq,
            item.product.unit,
          ),
        );
      }
    }
    return errors;
  }

  /// Process a scanned barcode.
  Future<void> processScanResult(String barcode) async {
    // Step 1: Validate barcode format
    if (!Helpers.isBarcodeValid(barcode)) {
      _scanMessage =
          'Invalid barcode "$barcode" — last digit must be even.';
      _scanSuccess = false;
      notifyListeners();
      return;
    }

    // Step 2: Look up the product
    final product = await _getProductByBarcode(barcode);
    if (product == null) {
      _scanMessage = 'No product found for barcode "$barcode".';
      _scanSuccess = false;
      notifyListeners();
      return;
    }

    // Step 3: Add / increment item in order
    final item = _orderItems[product.id];
    if (item != null) {
      item.quantity++;
    } else {
      _orderItems[product.id] = OrderItem(product: product, quantity: 1);
    }

    _scanMessage = '✓ Added "${product.name}" to order.';
    _scanSuccess = true;
    notifyListeners();
  }

  /// Clear the scan message.
  void clearScanMessage() {
    _scanMessage = null;
    notifyListeners();
  }

  /// Reset entire order.
  void resetOrder() {
    for (final item in _orderItems.values) {
      item.quantity = 0;
    }
    notifyListeners();
  }
}
