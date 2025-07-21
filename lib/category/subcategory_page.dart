import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trendera/productpages/product_card.dart';
import 'package:trendera/model_providers/product_model.dart';

class SubCategoryPage extends StatelessWidget {
  final List<ProductModel> subCategoryProduct;
  const SubCategoryPage({super.key, required this.subCategoryProduct});

  @override
  Widget build(BuildContext context) {
    if (subCategoryProduct.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(height: 250,),
            FaIcon(FontAwesomeIcons.boxOpen, size: 35),
            SizedBox(height: 20),
            Text('Sorry No Available Products', style: TextStyle(fontSize: 13)),
          ],
        ),
      );
    }

    return ProductCard(productcardproducts: subCategoryProduct);
  }
}
