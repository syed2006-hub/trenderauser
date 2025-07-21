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
  final List<String> size;
  final int totalquantity;
  final bool isOffer;
  final String? offerImage;
  final String? offerDescription;
  final String? carouselModel;
  final String? imageBytes;
  final Timestamp? createdAt;
  final String? selectedSize;
  final String? paymentStatus;

  // ✅ Newly added fields
  final String category;
  final String subcategory;
  final String shopId;

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.company,
    required this.imageUrl,
    required this.productDescription,
    required this.ratings,
    required this.isFavorite,
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
    required this.category,
    required this.subcategory,
    required this.shopId,
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
        size: List<String>.from(data['size'] ?? []),
        totalquantity: data['totalquantity'] ?? 0,

        isOffer: data['isOffer'] ?? false,
        offerImage: data['offerImage'],
        offerDescription: data['offerDescription'],
        carouselModel: data['carouselModel'],
        imageBytes: data['imageBytes'],
        createdAt: data['createdAt'],
        selectedSize: data['selectedSize'],
        paymentStatus: data['paymentStatus'],
        category: data['category'] ?? '',
        subcategory: data['subcategory'] ?? '',
        shopId: data['shopId'] ?? '',
      );
    } catch (e) {
      debugPrint("❌ Error parsing product [$id]: $e");
      rethrow;
    }
  }
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      title: map['title'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      company: map['company'] ?? '',
      imageUrl: List<String>.from(map['imageurl'] ?? []),
      productDescription: map['productdescription'] ?? '',
      ratings: (map['ratings'] ?? 0).toDouble(),
      isFavorite: map['isfavorite'] ?? false,
      size: List<String>.from(map['size'] ?? []),
      totalquantity: map['totalquantity'] ?? 0,
      isOffer: map['isOffer'] ?? false,
      offerImage: map['offerImage'],
      offerDescription: map['offerDescription'],
      carouselModel: map['carouselModel'],
      imageBytes: map['imageBytes'],
      createdAt: map['createdAt'],
      selectedSize: map['selectedSize'],
      paymentStatus: map['paymentStatus'],
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? '',
      shopId: map['shopId'] ?? '',
    );
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
      'size': size,
      'quantity': totalquantity,
      'isOffer': isOffer,
      'category': category,
      'subcategory': subcategory,
      'shopId': shopId,
      if (isOffer) ...{
        'offerImage': offerImage,
        'offerDescription': offerDescription,
        'carouselModel': carouselModel,
      },
      if (imageBytes != null) 'imageBytes': imageBytes,
      if (createdAt != null) 'createdAt': createdAt,
      if (selectedSize != null) 'selectedSize': selectedSize,
      if (paymentStatus != null) 'paymentStatus': paymentStatus,
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
    int? totalquantity,
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
      category: category,
      subcategory: subcategory,
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
      shopId: shopId,
    );
  }
}

class ProductProvider extends ChangeNotifier {
  bool isLoading = false;
  List<ProductModel> allProducts = [];
  List<ProductModel> searchResults = [];
  List<String> _recentSearches = [];

  List<ProductModel> get results => searchResults;
  List<String> get recentSearches => _recentSearches;

  void searchProducts(String query, List<ProductModel> queryProducts) {
    if (query.isEmpty || queryProducts.isEmpty) return;

    searchResults =
        queryProducts.where((product) {
          final title = product.title.toLowerCase();
          final type = product.category.toLowerCase();
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
      debugPrint("Error fetching products: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<ProductModel> get offerProducts =>
      allProducts.where((p) => p.isOffer).toList();

  List<ProductModel> get topRatingProducts =>
      allProducts.where((p) => p.ratings > 4.1).toList();

  List<ProductModel> filterByCategory(String category) =>
      allProducts.where((p) => p.category == category).toList();

  List<ProductModel> filterBySubcategory(String subcategory) =>
      allProducts.where((p) => p.subcategory == subcategory).toList();

  List<ProductModel> filterByShop(String shopId) =>
      allProducts.where((p) => p.shopId == shopId).toList();
}
