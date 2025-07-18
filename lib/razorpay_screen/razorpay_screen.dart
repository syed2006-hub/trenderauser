import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:trendera/model_providers/cart_provider.dart';
import 'package:trendera/razorpay_screen/payment_success_sheet.dart';

class PaymentPage extends StatefulWidget {
  final double totalPrice;
  const PaymentPage({super.key, required this.totalPrice});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

enum PaymentMethod { upiApp, upiId, card }

class _PaymentPageState extends State<PaymentPage>
    with SingleTickerProviderStateMixin {
  PaymentMethod? _selectedMethod;
  String? _upiApp;
  String? _upiId;
  String? _cardNumber;
  String? _expiryDate;
  String? _cvv;

  bool _isProcessing = false;
  bool _paymentSuccess = false;

  final List<String> _upiApps = ['GPay', 'PhonePe', 'Paytm'];
  final _formKey = GlobalKey<FormState>();
  late final AnimationController _lottieController;
  bool _moveToCenter = false;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);

    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _moveToCenter = true;
        });
      }
    });
  }

  Future<void> _startPayment() async {
    if (_selectedMethod == null) {
      Get.snackbar(
        "No Payment Method Selected",
        "Please select a payment method to continue.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 3)); // Simulated delay

    final cartProvider = Provider.of<CartProducts>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    final clonedCartItems =
        cartProvider.cartItems.map((item) {
          return {
            'title': item.product.title,
            'imageUrl': item.product.imageUrl.first,
            'price': item.product.price,
            'quantity': item.quantity,
            'selectedSize': item.selectedSize,
          };
        }).toList();

    if (user != null && cartProvider.cartItems.isNotEmpty) {
      final userOrderRef =
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('orders')
              .doc();

      final globalOrderRef = FirebaseFirestore.instance
          .collection('orders') // ✅ Global collection
          .doc(userOrderRef.id); // Reuse same ID

      final orderData = {
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'paymentStatus': 'success',
        'paymentMethod': _selectedMethod.toString().split('.').last,
        'totalPrice': widget.totalPrice,
        'items':
            cartProvider.cartItems.map((item) {
              return {
                'id': item.product.id,
                'title': item.product.title,
                'imageUrl': item.product.imageUrl,
                'price': item.product.price,
                'quantity': item.quantity,
                'selectedSize': item.selectedSize,
              };
            }).toList(),
      };

      // Save to user-specific and global collection
      await userOrderRef.set(orderData);
      await globalOrderRef.set(orderData);

      await cartProvider.clearCart();
    }

    setState(() {
      _isProcessing = false;
      _paymentSuccess = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => PaymentSuccessBottomSheet(
            totalPrice: widget.totalPrice,
            items: clonedCartItems,
          ),
    );
  }

  Widget _buildUPIAppSelector() => DropdownButtonFormField<String>(
    value: _upiApp,
    items:
        _upiApps
            .map(
              (app) => DropdownMenuItem(
                value: app,
                child: Text(app, style: TextStyle(color: Colors.black)),
              ),
            )
            .toList(),
    onChanged: (val) => setState(() => _upiApp = val),
    validator: (val) => val == null ? 'Please select a UPI app' : null,
    decoration: InputDecoration(
      errorStyle: const TextStyle(fontSize: 10, height: 0.2, color: Colors.red),

      labelText: "Select UPI App",
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2),
      ),
    ),
    style: const TextStyle(fontSize: 14),
  );

  Widget _buildUPIIdField() => TextFormField(
    onChanged: (val) => _upiId = val,
    validator:
        (val) =>
            val == null || !val.contains('@') ? 'Enter valid UPI ID' : null,
    decoration: InputDecoration(
      errorStyle: const TextStyle(fontSize: 10, height: 0.2, color: Colors.red),

      labelText: "Enter Your UPI ID",
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2),
      ),
    ),
    style: const TextStyle(fontSize: 14),
  );

  Widget _buildCardFields() => Column(
    children: [
      TextFormField(
        keyboardType: TextInputType.number,
        onChanged: (val) => _cardNumber = val,
        validator:
            (val) =>
                val == null || val.length < 16 ? 'Invalid card number' : null,
        decoration: InputDecoration(
          errorStyle: const TextStyle(
            fontSize: 10,
            height: 0.2,
            color: Colors.red,
          ),

          labelText: "Card Number",
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 12,
          ),
          errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        style: const TextStyle(fontSize: 14),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.datetime,
              onChanged: (val) => _expiryDate = val,
              validator:
                  (val) =>
                      val == null || val.length < 5 ? 'Invalid expiry' : null,
              decoration: InputDecoration(
                errorStyle: const TextStyle(
                  fontSize: 10,
                  height: 0.2,
                  color: Colors.red,
                ),

                labelText: "Expiry (MM/YY)",
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              obscureText: true,
              keyboardType: TextInputType.number,
              onChanged: (val) => _cvv = val,
              validator:
                  (val) => val == null || val.length < 3 ? 'Invalid CVV' : null,
              decoration: InputDecoration(
                errorStyle: const TextStyle(
                  fontSize: 10,
                  height: 0.2,
                  color: Colors.red,
                ),

                labelText: "CVV",
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _buildPaymentOptions() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Select Payment Method',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      RadioListTile(
        activeColor: Theme.of(context).colorScheme.secondary,
        value: PaymentMethod.upiApp,
        groupValue: _selectedMethod,
        onChanged: (val) => setState(() => _selectedMethod = val),
        title: Row(
          children: [
            Text('UPI App'),
            SizedBox(width: 5),
            Image.asset("assets/images/gpay.png", width: 20),
            SizedBox(width: 5),
            Image.asset("assets/images/phonepay.png", width: 20),
            SizedBox(width: 5),
            Image.asset("assets/images/paytm.png", width: 20),
          ],
        ),
      ),
      RadioListTile(
        activeColor: Theme.of(context).colorScheme.secondary,
        value: PaymentMethod.upiId,
        groupValue: _selectedMethod,
        onChanged: (val) => setState(() => _selectedMethod = val),
        title: Row(
          children: [
            const Text('UPI ID'),
            SizedBox(width: 5),
            Image.asset("assets/images/bhimupi.png", width: 30),
          ],
        ),
      ),
      RadioListTile(
        value: PaymentMethod.card,
        activeColor: Theme.of(context).colorScheme.secondary,
        groupValue: _selectedMethod,
        onChanged: (val) => setState(() => _selectedMethod = val),
        title: Row(
          children: [
            Text(' Card'),
            SizedBox(width: 5),
            Image.asset("assets/images/visa.png", width: 25),
            SizedBox(width: 5),
            Image.asset("assets/images/creditcard.png", width: 25),
          ],
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.secondary,
      body: Column(
        children: [
          // 🔷 Header with Chevron Icon
          SafeArea(
            child: Container(
              width: double.infinity,
              height: 70,
              color: Theme.of(context).colorScheme.secondary,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 10,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back_ios_new_outlined),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Payment",
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        const FaIcon(Icons.payment_rounded),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔷 White Body
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child:
                  _isProcessing
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: SpinKitFadingCube(
                                color: Theme.of(context).colorScheme.secondary,
                                size: 80.0,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Processing Payment...",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      )
                      : _paymentSuccess
                      ? SizedBox()
                      : Form(
                        key: _formKey,
                        child: ListView(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Amount:',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    '₹${widget.totalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildPaymentOptions(),
                            const SizedBox(height: 12),
                            if (_selectedMethod == PaymentMethod.upiApp)
                              _buildUPIAppSelector(),
                            if (_selectedMethod == PaymentMethod.upiId)
                              _buildUPIIdField(),
                            if (_selectedMethod == PaymentMethod.card)
                              _buildCardFields(),
                            const SizedBox(height: 30),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Pay Now'),
                              onPressed: _startPayment,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 24,
                                ),
                                textStyle: const TextStyle(fontSize: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
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
