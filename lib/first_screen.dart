import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trendera/cartpages/cart_page.dart';
import 'package:trendera/favoritepage/favorite_items_page.dart';
import 'package:trendera/homepage/home_page.dart'; 
import 'package:trendera/model_providers/favorite_provider.dart';
import 'package:trendera/model_providers/product_model.dart';
import 'package:trendera/model_providers/user_model.dart';
import 'package:trendera/userprofile/userprofile.dart';

class EcommerceMainPage extends StatefulWidget {
  const EcommerceMainPage({super.key});

  @override
  State<EcommerceMainPage> createState() => _EcommerceMainPageState();
}

class _EcommerceMainPageState extends State<EcommerceMainPage> {
  int _currentPage = 0;

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      _isInit = false;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final firebaseUser = FirebaseAuth.instance.currentUser;

        if (firebaseUser != null) {
          final userId = firebaseUser.uid;
          await Provider.of<ProductProvider>(
            context,
            listen: false,
          ).fetchProducts();
          await Provider.of<UserProvider>(
            context,
            listen: false,
          ).fetchUserData(userId);
          

          await Provider.of<FavoriteProducts>(
            context,
            listen: false,
          ).loadFavoritesFromFirestore();

          
        }
      });
    }
  }

  void _onNavBarTapped(int index) {
    setState(() => _currentPage = index);
  }

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case 0:
        return const HomePage();
      case 1:
        return const Favoriteitemspage();
      case 2:
        return const CartPage();
      case 3:
        return const UserProfile();
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(children: [_buildCurrentPage(), _buildBottomNavBar()]),
    );
  }

  Widget _buildBottomNavBar() {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: _currentPage == 0 ? Icons.home : Icons.home_outlined,
                  index: 0,
                ),
                _buildNavItem(
                  icon:
                      _currentPage == 1
                          ? Icons.favorite
                          : Icons.favorite_border,
                  index: 1,
                ),
                _buildNavItem(
                  icon:
                      _currentPage == 2
                          ? Icons.shopping_cart
                          : Icons.shopping_cart_outlined,
                  index: 2,
                ),
                _buildNavItem(
                  icon:
                      _currentPage == 3
                          ? Icons.person_4_sharp
                          : Icons.person_4_outlined,
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    double size = 28,
  }) {
    final isSelected = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: GestureDetector(
        onTap: () => _onNavBarTapped(index),
        child: Icon(
          icon,
          size: size,
          color: isSelected ? Colors.black : Theme.of(context).iconTheme.color,
        ),
      ),
    );
  }
}
