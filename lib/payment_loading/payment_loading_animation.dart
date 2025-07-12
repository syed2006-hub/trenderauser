// payment_loading_animation.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trendera/model_providers/cart_provider.dart';

enum PaymentStage { processing, success }

class PaymentAnimation extends StatefulWidget {
  const PaymentAnimation({super.key});

  @override
  State<PaymentAnimation> createState() => _PaymentAnimationState();
}

class _PaymentAnimationState extends State<PaymentAnimation> {
  PaymentStage stage = PaymentStage.processing;

  @override
  void initState() {
    super.initState();
    _startPayment();
  }

  Future<void> _startPayment() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 4));

    final cartProvider = Provider.of<CartProducts>(context, listen: false);
    final cartItems = cartProvider.cartItems;
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null && cartItems.isNotEmpty) {
      // Create a new order document under users/{userId}/orders/{orderId}
      final ordersCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('orders');

      final orderDoc = ordersCollection.doc(); // auto-generated ID

      await orderDoc.set({
        'timestamp': FieldValue.serverTimestamp(),
        'items':
            cartItems
                .map(
                  (item) => {
                    'id':item.product.id,
                    'title': item.product.title,
                    'imageUrl': item.product.imageUrl,
                    'price': item.product.price,
                    'quantity': item.quantity,
                    'selectedSize': item.selectedSize,
                  },
                )
                .toList(),
      });
    }

    // Clear the cart both locally and in Firestore
    await cartProvider.clearCart();

    if (!mounted) return;
    setState(() => stage = PaymentStage.success);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Black header with back-to-cart navigation
          Container(
            height: 130,
            color: Colors.black,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    "Payment",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),

          // White rounded container with animation
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 100),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 100),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child:
                        stage == PaymentStage.processing
                            ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Lottie.asset(
                                  'assets/lottie/payment_processing.json',
                                  width: 250,
                                ),
                                const SizedBox(height: 16),
                                const Text("Processing Payment..."),
                              ],
                            )
                            : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Lottie.asset(
                                  'assets/lottie/payment_success.json',
                                  width: 250,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Payment Successful!",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
