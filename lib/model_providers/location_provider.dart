import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';

class LocationProvider extends ChangeNotifier {
  String address = "Your Location";
  double latitude = 0.0;
  double longitude = 0.0;

  void setCoordinates(double lat, double long) {
    latitude = lat;
    longitude = long;
    notifyListeners();
  }

  Future<void> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        address =
            "${place.street}, ${place.locality}, "
            "${place.administrativeArea}, ${place.country}";
      } else {
        address = "No address found";
      }
    } catch (e) {
      address = "Error: $e";
    }
    notifyListeners();
  }

  /// 🔥 Fetch from Firestore and update provider state
  Future<void> fetchLocationFromFirestore(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null &&
            data['latitude'] != null &&
            data['longitude'] != null) {
          latitude = (data['latitude'] as num).toDouble();
          longitude = (data['longitude'] as num).toDouble();
          await getAddressFromCoordinates(latitude, longitude);
        } else {
          address = "No location data in Firestore";
          notifyListeners();
        }
      }
    } catch (e) {
      address = "Error fetching location: $e";
      notifyListeners();
    }
  }

  /// ✅ Clear location on logout
  void clear() {
    address = "Your Location";
    latitude = 0.0;
    longitude = 0.0;
    notifyListeners();
  }
}
