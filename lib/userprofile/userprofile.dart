import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trendera/cloudinary_service/cloudinary_service.dart';
import 'package:trendera/location/location_page.dart';
import 'package:trendera/model_providers/location_provider.dart';
import 'package:trendera/myorder_page/my_order_page.dart';
import 'package:trendera/model_providers/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with AutomaticKeepAliveClientMixin {
  File? _pickedImage;

  @override
  bool get wantKeepAlive => true;

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return;

    setState(() => _pickedImage = File(pickedFile.path));
    await _savePickedImageToFirestore();
  }

  Future<void> _savePickedImageToFirestore() async {
    if (_pickedImage == null) return;

    final uploader = CloudinaryService();
    final profileImageUrl = await uploader.uploadImage(_pickedImage!);

    if (profileImageUrl == null) {
      _showSnackBar("❌ Image upload failed.", Colors.red);
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'photoUrl': profileImageUrl,
        }, SetOptions(merge: true));

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final currentUser = userProvider.currentUser;

        if (currentUser != null) {
          userProvider.setUser(currentUser.copyWith(photoUrl: profileImageUrl));
        }

        _showSnackBar("✅ Profile image saved successfully!", Colors.green);
      }
    } catch (e) {
      _showSnackBar("❌ Failed to save image: $e", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Choose an option"),
            content: const Text("Do you want to upload or capture an image?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
                child: const Text(
                  "Capture",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
                child: const Text(
                  "Upload",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
    );
  }

  void showLinkDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Center(
            child: Stack(
              children: [
                // 🟢 Dialog content
                AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: EdgeInsets.all(16),
                  content: SizedBox(
                    height: 200,
                    width: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Copy (Or) Open the link"),
                        Text(
                          "https://syed2006-hub.github.io/trendera/",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.black,
                              ),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text:
                                        'https://syed2006-hub.github.io/trendera/',
                                  ),
                                );
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Copied to clipboard"),
                                  ),
                                );
                              },
                              icon: Icon(Icons.copy, color: Colors.white),
                              label: Text(
                                "Copy",
                                style: TextStyle(color: Colors.white),
                              ),
                              iconAlignment: IconAlignment.end,
                            ),
                            SizedBox(width: 10),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.black,
                              ),
                              onPressed: () async {
                                final Uri url = Uri.parse(
                                  'https://syed2006-hub.github.io/trendera/',
                                );
                                if (await canLaunchUrl(url)) {
                                  final launched = await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                  if (!launched) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to launch externally. Trying fallback...',
                                        ),
                                      ),
                                    );
                                    await launchUrl(url);
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Can't Open URL",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: Icon(
                                Icons.arrow_outward_rounded,
                                color: Colors.white,
                              ),
                              label: Text(
                                "Open",
                                style: TextStyle(color: Colors.white),
                              ),
                              iconAlignment: IconAlignment.end,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ✨ Shimmer overlay clipped to dialog box only
                Positioned.fill(
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 200,
                        width: 300,
                        child: IgnorePointer(
                          child: Shimmer.fromColors(
                            baseColor: Colors.white24,
                            highlightColor: Colors.white60,
                            child: Container(
                              color:
                                  Colors
                                      .white, // important for shimmer visibility
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<LocationProvider>(
          context,
          listen: false,
        ).fetchLocationFromFirestore(uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Scaffold(
      body: Stack(
        children: [
          _buildHeader(context, user),
          _buildProfileCard(context, user),
          _buildBottomLogo(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel? user) {
    return Container(
      width: double.infinity,
      height: 500.w,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(150)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Text(
              "Profile",
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                const CircleAvatar(radius: 60, backgroundColor: Colors.white),
                CircleAvatar(
                  radius: 55,
                  backgroundImage:
                      _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : user?.photoUrl != null
                          ? NetworkImage(user!.photoUrl!)
                          : const AssetImage("assets/images/userprofile.png")
                              as ImageProvider,
                ),
                Positioned(
                  bottom: -7,
                  right: -7,
                  child: IconButton(
                    icon: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: _showImageSourceDialog,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              user?.displayName ?? 'User Name',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              user?.email ?? 'user@email.com',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, UserModel? user) {
    return Align(
      alignment: const Alignment(0, 0.13),
      child: Container(
        height: 300.w,
        width: 350.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildRow(
              context,
              "My Order",
              "All recent orders",
              Icons.shopify,
              const MyOrderPage(),
            ),
            _buildRow(
              context,
              "Address",
              user?.address ?? '',
              Icons.location_on,
              const LocationAccess(),
            ),
            TextButton(
              onPressed: showLinkDialog,
              child: Row(
                children: [
                  const Icon(Icons.supervised_user_circle, color: Colors.red),
                  const SizedBox(width: 13),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Admin",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        "Click to get the admin side link",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _confirmLogout,
              child: Row(
                children: [
                  const Icon(Icons.logout, color: Colors.red),
                  const SizedBox(width: 13),
                  Text("Log Out", style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Center(
            child: Stack(
              children: [
                // 🟢 Dialog content
                AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: EdgeInsets.all(16),
                  content: SizedBox(
                    height: 150.h,
                    width: 300.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Are you sure you want to log out?"),
                        Text(
                          "Do you want to continue?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                  color: Colors.black,
                                  width: .6,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(Icons.close, color: Colors.black),
                              label: Text(
                                "No",
                                style: TextStyle(color: Colors.black),
                              ),
                              iconAlignment: IconAlignment.end,
                            ),
                            SizedBox(width: 10),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.black,
                              ),
                              onPressed: () async {
                                Navigator.pop(context);
                                await FirebaseAuth.instance.signOut();
                                Get.snackbar(
                                  "Signed Out",
                                  "You're Signed Out!",
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colors.black,
                                  colorText: Colors.white,
                                );
                              },
                              icon: Icon(Icons.logout, color: Colors.red),
                              label: Text(
                                "LogOut",
                                style: TextStyle(color: Colors.white),
                              ),
                              iconAlignment: IconAlignment.end,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ✨ Shimmer overlay clipped to dialog box only
                Positioned.fill(
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 150.h,
                        width: 300.w,
                        child: IgnorePointer(
                          child: Shimmer.fromColors(
                            baseColor: Colors.white24,
                            highlightColor: Colors.white60,
                            child: Container(
                              color:
                                  Colors
                                      .white, // important for shimmer visibility
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Widget page,
  ) {
    return TextButton(
      onPressed:
          () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => page)),
      child: Row(
        children: [
          Icon(icon, color: Colors.red),
          const SizedBox(width: 13),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyLarge),
              SizedBox(
                width: 250,
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomLogo() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: Opacity(
          opacity: 0.6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              "assets/images/logo.png",
              height: 70,
              width: 70,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
