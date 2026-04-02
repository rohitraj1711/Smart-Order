import 'package:flutter/material.dart';
import 'package:smart_order/core/utils/helpers.dart';

/// Sticky bottom bar showing the live grand total and Place Order button.
class OrderSummaryBar extends StatelessWidget {
  final double grandTotal;
  final int itemCount;
  final VoidCallback onPlaceOrder;

  const OrderSummaryBar({
    super.key,
    required this.grandTotal,
    required this.itemCount,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Total section
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$itemCount item${itemCount == 1 ? '' : 's'} in order',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(140),
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      Helpers.formatCurrency(grandTotal),
                      key: ValueKey(grandTotal),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Place Order button
            FilledButton.icon(
              onPressed: itemCount > 0 ? onPlaceOrder : null,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Place Order'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
