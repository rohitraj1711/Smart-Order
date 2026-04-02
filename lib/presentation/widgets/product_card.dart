import 'package:flutter/material.dart';
import 'package:smart_order/core/enums/customer_type.dart';
import 'package:smart_order/core/theme/app_theme.dart';
import 'package:smart_order/core/utils/helpers.dart';
import 'package:smart_order/domain/entities/order_item.dart';

/// A card representing a single product in the order list.
class ProductCard extends StatelessWidget {
  final OrderItem orderItem;
  final CustomerType customerType;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<int> onQuantityChanged;

  const ProductCard({
    super.key,
    required this.orderItem,
    required this.customerType,
    required this.onIncrement,
    required this.onDecrement,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final product = orderItem.product;
    final theme = Theme.of(context);
    final unitPrice = customerType == CustomerType.dealer
        ? product.dealerPrice
        : product.retailerPrice;
    final lineTotal = orderItem.lineTotal(customerType);
    final moqMet = orderItem.quantity == 0 || orderItem.isMoqSatisfied;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    product.imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.image_not_supported_outlined,
                          color: theme.colorScheme.onSurface.withAlpha(100)),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Name, category, price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _PriceBadge(
                            label: customerType.label,
                            price: unitPrice,
                            color: customerType == CustomerType.dealer
                                ? AppTheme.dealerColor
                                : AppTheme.retailerColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'per ${product.unit.replaceAll(RegExp(r"s$"), "")}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(140),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Quantity & Total row ────────────────────────────────
            Row(
              children: [
                // MOQ chip
                Tooltip(
                  message: 'Minimum Order Quantity',
                  child: Chip(
                    avatar: Icon(
                      moqMet ? Icons.check_circle : Icons.warning_amber,
                      size: 16,
                      color: moqMet ? AppTheme.successColor : AppTheme.errorColor,
                    ),
                    label: Text(
                      'MOQ: ${product.moq} ${product.unit}',
                      style: TextStyle(
                        fontSize: 12,
                        color: moqMet ? AppTheme.successColor : AppTheme.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: moqMet
                        ? AppTheme.successColor.withAlpha(20)
                        : AppTheme.errorColor.withAlpha(20),
                    side: BorderSide(
                      color: moqMet
                          ? AppTheme.successColor.withAlpha(60)
                          : AppTheme.errorColor.withAlpha(60),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const Spacer(),
                // Quantity stepper
                _QuantityStepper(
                  quantity: orderItem.quantity,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                ),
              ],
            ),

            // ── Line total ──────────────────────────────────────────
            if (orderItem.quantity > 0) ...[
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${orderItem.quantity} × ${Helpers.formatCurrency(unitPrice)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(160),
                    ),
                  ),
                  Text(
                    Helpers.formatCurrency(lineTotal),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Private sub-widgets ─────────────────────────────────────────────────

class _PriceBadge extends StatelessWidget {
  final String label;
  final double price;
  final Color color;

  const _PriceBadge({
    required this.label,
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        Helpers.formatCurrency(price),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove,
            onPressed: quantity > 0 ? onDecrement : null,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 40),
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _StepperButton(icon: Icons.add, onPressed: onIncrement),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _StepperButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: onPressed != null
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withAlpha(60),
          ),
        ),
      ),
    );
  }
}
