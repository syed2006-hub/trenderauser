import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductModel {
  final String id;
  final String title;
  final double price;
  final String company;
  final List<String> imageUrl;
  final String productDescription;
  final double ratings;
  final bool isFavorite;
  final String type;
  final List<String> size;
  final double totalquantity;
  final bool isOffer;
  final String? offerImage;
  final String? offerDescription;
  final String? carouselModel;
  final String? imageBytes;
  final Timestamp? createdAt;

  // ✅ Newly added fields
  final String? selectedSize;
  final String? paymentStatus;

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.company,
    required this.imageUrl,
    required this.productDescription,
    required this.ratings,
    required this.isFavorite,
    required this.type,
    required this.size,
    required this.totalquantity,
    required this.isOffer,
    this.offerImage,
    this.offerDescription,
    this.carouselModel,
    this.imageBytes,
    this.createdAt,
    this.selectedSize,
    this.paymentStatus,
  });

  factory ProductModel.fromFirestore(Map<String, dynamic> data, String id) {
    try {
      return ProductModel(
        id: id,
        title: data['title'] ?? '',
        price: (data['price'] ?? 0).toDouble(),
        company: data['company'] ?? '',
        imageUrl: List<String>.from(data['imageurl'] ?? []),
        productDescription: data['productdescription'] ?? '',
        ratings: (data['ratings'] ?? 0).toDouble(),
        isFavorite: data['isfavorite'] ?? false,
        type: data['type'] ?? '',
        size: List<String>.from(data['size'] ?? []),
        totalquantity:
            (data['quantity'] is num)
                ? (data['quantity'] as num).toDouble()
                : 1.0,
        isOffer: data['isOffer'] ?? false,
        offerImage: data['offerImage'],
        offerDescription: data['offerDescription'],
        carouselModel: data['carouselModel'],
        imageBytes: data['imageBytes'],
        createdAt: data['createdAt'],
        selectedSize: data['selectedSize'], // ✅ new
        paymentStatus: data['paymentStatus'], // ✅ new
      );
    } catch (e) {
      debugPrint("❌ Error parsing product [$id]: $e");
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'company': company,
      'imageurl': imageUrl,
      'productdescription': productDescription,
      'ratings': ratings,
      'isfavorite': isFavorite,
      'type': type,
      'size': size,
      'totalquantity': totalquantity,
      'isOffer': isOffer,
      if (isOffer) ...{
        'offerImage': offerImage,
        'offerDescription': offerDescription,
        'carouselModel': carouselModel,
      },
      if (imageBytes != null) 'imageBytes': imageBytes,
      if (createdAt != null) 'createdAt': createdAt,
      if (selectedSize != null) 'selectedSize': selectedSize, // ✅
      if (paymentStatus != null) 'paymentStatus': paymentStatus, // ✅
    };
  }

  ProductModel copyWith({
    String? id,
    String? title,
    double? price,
    String? company,
    List<String>? imageUrl,
    String? productDescription,
    double? ratings,
    bool? isFavorite,
    String? type,
    List<String>? size,
    double? totalquantity,
    bool? isOffer,
    String? offerImage,
    String? offerDescription,
    String? carouselModel,
    String? imageBytes,
    Timestamp? createdAt,
    String? selectedSize, // ✅
    String? paymentStatus, // ✅
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      company: company ?? this.company,
      imageUrl: imageUrl ?? this.imageUrl,
      productDescription: productDescription ?? this.productDescription,
      ratings: ratings ?? this.ratings,
      isFavorite: isFavorite ?? this.isFavorite,
      type: type ?? this.type,
      size: size ?? this.size,
      totalquantity: totalquantity ?? this.totalquantity,
      isOffer: isOffer ?? this.isOffer,
      offerImage: offerImage ?? this.offerImage,
      offerDescription: offerDescription ?? this.offerDescription,
      carouselModel: carouselModel ?? this.carouselModel,
      imageBytes: imageBytes ?? this.imageBytes,
      createdAt: createdAt ?? this.createdAt,
      selectedSize: selectedSize ?? this.selectedSize, // ✅
      paymentStatus: paymentStatus ?? this.paymentStatus, // ✅
    );
  }
}

class ProductProvider extends ChangeNotifier {
  bool isLoading = false;
  List<ProductModel> allProducts = [];
  List<ProductModel> _searchResults = [];
  List<String> _recentSearches = [];

  List<ProductModel> get searchResults => _searchResults;
  List<String> get recentSearches => _recentSearches;

  void searchProducts(String query) {
    if (query.isEmpty) return;

    _searchResults =
        allProducts.where((product) {
          final title = product.title.toLowerCase();
          final type = product.type.toLowerCase();
          final lowerQuery = query.toLowerCase();
          return title.contains(lowerQuery) || type.contains(lowerQuery);
        }).toList();

    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 5) {
        _recentSearches = _recentSearches.sublist(0, 5);
      }
    }

    notifyListeners();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading = true;
      notifyListeners();

      final snapshot =
          await FirebaseFirestore.instance.collection('products').get();

      allProducts =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return ProductModel.fromFirestore(data, doc.id);
          }).toList();
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<ProductModel> get offerProducts =>
      allProducts.where((p) => p.isOffer).toList();

  List<ProductModel> get topRatingProducts =>
      allProducts.where((p) => p.ratings > 4.1).toList();
}
