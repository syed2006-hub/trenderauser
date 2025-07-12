import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trendera/model_providers/product_model.dart';
import 'package:trendera/cartpages/cart_item.dart';

class CartProducts with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => _cartItems;

  /// Load cart items from Firestore and fetch ProductModel by ID
  Future<void> fetchCartItemsFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) {
      print("⚠️ User not logged in");
      return;
    }

    final cartRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart');

    final snapshot = await cartRef.get();
    print("📦 Cart documents found: ${snapshot.docs.length}");

    List<CartItem> fetchedItems = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final productId = data['productId']; // now a real product ID
      final quantity = data['quantity'] ?? 1;
      final selectedSize = data['selectedSize'] ?? '';

      try {
        final productDoc =
            await _firestore.collection('products').doc(productId).get();

        if (!productDoc.exists) {
          print("❌ Product '$productId' not found in Firestore");
          continue;
        }

        final product = ProductModel.fromFirestore(
          productDoc.data()!,
          productDoc.id,
        );

        fetchedItems.add(
          CartItem(
            product: product,
            quantity: quantity,
            selectedSize: selectedSize,
          ),
        );
      } catch (e) {
        print("❌ Error loading product $productId: $e");
      }
    }

    _cartItems = fetchedItems;
    notifyListeners();
  }

  /// Save or update a cart item to Firestore
  Future<void> _saveCartItem(CartItem item) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docId = '${item.product.id}_${item.selectedSize}';
    final cartRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(docId);

    await cartRef.set({
      'productId': item.product.id,
      'selectedSize': item.selectedSize,
      'quantity': item.quantity,
    });

    print("✅ Saved/Updated item: $docId");
  }

  /// Add or update cart item
  Future<void> addProduct(ProductModel product, String selectedSize) async {
    final index = _cartItems.indexWhere(
      (item) =>
          item.product.id == product.id && item.selectedSize == selectedSize,
    );

    if (index >= 0) {
      _cartItems[index].quantity += 1;
      await _saveCartItem(_cartItems[index]);
    } else {
      final newItem = CartItem(
        product: product,
        selectedSize: selectedSize,
        quantity: 1,
      );
      _cartItems.add(newItem);
      await _saveCartItem(newItem);
    }

    notifyListeners();
  }

  /// Increase quantity
  Future<void> increaseQuantity(CartItem item) async {
    item.quantity += 1;
    notifyListeners();
    await _saveCartItem(item);
  }

  /// Decrease quantity or remove
  Future<void> decreaseQuantity(CartItem item) async {
    if (item.quantity > 1) {
      item.quantity -= 1;
      await _saveCartItem(item);
    } else {
      await removeItem(item);
    }
    notifyListeners();
  }

  /// Remove item completely
  Future<void> removeItem(CartItem item) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docId = '${item.product.id}_${item.selectedSize}';
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(docId)
          .delete();
      print("🗑️ Deleted cart item: $docId");
    } catch (e) {
      print("❌ Error deleting item $docId: $e");
    }

    _cartItems.removeWhere(
      (e) =>
          e.product.id == item.product.id &&
          e.selectedSize == item.selectedSize,
    );
    notifyListeners();
  }

  /// Clear the entire cart
  Future<void> clearCart() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final cartDocs =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .get();

    final batch = _firestore.batch();
    for (final doc in cartDocs.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    print("🧹 Cleared entire cart from Firestore");

    _cartItems.clear();
    notifyListeners();
  }
}
