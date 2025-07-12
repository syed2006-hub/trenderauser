import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trendera/cartpages/cart_page.dart';
import 'package:trendera/favoritepage/favorite_items_page.dart';
import 'package:trendera/homepage/home_page.dart';
import 'package:trendera/model_providers/cart_provider.dart';
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

  final List<Widget> _pages = const [
    HomePage(),
    Favoriteitemspage(),
    CartPage(),
    UserProfile(),
  ];

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
          await Provider.of<UserProvider>(
            context,
            listen: false,
          ).fetchUserData(userId);
          await Provider.of<ProductProvider>(
            context,
            listen: false,
          ).fetchProducts();

          // Wait for cart and favorites to load
          await Provider.of<FavoriteProducts>(
            context,
            listen: false,
          ).loadFavoritesFromFirestore();
          await Provider.of<CartProducts>(
            context,
            listen: false,
          ).fetchCartItemsFromFirestore();
        }
      });
    }
  }

  void _onNavBarTapped(int index) {
    setState(() => _currentPage = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          IndexedStack(index: _currentPage, children: _pages),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        icon:
                            _currentPage == 0
                                ? Icons.home
                                : Icons.home_outlined,
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
                        icon: FontAwesomeIcons.user,
                        index: 3,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
      duration: Duration(milliseconds: 250),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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

class Chipclass extends StatelessWidget {
  final String selectedfilterforchip;
  final String filterforchip;
  final String currentfiltertextforchip;

  const Chipclass({
    super.key,
    required this.selectedfilterforchip,
    required this.filterforchip,
    required this.currentfiltertextforchip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Chip(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
          label: Image.asset(filterforchip, height: 35, width: 35),
          backgroundColor: Colors.white,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(300),
          ),
          elevation: 5,
        ),
        const SizedBox(height: 5),
        Text(currentfiltertextforchip, style: TextStyle(color: Colors.white)),
      ],
    );
  }
}
