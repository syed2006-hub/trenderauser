import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trendera/productpages/product_card.dart';
import 'package:trendera/model_providers/product_model.dart';


class TracksPage extends StatelessWidget {
  const TracksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final allProducts = Provider.of<ProductProvider>(context).allProducts;

    // Filter products where type == 'track' (case-insensitive)
    final trackProducts = allProducts.where((product) {
      return product.type.toLowerCase() == 'track';
    }).toList();

    if (trackProducts.isEmpty) {
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
            'Track Collections...',
            style:Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        ProductCard(productcardproducts: trackProducts),
      ],
    );
  }
}
