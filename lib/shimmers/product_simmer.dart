import 'dart:async';
import 'package:flutter/material.dart';

class ProductSimmer extends StatefulWidget {
  const ProductSimmer({super.key});

  @override
  State<ProductSimmer> createState() => _ProductShimmerState();
}

class _ProductShimmerState extends State<ProductSimmer> {
  final List<String> loadingTexts = [
    "⏳ Hang tight",
    "🔍 Finding better products ",
    "🎯 Matching your style...",
    "🛍️ Loading trends you'll love...",
  ];

  int _currentTextIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1250), (_) {
      setState(() {
        _currentTextIndex = (_currentTextIndex + 1) % loadingTexts.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Text(
        loadingTexts[_currentTextIndex],
        key: ValueKey(_currentTextIndex),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
