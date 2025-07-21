import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trendera/model_providers/product_model.dart';

class OrderProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ProductModel> myOrders = [];
  bool isLoading = false;

  Future<void> fetchMyOrders(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading = true;
    notifyListeners();

    try {
      final allProducts =
          Provider.of<ProductProvider>(context, listen: false).allProducts;

      final ordersSnapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('orders')
              .get();

      List<ProductModel> loadedOrders = [];

      for (var orderDoc in ordersSnapshot.docs) {
        final orderData = orderDoc.data();
        final List items = orderData['items'] ?? [];

        for (var item in items) {
          final matchingProduct = allProducts.firstWhere(
            (p) => p.id == item['id'],
            orElse:
                () => ProductModel(
                  id: item['id'] ?? '',
                  title: item['title'] ?? '',
                  price:
                      (item['price'] is num)
                          ? (item['price'] as num).toDouble()
                          : 0.0,
                  company: item['company'] ?? '',
                  imageUrl: List<String>.from(item['imageUrl'] ?? []),
                  productDescription: item['productDescription'] ?? '',
                  ratings:
                      (item['ratings'] is num)
                          ? (item['ratings'] as num).toDouble()
                          : 0.0,
                  isFavorite: false,
                  category: item['category']  ,
                  subcategory: item['subcategory'] ,
                  size: List<String>.from(item['size'] ?? []),
                  isOffer: item['isOffer'] ?? false,
                  offerImage: item['offerImage'],
                  offerDescription: item['offerDescription'],
                  carouselModel: item['carouselModel'],
                  imageBytes: item['imageBytes'],
                  totalquantity: item['quantity'] ?? 1,
                  shopId: item['shopId']
                ),
          );

          // If found, override dynamic fields from order
          final enrichedProduct = matchingProduct.copyWith(
            totalquantity: item['quantity'] ,
            selectedSize: item['selectedSize'],
            paymentStatus: orderData['paymentStatus'], // pulled from Firestore
          );

          loadedOrders.add(enrichedProduct);
        }
      }

      myOrders = loadedOrders;
    } catch (e) {
      debugPrint("Error fetching orders: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteOrder(ProductModel product) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final ordersSnapshot =
          await _firestore
              .collection('users')
              .doc(uid)
              .collection('orders')
              .get();

      for (var orderDoc in ordersSnapshot.docs) {
        final orderData = orderDoc.data();
        final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);

        final updatedItems =
            items.where((item) => item['id'] != product.id).toList();

        if (updatedItems.isEmpty) {
          await orderDoc.reference.delete();
        } else {
          await orderDoc.reference.update({'items': updatedItems});
        }
      }

      myOrders.removeWhere((item) => item.id == product.id);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting order: $e");
    }
  }
}
