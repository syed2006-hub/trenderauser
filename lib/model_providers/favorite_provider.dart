import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:trendera/model_providers/product_model.dart';

class FavoriteProducts with ChangeNotifier {
  final List<ProductModel> _favProducts = [];
  List<ProductModel> get favproductinfo => _favProducts;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if a product is favorited
  bool isFavorite(ProductModel product) {
    return _favProducts.any((item) => item.id == product.id);
  }

  /// Toggle favorite state
  Future<void> toggleFavorite(ProductModel product) async {
    if (isFavorite(product)) {
      await removeProduct(product);
    } else {
      await addProduct(product);
    }
    notifyListeners();
  }

  /// Add a product to favorites in Firestore
  Future<void> addProduct(ProductModel product) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (isFavorite(product)) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(product.id)
          .set({'productId': product.id});

      _favProducts.add(product);
      notifyListeners();
      debugPrint("❤️ Added to favorites: ${product.title}");
    } catch (e) {
      debugPrint('❌ Error adding favorite: $e');
    }
  }

  /// Remove a product from favorites in Firestore
  Future<void> removeProduct(ProductModel product) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(product.id)
          .delete();

      _favProducts.removeWhere((item) => item.id == product.id);
      notifyListeners();
      debugPrint("💔 Removed from favorites: ${product.title}");
    } catch (e) {
      debugPrint('❌ Error removing favorite: $e');
    }
  }

  /// Load all favorite products from Firestore
  Future<void> loadFavoritesFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final favSnapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('favorites')
              .get();

      _favProducts.clear(); // Clear before reload to avoid duplicates

      for (final doc in favSnapshot.docs) {
        final productId = doc.id;

        try {
          final productSnap =
              await _firestore.collection('products').doc(productId).get();

          if (productSnap.exists) {
            final product = ProductModel.fromFirestore(
              productSnap.data()!,
              productId,
            );
            _favProducts.add(product);
          } else {
            debugPrint("⚠️ Favorite product not found: $productId");
          }
        } catch (e) {
          debugPrint('❌ Error fetching product $productId: $e');
        }
      }

      notifyListeners();
      debugPrint("✅ Favorites loaded: ${_favProducts.length}");
    } catch (e) {
      debugPrint('❌ Error loading favorites: $e');
    }
  }

  /// Clear local favorites only (does not affect Firestore)
  void clearFavorites() {
    _favProducts.clear();
    notifyListeners();
  }
}
