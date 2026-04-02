import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_order/core/constants/app_constants.dart';
import 'package:smart_order/core/enums/customer_type.dart';
import 'package:smart_order/presentation/providers/order_provider.dart';
import 'package:smart_order/presentation/screens/barcode_scanner_screen.dart';
import 'package:smart_order/presentation/screens/order_confirmation_screen.dart';
import 'package:smart_order/presentation/widgets/customer_type_selector.dart';
import 'package:smart_order/presentation/widgets/empty_state_widget.dart';
import 'package:smart_order/presentation/widgets/order_summary_bar.dart';
import 'package:smart_order/presentation/widgets/product_card.dart';

/// Main screen – product listing with order capabilities.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load products on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadProducts();
    });
  }

  void _onPlaceOrder() {
    final provider = context.read<OrderProvider>();
    final errors = provider.validateOrder();

    if (errors.isNotEmpty) {
      // Show MOQ validation errors
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded,
              color: Colors.orange, size: 40),
          title: const Text('MOQ Not Met'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: errors
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: Text(e,
                                style: const TextStyle(fontSize: 14)),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK, I\'ll fix it'),
            ),
          ],
        ),
      );
      return;
    }

    if (provider.activeOrderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add items to your order first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navigate to order confirmation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OrderConfirmationScreen(),
      ),
    );
  }

  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 24),
            SizedBox(width: 8),
            Text(AppConstants.appName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Barcode',
            onPressed: _openScanner,
          ),
          Consumer<OrderProvider>(
            builder: (_, provider, __) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'reset') {
                    provider.resetOrder();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order reset.')),
                    );
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'reset',
                    child: Row(
                      children: [
                        Icon(Icons.restart_alt, size: 20),
                        SizedBox(width: 8),
                        Text('Reset Order'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          // ── Loading ────────────────────────────────────────────────
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading products…'),
                ],
              ),
            );
          }

          // ── Error ─────────────────────────────────────────────────
          if (provider.errorMessage != null) {
            return EmptyStateWidget(
              icon: Icons.cloud_off,
              title: 'Something went wrong',
              subtitle: provider.errorMessage!,
              actionLabel: 'Retry',
              onAction: provider.loadProducts,
            );
          }

          // ── Empty ─────────────────────────────────────────────────
          if (provider.products.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.inventory_2_outlined,
              title: 'No Products',
              subtitle: 'There are no products available at the moment.',
            );
          }

          // ── Product list ──────────────────────────────────────────
          return Column(
            children: [
              // Customer type toggle
              CustomerTypeSelector(
                selected: provider.customerType,
                onChanged: provider.setCustomerType,
              ),

              // Info banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: (provider.customerType ==
                              _dealerType
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFE65100))
                      .withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (provider.customerType == _dealerType
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFE65100))
                        .withAlpha(40),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: provider.customerType == _dealerType
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFE65100),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.customerType == _dealerType
                            ? 'Showing dealer prices — bulk discounts applied'
                            : 'Showing retailer prices — standard rates',
                        style: TextStyle(
                          fontSize: 13,
                          color: provider.customerType == _dealerType
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Products
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: provider.orderItems.length,
                  itemBuilder: (context, index) {
                    final item = provider.orderItems[index];
                    return ProductCard(
                      orderItem: item,
                      customerType: provider.customerType,
                      onIncrement: () =>
                          provider.incrementQuantity(item.product.id),
                      onDecrement: () =>
                          provider.decrementQuantity(item.product.id),
                      onQuantityChanged: (qty) =>
                          provider.updateQuantity(item.product.id, qty),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<OrderProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading || provider.products.isEmpty) {
            return const SizedBox.shrink();
          }
          return OrderSummaryBar(
            grandTotal: provider.grandTotal,
            itemCount: provider.totalItemsInCart,
            onPlaceOrder: _onPlaceOrder,
          );
        },
      ),
    );
  }
}

// ignore: library_private_types_in_public_api
const _dealerType = CustomerType.dealer;
