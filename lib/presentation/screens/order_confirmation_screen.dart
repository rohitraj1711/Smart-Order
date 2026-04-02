import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_order/core/enums/customer_type.dart';
import 'package:smart_order/core/theme/app_theme.dart';
import 'package:smart_order/core/utils/helpers.dart';
import 'package:smart_order/presentation/providers/order_provider.dart';

/// Order confirmation screen showing a summary before final submission.
class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Order Summary')),
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          final items = provider.activeOrderItems;
          final customerType = provider.customerType;
          final isDealer = customerType == CustomerType.dealer;

          return Column(
            children: [
              // Customer type badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                color: isDealer
                    ? AppTheme.dealerColor.withAlpha(20)
                    : AppTheme.retailerColor.withAlpha(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isDealer ? Icons.store : Icons.shopping_bag_outlined,
                      color:
                          isDealer ? AppTheme.dealerColor : AppTheme.retailerColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${customerType.label} Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDealer
                            ? AppTheme.dealerColor
                            : AppTheme.retailerColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Item list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final price = isDealer
                        ? item.product.dealerPrice
                        : item.product.retailerPrice;
                    final total = item.lineTotal(customerType);

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Number badge
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.quantity} ${item.product.unit} × ${Helpers.formatCurrency(price)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withAlpha(140),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          Helpers.formatCurrency(total),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Grand total & confirm
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      offset: const Offset(0, -2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      // Totals breakdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal',
                              style: theme.textTheme.bodyMedium),
                          Text(Helpers.formatCurrency(provider.grandTotal),
                              style: theme.textTheme.bodyMedium),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Grand Total',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            Helpers.formatCurrency(provider.grandTotal),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _confirmOrder(context, provider),
                          icon: const Icon(Icons.check),
                          label: const Text('Confirm Order'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmOrder(BuildContext context, OrderProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.celebration, color: Colors.amber, size: 48),
        title: const Text('Order Placed!'),
        content: Text(
          'Your ${provider.customerType.label.toLowerCase()} order of '
          '${Helpers.formatCurrency(provider.grandTotal)} has been '
          'placed successfully.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              provider.resetOrder();
              Navigator.of(context)
                ..pop() // close dialog
                ..pop(); // go back to home
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
