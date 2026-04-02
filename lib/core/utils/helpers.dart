import 'package:smart_order/core/enums/customer_type.dart';

/// Pure helper functions – no dependency on Flutter or any state.
class Helpers {
  Helpers._();

  // ── Barcode Validation ────────────────────────────────────────────────
  /// Returns `true` when the last digit of [barcode] is **even** (0,2,4,6,8).
  /// Returns `false` for empty/null barcodes or when last digit is odd.
  static bool isBarcodeValid(String? barcode) {
    if (barcode == null || barcode.isEmpty) return false;
    final lastChar = barcode[barcode.length - 1];
    final lastDigit = int.tryParse(lastChar);
    if (lastDigit == null) return false;
    return lastDigit.isEven;
  }

  // ── MOQ Validation ────────────────────────────────────────────────────
  /// Returns `true` when [quantity] meets or exceeds [moq].
  static bool isMoqSatisfied(int quantity, int moq) => quantity >= moq;

  /// Human-readable MOQ error message.
  static String moqErrorMessage(String productName, int moq, String unit) =>
      'Minimum order for "$productName" is $moq $unit';

  // ── Price Calculation ─────────────────────────────────────────────────
  /// Returns the unit price for a product based on customer type.
  static double unitPrice({
    required double dealerPrice,
    required double retailerPrice,
    required CustomerType customerType,
  }) {
    return customerType == CustomerType.dealer ? dealerPrice : retailerPrice;
  }

  /// Returns the line total for a single product given [quantity].
  static double lineTotal({
    required double dealerPrice,
    required double retailerPrice,
    required CustomerType customerType,
    required int quantity,
  }) {
    return unitPrice(
          dealerPrice: dealerPrice,
          retailerPrice: retailerPrice,
          customerType: customerType,
        ) *
        quantity;
  }

  // ── Formatting ────────────────────────────────────────────────────────
  /// Formats a double as currency string (e.g. ₹1,050.00).
  static String formatCurrency(double amount, {String symbol = '₹'}) {
    // Simple Indian-style formatting
    final parts = amount.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    // Add commas
    final buffer = StringBuffer();
    final digits = intPart.split('').reversed.toList();
    for (var i = 0; i < digits.length; i++) {
      if (i == 3 || (i > 3 && (i - 1) % 2 == 0)) {
        buffer.write(',');
      }
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString().split('').reversed.join();
    return '$symbol$formatted.$decPart';
  }
}
