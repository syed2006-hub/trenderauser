import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trendera/homepage/main_image_slider.dart' show ImageCarousel;
import 'package:trendera/productpages/product_card.dart';
import 'package:trendera/homepage/topratedproducts/top_rating_product_card.dart';
import 'package:trendera/model_providers/product_model.dart';

class AllPage extends StatelessWidget {
  const AllPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final offerProducts = productProvider.offerProducts;
    final topRatingProducts = productProvider.topRatingProducts; 
    final hotDealProducts =
        productProvider.allProducts; // or hot deal list if any

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (offerProducts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Exclusive offers...',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Padding(padding: const EdgeInsets.all(12.0), child: ImageCarousel()),
        ],

        if (topRatingProducts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Top Ratings..',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          TopRatingProductcard(),
        ],

        if (hotDealProducts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Hot Deals..',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          ProductCard(productcardproducts: hotDealProducts),
        ],

        const SizedBox(height: 20),
      ],
    );
  }
}
