import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trendera/model_providers/cart_provider.dart';
import 'package:trendera/model_providers/favorite_provider.dart';
import 'package:trendera/model_providers/product_model.dart';
import 'package:trendera/singleproductdetails/productimagecursole.dart';

class SingleProdDetaitls extends StatefulWidget {
  final ProductModel singleproductdetails;
  const SingleProdDetaitls({super.key, required this.singleproductdetails});

  @override
  State<SingleProdDetaitls> createState() => _SingleProdDetaitlsState();
}

class _SingleProdDetaitlsState extends State<SingleProdDetaitls> {
  String selectedsize = '';

  void addToCart() {
    final sizes = widget.singleproductdetails.size;
    if (selectedsize.isNotEmpty || sizes.isEmpty) {
      Provider.of<CartProducts>(
        context,
        listen: false,
      ).addProduct(widget.singleproductdetails, selectedsize);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🛒 Added to cart'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠ Please select a size'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.singleproductdetails;
    final sizes = product.size;
    final isFavorite = Provider.of<FavoriteProducts>(
      context,
    ).isFavorite(product);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 400.h,
                width: double.infinity,
                child: ProductImageCarousel(imageUrls: product.imageUrl),
              ),
              Positioned(
                top: 40,
                left: 16,
                child: _iconButton(
                  icon: Icons.arrow_back_ios_new,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Positioned(
                top: 40,
                right: 16,
                child: _iconButton(
                  icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                  onPressed: () {
                    final favProvider = Provider.of<FavoriteProducts>(
                      context,
                      listen: false,
                    );
                    favProvider.toggleFavorite(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFavorite
                              ? 'Removed from favorites'
                              : 'Added to favorites',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ListView(
                children: [
                  Text(
                    product.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.company,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 10),
                  RatingBarIndicator(
                    rating: product.ratings,
                    itemBuilder:
                        (_, __) => const Icon(Icons.star, color: Colors.amber),
                    itemSize: 25,
                    itemCount: 5,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '₹${product.price}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (sizes.isNotEmpty) ...[
                    Text(
                      'Available Sizes:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children:
                          sizes.map((size) {
                            final isSelected = selectedsize == size;
                            return ChoiceChip(
                              label: Text(size),
                              selected: isSelected,
                              onSelected:
                                  (_) => setState(() => selectedsize = size),
                              selectedColor: Theme.of(context).colorScheme.secondary,
                              backgroundColor: Colors.grey.shade300,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                              checkmarkColor: Colors.white,
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Row(
                    children: [
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Spacer(),
                      Text("Only ${product.totalquantity} Stock's left"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.productDescription,
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 100), // Padding for FAB
                ],
              ),
            ),
          ),
        ],
      ),

      /// ✅ Floating Action Button for Add to Cart
      floatingActionButton: SizedBox(
        width: 350.w,
        child: FloatingActionButton.extended(
          onPressed: addToCart,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          icon: const Icon(Icons.shopping_cart),
          label: const Text('Add to Cart'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color color = Colors.white,
  }) {
    return ClipOval(
      child: Material(
        color: Colors.black38,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}
