import 'package:flutter_test/flutter_test.dart';
import 'package:smart_order/core/utils/helpers.dart';
import 'package:smart_order/core/enums/customer_type.dart';

void main() {
  group('Helpers - Barcode Validation', () {
    test('returns true for barcode ending with even digit', () {
      expect(Helpers.isBarcodeValid('8901234567890'), isTrue); // ends in 0
      expect(Helpers.isBarcodeValid('1234567892'), isTrue); // ends in 2
      expect(Helpers.isBarcodeValid('9999994'), isTrue); // ends in 4
      expect(Helpers.isBarcodeValid('1111116'), isTrue); // ends in 6
      expect(Helpers.isBarcodeValid('2222228'), isTrue); // ends in 8
    });

    test('returns false for barcode ending with odd digit', () {
      expect(Helpers.isBarcodeValid('8901234567891'), isFalse); // ends in 1
      expect(Helpers.isBarcodeValid('1234567893'), isFalse); // ends in 3
      expect(Helpers.isBarcodeValid('9999995'), isFalse); // ends in 5
      expect(Helpers.isBarcodeValid('1111117'), isFalse); // ends in 7
      expect(Helpers.isBarcodeValid('2222229'), isFalse); // ends in 9
    });

    test('returns false for null or empty barcode', () {
      expect(Helpers.isBarcodeValid(null), isFalse);
      expect(Helpers.isBarcodeValid(''), isFalse);
    });

    test('returns false for barcode ending with non-digit', () {
      expect(Helpers.isBarcodeValid('ABCDEFG'), isFalse);
      expect(Helpers.isBarcodeValid('12345X'), isFalse);
    });
  });

  group('Helpers - MOQ Validation', () {
    test('returns true when quantity meets MOQ', () {
      expect(Helpers.isMoqSatisfied(10, 10), isTrue);
      expect(Helpers.isMoqSatisfied(15, 10), isTrue);
    });

    test('returns false when quantity is below MOQ', () {
      expect(Helpers.isMoqSatisfied(5, 10), isFalse);
      expect(Helpers.isMoqSatisfied(0, 1), isFalse);
    });
  });

  group('Helpers - Price Calculation', () {
    test('returns dealer price for dealer customer type', () {
      final price = Helpers.unitPrice(
        dealerPrice: 100.0,
        retailerPrice: 150.0,
        customerType: CustomerType.dealer,
      );
      expect(price, 100.0);
    });

    test('returns retailer price for retailer customer type', () {
      final price = Helpers.unitPrice(
        dealerPrice: 100.0,
        retailerPrice: 150.0,
        customerType: CustomerType.retailer,
      );
      expect(price, 150.0);
    });

    test('calculates correct line total', () {
      final total = Helpers.lineTotal(
        dealerPrice: 100.0,
        retailerPrice: 150.0,
        customerType: CustomerType.dealer,
        quantity: 5,
      );
      expect(total, 500.0);
    });
  });

  group('Helpers - Currency Formatting', () {
    test('formats currency correctly', () {
      expect(Helpers.formatCurrency(1050.0), '₹1,050.00');
      expect(Helpers.formatCurrency(0.0), '₹0.00');
      expect(Helpers.formatCurrency(99999.99), '₹99,999.99');
    });
  });
}
