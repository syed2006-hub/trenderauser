import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trendera/productpages/product_card.dart';
import 'package:trendera/model_providers/product_model.dart';

class AccessoriesPage extends StatelessWidget {
  const AccessoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final allProducts = Provider.of<ProductProvider>(context).allProducts;

    // Filter products where type is 'Accessories' (case-insensitive)
    final accessoriesProducts =
        allProducts.where((product) {
          return product.type.toLowerCase() == 'accesories';
        }).toList();

    if (accessoriesProducts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No products available.', style: TextStyle(fontSize: 16)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Padding(
          padding: EdgeInsets.only(left: 8.0,),
          child: Text(
            'Accessories Collection....',
            style:Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        ProductCard(productcardproducts: accessoriesProducts),
      ],
    );
  }
}
