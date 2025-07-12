import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trendera/productpages/product_card.dart';
import 'package:trendera/model_providers/product_model.dart';

class TrouserPage extends StatelessWidget {
  const TrouserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final allProducts = Provider.of<ProductProvider>(context).allProducts;

    // Filter only trousers (case-insensitive)
    final trouserProducts = allProducts.where((product) {
      return product.type.toLowerCase() == 'trouser';
    }).toList();

    if (trouserProducts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No products available.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Padding(
          padding: EdgeInsets.only(left: 8.0, top: 12.0),
          child: Text(
            'Trouser Collections...',
            style:Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        ProductCard(productcardproducts: trouserProducts),
      ],
    );
  }
}
