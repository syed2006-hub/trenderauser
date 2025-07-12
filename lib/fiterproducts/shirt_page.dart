import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trendera/productpages/product_card.dart';
import 'package:trendera/model_providers/product_model.dart'; 
class ShirtPage extends StatelessWidget {
  const ShirtPage({super.key});

  @override
  Widget build(BuildContext context) {
    final allProducts = Provider.of<ProductProvider>(context).allProducts;

    // Filter products where type == 'shirt' (case-insensitive)
    final shirtProducts = allProducts.where((product) {
      return product.type.toLowerCase() == 'shirt';
    }).toList();

    if (shirtProducts.isEmpty) {
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
            'Shirt Collection...',
            style:Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        ProductCard(productcardproducts: shirtProducts),
      ],
    );
  }
}
