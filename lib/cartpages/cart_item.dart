import 'package:trendera/model_providers/product_model.dart';

class CartItem {
  final ProductModel product;
   int quantity;
  final String selectedSize;

  CartItem({
    required this.product,
    required this.quantity,
    required this.selectedSize,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'productId': product.id,
      'quantity': quantity,
      'selectedSize': selectedSize,
    };
  }

  // fromFirestore will be handled inside CartProvider since we need to fetch product separately
}
