import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trendera/model_providers/location_provider.dart';
import 'package:trendera/model_providers/user_model.dart';

class LocationAccess extends StatefulWidget {
  const LocationAccess({super.key});

  @override
  State<LocationAccess> createState() => _LocationAccessState();
}

class _LocationAccessState extends State<LocationAccess> {
  bool isLoading = false;

  Future<void> _getCurrentLocation() async {
    setState(() => isLoading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception("Location services are disabled.");

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Location permission denied.");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception("Location permissions are permanently denied.");
      }

      final position = await Geolocator.getCurrentPosition();
      final provider = Provider.of<LocationProvider>(context, listen: false);

      provider.setCoordinates(position.latitude, position.longitude);
      await provider.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final locationData = {
          'uid': user.uid,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'address': provider.address,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(locationData, SetOptions(merge: true));
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.fetchUserData(
          user.uid,
        ); // 👈 Refresh local user model
      }
    } catch (e) {
      if (mounted) Get.snackbar("Location Error", "$e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // ✅ Unified Black Header
          SafeArea(
            child: Container(
              width: double.infinity,
              height: 70.w,
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 8,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Location",
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.location_on),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ White Body with rounded top
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Center(
                child: Consumer<LocationProvider>(
                  builder: (context, locationProvider, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 400.w,
                          width: 350.w,
                          child: MapScreen(
                            latitude: locationProvider.latitude,
                            longitude: locationProvider.longitude,
                          ),
                        ),
                        SizedBox(
                          width: 350.w,
                          child: Text(
                            locationProvider.address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 350.w,
                          child: ElevatedButton(
                            onPressed: isLoading ? (){} : _getCurrentLocation,
                            child:
                                isLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        backgroundColor: Colors.black,

                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text("Update Location"),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapScreen({super.key, required this.latitude, required this.longitude});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.latitude != oldWidget.latitude ||
        widget.longitude != oldWidget.longitude) {
      final newPosition = LatLng(widget.latitude, widget.longitude);
      mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng target = LatLng(widget.latitude, widget.longitude);

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: target, zoom: 15),
      markers: {
        Marker(
          markerId: const MarkerId('current_location'),
          position: target,
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      },
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
      },
      myLocationEnabled: true,
      zoomControlsEnabled: true,
    );
  }
}
