import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trendera/model_providers/product_model.dart';

class FilterProvider extends ChangeNotifier {
  List<ProductModel> _allProducts = [];
  List<ProductModel> get allProducts => _allProducts;

  bool isLoading = true;

  /// Fetches all products from Firestore and updates the provider
  Future<void> fetchAllProducts() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('products').get();
      _allProducts =
          snapshot.docs.map((doc) => ProductModel.fromMap(doc.data())).toList();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error fetching products: $e");
      isLoading = false;
      notifyListeners();
    }
  }

  /// Filter by main category (e.g. 'Mens', 'Womens')
  List<ProductModel> getProductsByMainCategory(String mainCategory) {
    if (mainCategory == 'All') return _allProducts;

    return _allProducts
        .where(
          (product) =>
              product.category.toLowerCase() == mainCategory.toLowerCase(),
        )
        .toList();
  }

  /// Filter by subcategory (e.g. 'Tshirts', 'Shirts')
  List<ProductModel> getProductsBySubCategory(String subCategory) {
    return _allProducts
        .where(
          (product) =>
              product.subcategory .toLowerCase() == subCategory.toLowerCase(),
        )
        .toList();
  }

  /// Filter by both category and subcategory
  List<ProductModel> getProductsByCategoryAndSubCategory(
    String mainCategory,
    String subCategory,
  ) {
    return _allProducts
        .where(
          (product) =>
              product.category.toLowerCase() == mainCategory.toLowerCase() &&
              product.subcategory.toLowerCase() == subCategory.toLowerCase(),
        )
        .toList();
  }
}
