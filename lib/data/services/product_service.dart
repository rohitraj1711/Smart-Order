import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:smart_order/core/constants/app_constants.dart';
import 'package:smart_order/data/models/product_model.dart';

/// Service that fetches raw product data from the local JSON asset.
///
/// In a production app this would call a REST API; swapping this service
/// is the only change needed to move from local data to remote.
class ProductService {
  /// Load and decode the products JSON asset.
  Future<List<ProductModel>> fetchProducts() async {

    final jsonString =
        await rootBundle.loadString(AppConstants.productsAssetPath);
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
