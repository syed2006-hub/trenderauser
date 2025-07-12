import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trendera/model_providers/favorite_provider.dart';
import 'package:trendera/productpages/product_card.dart';

class Favoriteitemspage extends StatefulWidget {
  const Favoriteitemspage({super.key});

  @override
  State<Favoriteitemspage> createState() => _FavoriteitemspageState();
}

class _FavoriteitemspageState extends State<Favoriteitemspage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;


  @override
  Widget build(BuildContext context) {
    super.build(context);
    final favoriteProducts = context.watch<FavoriteProducts>().favproductinfo;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // 🔺 Header
          SafeArea(
            child: Container(
              width: double.infinity,
              height: 70.w,
              color: Colors.black,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Favorite",
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.favorite_border, color: Colors.red),
                  ],
                ),
              ),
            ),
          ),

          // 🔺 Content
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child:
                  favoriteProducts.isEmpty
                      ? Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100.w),
                          child: const Text("No favorites yet"),
                        ),
                      )
                      : SingleChildScrollView(
                        child: ProductCard(
                          productcardproducts: favoriteProducts,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
