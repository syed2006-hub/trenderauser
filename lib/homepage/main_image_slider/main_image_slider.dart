import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:trendera/model_providers/product_model.dart';
import 'package:trendera/singleproductdetails/single_prod_detaitls.dart';

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({super.key});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final offerProducts = Provider.of<ProductProvider>(context).offerProducts;

    return Column(
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: 200,
            autoPlay: true,
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
            autoPlayInterval: const Duration(seconds: 8),
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
          items:
              offerProducts.map((product) {
                return _CarouselItem(product: product);
              }).toList(),
        ),

        const SizedBox(height: 10),

        /// SMOOTH DOT INDICATOR
        AnimatedSmoothIndicator(
          activeIndex: _currentIndex,
          count: offerProducts.length,
          effect: ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 8,
            spacing: 6,
            activeDotColor: Colors.black,
            dotColor: Colors.blueGrey,
          ),
          onDotClicked: (index) {
            _carouselController.animateToPage(index);
          },
        ),
      ],
    );
  }
}

class _CarouselItem extends StatelessWidget {
  final ProductModel product;

  const _CarouselItem({required this.product});

  @override
  Widget build(BuildContext context) {
    final model = product.carouselModel ?? 'ModelA';

    switch (model) {
      case 'ModelB':
        return _ModelB(product: product);
      case 'ModelC':
        return _ModelC(product: product);
      default:
        return _ModelA(product: product);
    }
  }
}

// ----------------------- Model A -----------------------
class _ModelA extends StatefulWidget {
  final ProductModel product;
  const _ModelA({required this.product});

  @override
  State<_ModelA> createState() => _ModelAState();
}

class _ModelAState extends State<_ModelA> {
  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
    final offerImage =
        (widget.product.offerImage?.isNotEmpty ?? false)
            ? widget.product.offerImage!
            : widget.product.imageUrl;
    final offerText = widget.product.offerDescription;
    final price = widget.product.price.toStringAsFixed(0);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => SingleProdDetaitls(singleproductdetails: widget.product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(colors: [Colors.grey, Colors.black]),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offerText ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "BUY FOR",
                    style: TextStyle(color: Colors.white, fontSize: 26),
                  ),
                  Row(
                    children: [
                      Text(
                        '₹$price',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  if (!_isLoaded)
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.white,
                      ),
                    ),
                  Positioned.fill(
                    child: Image.network(
                      offerImage.toString(),
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() => _isLoaded = true);
                            }
                          });
                          return child;
                        }
                        return const SizedBox();
                      },
                      errorBuilder:
                          (_, __, ___) => const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white,
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------- Model B -----------------------
class _ModelB extends StatelessWidget {
  final ProductModel product;
  const _ModelB({required this.product});

  @override
  Widget build(BuildContext context) {
    final offerImage =
        (product.offerImage?.isNotEmpty ?? false)
            ? product.offerImage
            : product.imageUrl;
    final offerText = product.offerDescription;
    final price = product.price.toStringAsFixed(0);

    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SingleProdDetaitls(singleproductdetails: product),
            ),
          ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black,
        ),

        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              offerImage.toString(),
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.white),
                  ),
            ),
            Container(color: Colors.black.withOpacity(0.5)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offerText ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      'ONLY ₹$price',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------- Model C -----------------------
class _ModelC extends StatelessWidget {
  final ProductModel product;
  const _ModelC({required this.product});

  @override
  Widget build(BuildContext context) {
    final offerImage =
        (product.offerImage?.isNotEmpty ?? false)
            ? product.offerImage
            : product.imageUrl;
    final offerText = product.offerDescription;
    final price = product.price.toStringAsFixed(0);

    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SingleProdDetaitls(singleproductdetails: product),
            ),
          ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              offerImage.toString(),
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.white),
                  ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black,
            ),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  offerText ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  '₹$price',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
