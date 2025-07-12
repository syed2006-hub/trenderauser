import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.address,
    this.latitude,
    this.longitude,
    this.photoUrl,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? address,
    double? latitude,
    double? longitude,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      displayName: map['displayName'],
      address: map['address'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      photoUrl: map['photoUrl'],
    );
  }
}

class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  void setUser(UserModel userModel) {
    _currentUser = userModel;
    notifyListeners();
  }

  Future<void> updateUserLocation({
    required String uid,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      });

      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          address: address,
          latitude: latitude,
          longitude: longitude,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating location: $e");
    }
  }

  Future<void> updateUserProfileImage(String uid, String photoUrl) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'photoUrl': photoUrl,
      });

      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(photoUrl: photoUrl);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Failed to update photoUrl: $e");
    }
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
