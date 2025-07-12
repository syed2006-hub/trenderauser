// cartpricepage.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trendera/model_providers/cart_provider.dart';
import 'package:trendera/payment_loading/payment_loading_animation.dart';

class Cartpricepage extends StatefulWidget {
  const Cartpricepage({super.key});

  @override
  State<Cartpricepage> createState() => _CartpricepageState();
}

class _CartpricepageState extends State<Cartpricepage> {
  @override
  void initState() {
    super.initState();

    // Set navigation bar color (bottom bar)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black, // ✅ Bottom nav bar color
        systemNavigationBarIconBrightness: Brightness.light, // Icon color
      ),
    );
  }

  @override
  void dispose() {
    // Optional: Reset to default when you leave the page
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent, // ✅ Bottom nav bar color
        systemNavigationBarIconBrightness:
            Brightness.light, // Icon color), // Or your app default style
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProducts>(context);
    final cartItems = cartProvider.cartItems;

    if (cartItems.isEmpty) {
      return const Scaffold(body: Center(child: Text("Your cart is empty")));
    }

    final totalPrice = cartItems.fold<double>(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );

    final totalQuantity = cartItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    const discount = 5.0;
    const shippingCost = 6.0;
    final subtotal = totalPrice - discount + shippingCost;

    final formatCurrency = NumberFormat.simpleCurrency(name: 'INR');

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Header
          Container(
            height: 480.h,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(300)),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackButton(color: Colors.white),
                      Text(
                        "Price Summary",
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(Icons.receipt_long, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 480.h,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(300)),
              ),
            ),
          ),
          // Order Summary
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                ],
              ),
            ),
          ),

          // Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: SizedBox(
                width: 320,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Place Order"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentAnimation(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
}
