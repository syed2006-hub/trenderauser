import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trendera/productpages/product_card.dart';
import 'package:trendera/model_providers/product_model.dart';

class SearchResultPage extends StatefulWidget {
  final String query;
  final List<ProductModel>? similarProducts;
  final List<ProductModel>? relatedProducts;

  const SearchResultPage({
    super.key,
    required this.query,
    this.similarProducts,
    this.relatedProducts,
  });

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.similarProducts == null && widget.relatedProducts == null) {
      Future.microtask(() {
        final provider = Provider.of<ProductProvider>(context, listen: false);
        provider.searchProducts(widget.query);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final similar =
        widget.similarProducts ??
        Provider.of<ProductProvider>(context).searchResults;

    // ❌ Remove similar products from related list
    final related =
        (widget.relatedProducts ?? []).where((relProd) {
          return !similar.any((simProd) => simProd.id == relProd.id);
        }).toList();


    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SafeArea(
            child: Container(
              height: 70.w,
              color: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back_ios_new_outlined),
                  ),
                  Spacer(),
                  Text(
                    "Search Results ",
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  const Icon(Icons.search, color: Colors.red),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child:
                  (similar.isEmpty && related.isEmpty)
                      ? Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100.w),
                          child: const Text(
                            "No matched products",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                      : SingleChildScrollView(
                        padding: EdgeInsets.all(10.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (similar.isNotEmpty) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 20.w,
                                  horizontal: 5.w,
                                ),
                                child: Text(
                                  "Similar Products....",
                                  style:
                                      Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                ),
                              ),
                              ProductCard(productcardproducts: similar),
                            ],
                            if (related.isNotEmpty) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 1.w,
                                  horizontal: 5.w,
                                ),
                                child: Text(
                                  "Related Products",
                                  style:
                                      Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                ),
                              ),
                              ProductCard(productcardproducts: related),
                            ],
                          ],
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
