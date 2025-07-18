import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trendera/ecommerce.dart';

import 'package:trendera/firebase_options.dart';
import 'package:trendera/sign_in_page/login_screen/signin_page.dart';
import 'package:trendera/model_providers/cart_provider.dart';
import 'package:trendera/model_providers/favorite_provider.dart';
import 'package:trendera/model_providers/location_provider.dart';
import 'package:trendera/model_providers/order_provider.dart';
import 'package:trendera/model_providers/product_model.dart';
import 'package:trendera/model_providers/user_model.dart';
import 'package:trendera/myorder_page/my_order_page.dart';
import 'package:trendera/shimmers/home_shimmer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoriteProducts()),
        ChangeNotifierProvider(create: (_) => CartProducts()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(412, 915),
        minTextAdapt: true,
        splitScreenMode: true,
        builder:
            (_, __) => GetMaterialApp(
              routes: {
                '/my-orders': (context) => const MyOrderPage(),
                // add other named routes here
              },
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                useMaterial3: true,
                inputDecorationTheme: const InputDecorationTheme(
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                colorScheme: const ColorScheme.light(
                  secondary: Color.fromARGB(255, 80, 138, 161),
                  primary: Color(0xFFFFFFFF),
                ),
                textTheme: GoogleFonts.aDLaMDisplayTextTheme().copyWith(
                  titleMedium: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                  titleSmall: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                  headlineLarge: const TextStyle(
                    fontSize: 22,
                    color: Colors.red,
                  ),
                  headlineMedium: const TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                  headlineSmall: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
                appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
                iconTheme: const IconThemeData(size: 24, color: Colors.black),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6394A8),
                    textStyle: const TextStyle(color: Colors.black),
                  ),
                ),
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor: Colors.black,
                  selectionColor: Colors.blue.shade300,
                  selectionHandleColor: Colors.blue,
                ),
              ),
              home: const AuthGate(),
            ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<String?> _getUserRole(String uid) async {
    // Check in 'users' collection
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists && userDoc.data()?['role'] == 'user') {
      return 'user';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;

          return FutureBuilder<String?>(
            future: _getUserRole(user.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return HomeShimmer();
              }

              final role = roleSnapshot.data;
              debugPrint("✅ AuthGate role: $role");

              return EcommerceMainPage();
            },
          );
        }

        // User not logged in
        return LoginPage(isShop: false);
      },
    );
  }
}
