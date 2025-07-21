import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trendera/category/subcategory_page.dart';
import 'package:trendera/model_providers/filter_product_provider.dart';
import 'package:trendera/model_providers/product_model.dart';

class CurrentPage extends StatelessWidget {
  final String selectedCategory;
  final String wentFrom;
  final List<String> listCategories;

  const CurrentPage({
    super.key,
    required this.selectedCategory,
    required this.wentFrom,
    required this.listCategories,
  });

  @override
  Widget build(BuildContext context) {
    final allProducts = Provider.of<FilterProvider>(context).allProducts;
    final selected = selectedCategory.toLowerCase().trim();
    final source = wentFrom.toLowerCase().trim();

    List<ProductModel> filteredProducts;

    // Step 1: Filter by main category (Mens, Womens, Kids, Acc)
    final fromCategoryProducts = allProducts.where((product) {
      final mainCat = product.category.toLowerCase().trim() ;
      return mainCat == source;
    }).toList();

    // Step 2: Now filter within that
    if (selected == 'all') {
      filteredProducts = fromCategoryProducts.where((product) {
        final subType = product.subcategory.toLowerCase().trim();
        return listCategories
            .map((c) => c.toLowerCase().trim())
            .contains(subType);
      }).toList();
    } else {
      filteredProducts = fromCategoryProducts.where((product) {
        final subCat = product.subcategory.toLowerCase().trim();
        return subCat == selected;
      }).toList();
    }

    // Debug logs
    print('Filtered by category: $selectedCategory');
    print('Went From: $wentFrom');
    for (var p in allProducts) {
      print('Product: ${p.title}, Category: ${p.category}, Type: ${p.category}');
    }
    print('Filtered products count: ${filteredProducts.length}');

    return SubCategoryPage(subCategoryProduct: filteredProducts);
  }
}
