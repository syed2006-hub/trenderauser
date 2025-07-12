import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trendera/main.dart';

class LoginPage extends StatefulWidget {
  final bool isShop;
  const LoginPage({super.key, required this.isShop});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      // Sign out from any previous session
      await _auth.signOut();
      await _googleSignIn.signOut();

      // Start Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user == null || user.email == null) {
        throw Exception("User authentication failed");
      }

      // ✅ Role Conflict Check
      final oppositeCollection = widget.isShop ? 'users' : 'shops';
      final oppositeDoc =
          await _firestore.collection(oppositeCollection).doc(user.uid).get();

      if (oppositeDoc.exists) {
        // ❌ Conflict — user exists with opposite role
        await _auth.signOut();
        await _googleSignIn.signOut();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'This email is already registered as a ${widget.isShop ? 'user' : 'shop'}. '
              'Please use the correct login.',
            ),
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }

      // ✅ Continue with correct role flow
      final correctCollection = widget.isShop ? 'shops' : 'users';
      final correctDoc =
          await _firestore.collection(correctCollection).doc(user.uid).get();

      if (!correctDoc.exists) {
        // Create document if not already present
        await _firestore.collection(correctCollection).doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? '',
          'photoURL': user.photoURL ?? '',
          'role': widget.isShop ? 'shop' : 'user',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        // Just update last login timestamp
        await _firestore.collection(correctCollection).doc(user.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }

      // Navigate to AuthGate
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthGate()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is FirebaseAuthException
                ? _getFirebaseError(e)
                : 'Sign-in failed. Please try again.',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'Email already linked with another method';
      case 'network-request-failed':
        return 'Network error. Check your connection';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                // Main Page Content
                _buildLoginCard(
                  logoAsset: "assets/images/logo_wo_bg.png",
                  googleAsset: "assets/images/google_logo.png",
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                ),

                // Loading Overlay
                if (_isLoading)
                  Positioned.fill(
                    child: Stack(
                      children: [
                        const Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard({
    required String logoAsset,
    required String googleAsset,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(logoAsset, height: 120, fit: BoxFit.cover),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: textColor,
            ),
            height: 200.h,
            width: 350.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: backgroundColor,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _signInWithGoogle(),
                  child: Image.asset(googleAsset, width: 250),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(color: textColor, fontSize: 14),
              children: [
                const TextSpan(text: "By continuing you agree to Trendera's "),
                TextSpan(
                  text: "Terms & Conditions",
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
                const TextSpan(text: " and "),
                TextSpan(
                  text: "Privacy Policy",
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
                const TextSpan(text: "."),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
