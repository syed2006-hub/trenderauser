import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trendera/model_providers/product_model.dart';
import 'package:trendera/singleproductdetails/single_prod_detaitls.dart';

class TopRatingProductcard extends StatefulWidget {
  const TopRatingProductcard({super.key});

  @override
  State<TopRatingProductcard> createState() => _TopRatingProductcardState();
}

class _TopRatingProductcardState extends State<TopRatingProductcard> {
  final ScrollController _scrollController = ScrollController();

  static const double _itemWidth = 230;
  static const double _itemHeight = 270;
  static const double _spacing = 8;
  static const double _maxScale = 1.0;
  static const double _minScale = 0.8;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final double offset = (_itemWidth + _spacing * 2) * .92;
      _scrollController.jumpTo(offset);
    });
  }

  double _calculateScale(double itemCenter, double screenCenter) {
    const double maxDistance = 200;
    final double distance = (screenCenter - itemCenter).abs();

    if (distance == 0) return _maxScale;
    if (distance >= maxDistance) return _minScale;

    final double scaleFactor = 1 - (distance / maxDistance);
    return _minScale + (_maxScale - _minScale) * scaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final allProducts = Provider.of<ProductProvider>(context).allProducts;

    final filteredProducts =
        allProducts.where((product) => product.ratings >= 4).toList();

    return SizedBox(
      height: _itemHeight + 60,
      child: NotificationListener<ScrollNotification>(
        onNotification: (_) {
          setState(() {});
          return false;
        },
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: (screenWidth - _itemWidth) / 2,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            final scrollOffset = _scrollController.offset;
            final itemX = index * (_itemWidth + _spacing * 2);
            final itemCenter = itemX + _itemWidth / 2 - scrollOffset;
            final screenCenter = screenWidth / 2;

            final scale = _calculateScale(itemCenter, screenCenter);

            return AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              SingleProdDetaitls(singleproductdetails: product),
                    ),
                  );
                },
                child: SizedBox(
                  width: _itemWidth,
                  height: _itemHeight,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      Center(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.network(
                                product.imageUrl.first,
                                fit: BoxFit.cover,
                                width: _itemWidth,
                                height: _itemHeight,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      width: _itemWidth,
                                      height: double.infinity,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      width: _itemWidth,
                                      height: double.infinity,
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Text(
                                '₹${product.price}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            Positioned(
                              bottom: 40,
                              right: 10,
                              child: RatingBarIndicator(
                                rating: product.ratings,
                                itemBuilder:
                                    (_, __) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                itemCount: 5,
                                itemSize: 24,
                                direction: Axis.horizontal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
