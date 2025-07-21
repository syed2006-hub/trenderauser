import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeShimmer extends StatefulWidget {
  const HomeShimmer({super.key});

  @override
  State<HomeShimmer> createState() => _HomeShimmerState();
}

class _HomeShimmerState extends State<HomeShimmer> {
  final List<String> loadingTexts = [
    "⏳ Hang tight ",
    "🔍 Finding products ",
    "🎯 Matching your style...",
    "🛍️ Loading trends",
    "❤️ you'll love...",
  ];

  int _currentTextIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ✨ Shimmer UI in background
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: 6,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder:
                          (_, __) => Column(
                            children: [
                              Container(
                                height: 65,
                                width: 65,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 10,
                                width: 40,
                                color: Colors.white,
                              ),
                            ],
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        padding: const EdgeInsets.only(top: 10, bottom: 20),
                        itemCount: 6,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.68,
                            ),
                        itemBuilder:
                            (_, __) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: screenWidth / 2 - 32,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 12,
                                  width: 100,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 10,
                                  width: 60,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🖤 Centered Loading Text
            Positioned(
              top: MediaQuery.of(context).size.height * 0.5,
              child: AnimatedSwitcher(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
