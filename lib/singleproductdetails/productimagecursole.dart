import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart'; 

class ProductImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const ProductImageCarousel({super.key, required this.imageUrls});

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (_pageController.hasClients && widget.imageUrls.isNotEmpty) {
        int nextPage = (_currentIndex + 1) % widget.imageUrls.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          ClipRRect(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return Image.network(
                  widget.imageUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.broken_image)),
                );
              },
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: DotsIndicator(
                dotsCount: widget.imageUrls.length,
                position: _currentIndex.toDouble(),
                decorator: DotsDecorator(
                  activeColor: Colors.black,
                  size: const Size.square(6.0),
                  activeSize: const Size(16.0, 6.0),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
