import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_order/core/constants/app_constants.dart';
import 'package:smart_order/core/theme/app_theme.dart';
import 'package:smart_order/data/repositories/product_repository_impl.dart';
import 'package:smart_order/data/services/product_service.dart';
import 'package:smart_order/domain/usecases/get_product_by_barcode_usecase.dart';
import 'package:smart_order/domain/usecases/get_products_usecase.dart';
import 'package:smart_order/presentation/providers/order_provider.dart';
import 'package:smart_order/presentation/screens/home_screen.dart';

void main() {
  runApp(const SmartOrderApp());
}

class SmartOrderApp extends StatelessWidget {
  const SmartOrderApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Dependency wiring (manual DI) ─────────────────────────────────
    final productService = ProductService();
    final productRepository = ProductRepositoryImpl(productService);
    final getProductsUseCase = GetProductsUseCase(productRepository);
    final getProductByBarcodeUseCase =
        GetProductByBarcodeUseCase(productRepository);

    return ChangeNotifierProvider(
      create: (_) => OrderProvider(
        getProducts: getProductsUseCase,
        getProductByBarcode: getProductByBarcodeUseCase,
      ),
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
