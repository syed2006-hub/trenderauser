import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PaymentSuccessBottomSheet extends StatefulWidget {
  final double totalPrice;
  final List<Map<String, dynamic>> items;

  const PaymentSuccessBottomSheet({
    super.key,
    required this.totalPrice,
    required this.items,
  });

  @override
  State<PaymentSuccessBottomSheet> createState() =>
      _PaymentSuccessBottomSheetState();
}

class _PaymentSuccessBottomSheetState extends State<PaymentSuccessBottomSheet>
    with TickerProviderStateMixin {
  late final AnimationController _lottieController;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  int countdown = 5;
  Timer? _timer;
  bool showtimer = false;
  @override
  void initState() {
    super.initState();
    showtimer = false;
    _lottieController = AnimationController(vsync: this);

    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _sheetController.animateTo(
            1.0, // expand to maxChildSize
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          setState(() {
            showtimer = true;
          });
          // Start countdown after expanding
          _startCountdown();
        });
      }
    });
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown == 1) {
        _timer?.cancel();
        _navigateToMyOrders();
      }
      setState(() {
        countdown--;
      });
    });
  }

  void _navigateToMyOrders() {
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacementNamed(
      '/my-orders',
    ); // or use Get.toNamed('/my-orders') if using GetX
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.4,
      maxChildSize: 1.0,
      minChildSize: 0.3,
      builder: (_, scrollController) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: scrollController,
              children: [
                if (showtimer)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        "Redirecting in 00:0$countdown",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                Center(
                  child: Lottie.asset(
                    "assets/lottie/payment_success.json",
                    height: 250,
                    repeat: false,
                    controller: _lottieController,
                    onLoaded: (composition) {
                      _lottieController.duration = composition.duration;
                      _lottieController.forward();
                    },
                  ),
                ), 
                const Center(
                  child: Text(
                    "Payment Successful!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),

                const Divider(height: 30),
                const Text(
                  "Order Details:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...widget.items.map(
                  (item) => ListTile(
                    leading: Image.network(item['imageUrl'], width: 40),
                    title: Text(item['title']),
                    subtitle: Row(
                      children: [
                        Text("Size: ${item['selectedSize']}"),
                        Spacer(),
                        Text("Qty: ${item['quantity']}"),
                      ],
                    ),
                    trailing: Text("₹${item['price']}"),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text("Total"),
                  trailing: Text(
                    "₹${widget.totalPrice.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
