import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trendera/model_providers/cart_provider.dart'; 
import 'package:trendera/razorpay_screen/razorpay_screen.dart';
import 'package:trendera/shimmers/cart_shimmer.dart';
import 'package:trendera/singleproductdetails/single_prod_detaitls.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final formatCurrency = NumberFormat.simpleCurrency(locale: 'en_IN');
  bool startanimation = false;
  bool isLoading = true;
  void showPricingSummaryBottomSheet(
    BuildContext context,
    double totalPrice,
    int totalQuantity,
  ) {
    const discount = 5.0;
    const shippingCost = 6.0;
    final subtotal = totalPrice - discount + shippingCost;
    final formatCurrency = NumberFormat.simpleCurrency(name: 'INR');

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Text(
                "Price Summary",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              _summaryRow(
                context,
                'Sub Total ($totalQuantity items)',
                formatCurrency.format(totalPrice),
              ),
              _summaryRow(
                context,
                'Shipping',
                shippingCost == 0
                    ? 'Free'
                    : formatCurrency.format(shippingCost),
              ),
              _summaryRow(
                context,
                'Discounts',
                formatCurrency.format(discount),
              ),
              const Divider(),
              _summaryRow(
                context,
                'Total',
                '',
                trailingWidget: Text(
                  formatCurrency.format(subtotal),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.payment),
                  label: const Text("Continue to Payment"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentPage(totalPrice: totalPrice),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);

      await Provider.of<CartProducts>(
        context,
        listen: false,
      ).fetchCartItemsFromFirestore();

      setState(() => isLoading = false);

      // Delay to allow the list to render before triggering animation
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            startanimation = true;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProducts>();
    final items = cartProvider.cartItems;
    final totalPrice = items.fold<double>(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );

    final totalQuantity = items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    double screenwidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Column(
        children: [
          // Top Bar
          SafeArea(
            child: Container(
              height: 70.w,
              alignment: Alignment.center,
              color: Theme.of(context).colorScheme.secondary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "My Cart",
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.shopping_cart),
                ],
              ),
            ),
          ),

          // Cart Body
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child:
                  items.isEmpty
                      ? Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100.w),
                          child: const Text("Your cart is empty"),
                        ),
                      )
                      : isLoading
                      ? CartShimmer()
                      : Stack(
                        children: [
                          // Cart List
                          Padding(
                            padding: const EdgeInsets.only(bottom: 80),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                final product = item.product;

                                return AnimatedContainer(
                                  duration: Duration(
                                    milliseconds: 300 + (index * 100),
                                  ),
                                  transform: Matrix4.translationValues(
                                    startanimation ? 0 : screenwidth,
                                    0,
                                    0,
                                  ),
                                  curve: Curves.easeOut,
                                  child: Card(
                                    color: Colors.grey[90],
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Product Image
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) => SingleProdDetaitls(
                                                        singleproductdetails:
                                                            product,
                                                      ),
                                                ),
                                              );
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                product.imageUrl.first,
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return Container(
                                                    width: 60,
                                                    height: 60,
                                                    color: Colors.grey[200],
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      color: Colors.grey[600],
                                                      size: 30,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          // Product Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.title,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                ),
                                                const SizedBox(height: 4),
                                                item.selectedSize.isEmpty
                                                    ? const SizedBox.shrink()
                                                    : Text(
                                                      "Size: ${item.selectedSize}",
                                                    ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons
                                                            .remove_circle_outline,
                                                      ),
                                                      color: Colors.black,
                                                      onPressed: () {
                                                        cartProvider
                                                            .decreaseQuantity(
                                                              item,
                                                            );
                                                      },
                                                    ),
                                                    Text('${item.quantity}'),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons
                                                            .add_circle_outline,
                                                      ),
                                                      color: Colors.black,
                                                      onPressed: () {
                                                        cartProvider
                                                            .increaseQuantity(
                                                              item,
                                                            );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  formatCurrency.format(
                                                    product.price *
                                                        item.quantity,
                                                  ),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Delete / Qty Display
                                          Column(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                ),
                                                onPressed: () {
                                                  cartProvider.removeItem(item);
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Item removed from cart',
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              Text(
                                                "Qty: ${item.quantity}",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Checkout Button
                          Positioned(
                            bottom: 100,
                            right: 20,
                            child: FloatingActionButton.extended(
                              heroTag: Clip.none,
                              onPressed: () {
                                showPricingSummaryBottomSheet(
                                  context,
                                  totalPrice,
                                  totalQuantity,
                                );
                              },
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              icon: const Icon(Icons.payment),
                              label: const Text('Checkout'),
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _summaryRow(
  BuildContext context,
  String title,
  String value, {
  Widget? trailingWidget,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        trailingWidget ??
            Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    ),
  );
}
