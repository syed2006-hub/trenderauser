import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignupPage extends StatefulWidget {
  final bool cameFromFlashPage;
  final String? prefilledEmail;
  final bool isGoogleEmailLocked;

  const SignupPage({
    super.key,
    this.cameFromFlashPage = false,
    this.prefilledEmail,
    required this.isGoogleEmailLocked,
  });

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final shopAddressController = TextEditingController();
  final shopAreaController = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledEmail != null) {
      emailController.text = widget.prefilledEmail!;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    shopAddressController.dispose();
    shopAreaController.dispose();
    super.dispose();
  }

  Future<void> completeGoogleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) {
      Get.snackbar("Signup Error", "Google Sign-In session expired.");
      return;
    }

    setState(() => _isLoading = true);

    final uid = currentUser.uid;
    final email = currentUser.email!;
    final username = usernameController.text.trim();
    final shopAddress = shopAddressController.text.trim();
    final shopArea = shopAreaController.text.trim();

    try {
      // Check if already registered as user
      final userExists =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (userExists.docs.isNotEmpty) {
        Get.snackbar(
          "Signup Denied",
          "❌ This email is already registered as a user.",
          backgroundColor: Colors.redAccent.withOpacity(0.7),
          colorText: Colors.white,
        );
        await FirebaseAuth.instance.signOut();
        return;
      }

      // Check if already registered as shop
      final shopDoc =
          await FirebaseFirestore.instance.collection('shops').doc(uid).get();
      if (shopDoc.exists) {
        Get.snackbar("Already Registered", "This shop is already signed up.");
        return;
      }

      // Save display name
      await currentUser.updateDisplayName(username);

      final shopData = {
        'uid': uid,
        'shopId': uid,
        'shopName': username,
        'shopEmail': email,
        'shopAddress': shopAddress,
        'shopArea': shopArea,
        'role': 'shop',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('shops')
          .doc(uid)
          .set(shopData, SetOptions(merge: true));

      Get.snackbar(
        "Signup Complete",
        "Welcome, $username!",
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Sign-up failed. Please try again.",
        backgroundColor: Colors.black,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            // Heading at top
            Padding(
              padding: const EdgeInsets.only(top: 60, left: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Create\nYour Shop Account',
                  style: TextStyle(
                    fontSize: 36.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
            ),

            // Animated white container
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : 0,
              top: MediaQuery.of(context).viewInsets.bottom > 0 ? 10 : null,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 650.h,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          buildField(
                            controller: usernameController,
                            hintText: 'Shop Name',
                            validatorMsg: 'Enter shop name',
                          ),
                          const SizedBox(height: 20),
                          buildField(
                            controller: emailController,
                            hintText: 'Email (Google)',
                            validatorMsg: 'Enter email',
                            enabled: !widget.isGoogleEmailLocked,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          buildField(
                            controller: shopAddressController,
                            hintText: 'Shop Address',
                            validatorMsg: 'Enter shop address',
                          ),
                          const SizedBox(height: 20),
                          buildField(
                            controller: shopAreaController,
                            hintText: 'Shop Area',
                            validatorMsg: 'Enter shop area',
                          ),
                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading ? (){} : completeGoogleSignup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        backgroundColor: Colors.black,
                                      )
                                      : const Text(
                                        'SIGN UP',
                                        style: TextStyle(color: Colors.white),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildField({
    required String hintText,
    required String validatorMsg,
    required TextEditingController controller,
    bool isPassword = false,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: isPassword ? _obscureText : false,
      keyboardType: keyboardType,
      cursorColor: Colors.black,
      validator:
          (value) =>
              validatorMsg.isNotEmpty && value!.trim().isEmpty
                  ? validatorMsg
                  : null,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black54),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),

        hintText: hintText,
        filled: true,
        fillColor: enabled ? const Color(0xFFF2F2F2) : Colors.grey.shade300,
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscureText = !_obscureText);
                  },
                )
                : null,
      ),
    );
  }
}
