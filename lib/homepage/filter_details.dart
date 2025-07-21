import 'package:provider/provider.dart';
import 'package:trendera/category/category_page.dart';
import 'package:trendera/model_providers/filter_product_provider.dart';

// Categories for Men
List<String> mensCategory = [
  'All',
  'Shirt',
  'Tshirt',
  'Trouser',
  'Hoody',
  'Tracks',
];

// Categories for Women
List<String> womensCategory = [
  'All',
  'Top',
  'Dress',
  'Kurti',
  'Leggings',
  'Saree',
  'Tshirt',
  'Shirt',
  'Hoody',
];

// Categories for Kids
List<String> kidsCategory = [
  'All',
  'Shirt',
  'Frock',
  'Tshirt',
  'Shorts',
  'Hoody',
  'Tracks',
];

// Categories for Accessories
List<String> accessoriesCategory = [
  'All',
  'Watches',
  'Belts',
  'Bags',
  'Caps',
  'Sunglasses',
];
final filters = [
  [
    'assets/images/mens.png',
    'Mens',
    Consumer<FilterProvider>(
      builder: (context, provider, _) {
        return CategoryPage(
          listproducts: provider.getProductsByMainCategory('Mens'),
          listcategories: mensCategory,
          wentFrom: 'Mens',
        );
      },
    ),
  ],
  [
    'assets/images/womens.webp',
    'Womens',
    Consumer<FilterProvider>(
      builder: (context, provider, _) {
        return CategoryPage(
          listproducts: provider.getProductsByMainCategory('Womens'),
          listcategories: womensCategory,
          wentFrom: 'Womens',
        );
      },
    ),
  ],
  [
    'assets/images/kids.png',
    'Kids',
    Consumer<FilterProvider>(
      builder: (context, provider, _) {
        return CategoryPage(
          listproducts: provider.getProductsByMainCategory('Kids'),
          listcategories: kidsCategory,
          wentFrom: 'Kids',
        );
      },
    ),
  ],
  [
    'assets/images/accessories.png',
    'Accessories',
    Consumer<FilterProvider>(
      builder: (context, provider, _) {
        return CategoryPage(
          listproducts: provider.getProductsByMainCategory('Accessories'),
          listcategories: accessoriesCategory,
          wentFrom: 'Accessories',
        );
      },
    ),
  ],
];
