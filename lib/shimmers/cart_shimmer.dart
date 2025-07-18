import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CartShimmer extends StatelessWidget {
  const CartShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(2, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Image placeholder
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Text + controls
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 140, height: 16, color: Colors.white),
                        const SizedBox(height: 6),
                        Container(width: 60, height: 14, color: Colors.white),
                        const SizedBox(height: 6),
                        Row(
                          children: List.generate(3, (i) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 6),
                        Container(width: 80, height: 14, color: Colors.white),
                      ],
                    ),
                  ),
                  // Delete + Qty
                  Column(
                    children: [
                      Container(width: 24, height: 24, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 40, height: 12, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
