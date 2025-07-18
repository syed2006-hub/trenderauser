import 'dart:io';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trendera/Gemini_service/gemini_service.dart';
import 'package:trendera/ecommerce.dart';
import 'package:trendera/fiterproducts/accesories_page.dart';
import 'package:trendera/fiterproducts/all_page.dart';
import 'package:trendera/fiterproducts/hoody_page.dart';
import 'package:trendera/fiterproducts/shirt_page.dart';
import 'package:trendera/fiterproducts/tracks_page.dart';
import 'package:trendera/fiterproducts/trouser_page.dart';
import 'package:trendera/fiterproducts/tshirt_page.dart';
import 'package:trendera/model_providers/cart_provider.dart';
import 'package:trendera/model_providers/favorite_provider.dart';
import 'package:trendera/model_providers/product_model.dart';
import 'package:trendera/search_result_page/search_result_page.dart';
import 'package:trendera/model_providers/user_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  late String selectedCategory;
  final filters = [
    ['assets/images/all.png', 'All'],
    ['assets/images/shirt.png', 'Shirt'],
    ['assets/images/trouser.png', 'Trousers'],
    ['assets/images/tshirt.png', 'Tshirt'],
    ['assets/images/track.png', 'Tracks'],
    ['assets/images/hoody.png', 'Hoody'],
    ['assets/images/accesories.png', 'Accesories'],
  ];

  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    selectedCategory = filters[0][1];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String value) {
    if (value.trim().isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchResultPage(query: value.trim()),
        ),
      );
    }
  }

  Future<void> handleImageFromScanner(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return;
    final imageFile = File(pickedFile.path);

    // Show blurred loading dialog
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Loading",
      barrierColor: Colors.black.withOpacity(0.3),
      pageBuilder: (_, __, ___) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Center(
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text("Searching..."),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(imageFile, height: 150),
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  const Text("Finding similar products..."),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      final allProducts =
          Provider.of<ProductProvider>(context, listen: false).allProducts;

      final geminiService = GeminiService();
      final results = await geminiService.fetchSimilarProducts(
        imageFile: imageFile,
        allProducts: allProducts,
      );

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      final similar = results['similar'] ?? [];
      final related = results['related'] ?? [];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => SearchResultPage(
                query: 'Image match',
                similarProducts: similar,
                relatedProducts: related,
              ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _showCaptureDialog(BuildContext context) {
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
                    height: 150,
                    width: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Upload (Or) Capture image",
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
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                handleImageFromScanner(ImageSource.camera);
                              },
                              icon: Icon(Icons.camera, color: Colors.white),
                              label: Text(
                                "Capture",
                                style: TextStyle(color: Colors.white),
                              ),
                              iconAlignment: IconAlignment.end,
                            ),
                            SizedBox(width: 10),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                handleImageFromScanner(ImageSource.gallery);
                              },
                              icon: Icon(
                                Icons.file_upload_outlined,
                                color: Colors.white,
                              ),
                              label: Text(
                                "Upload",
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
                        height: 150,
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


  Future<void> fetchInitialData(BuildContext context) async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final productProvider = Provider.of<ProductProvider>(
          context,
          listen: false,
        );
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await Provider.of<FavoriteProducts>(
          context,
          listen: false,
        ).loadFavoritesFromFirestore();
        await Provider.of<CartProducts>(
          context,
          listen: false,
        ).fetchCartItemsFromFirestore();
        await productProvider.fetchProducts();
        await userProvider.fetchUserData(firebaseUser.uid);
      }
      debugPrint("✅ All data loaded successfully.");
    } catch (e) {
      debugPrint("❌ Error while loading data: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load data. ${e.toString()}"),
            duration: Duration(seconds: 6),
            action: SnackBarAction(
              label: "Retry",
              onPressed: () => fetchInitialData(context),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: RefreshIndicator(
        color: Colors.red,
        onRefresh: () async {
          await fetchInitialData(context);

          // ⚠️ Force rebuild by first setting to null, then 'All'
          setState(() {
            selectedCategory = '';
          });
          // Delay is required to ensure the widget rebuilds
          await Future.delayed(Duration(milliseconds: 50));
          setState(() {
            selectedCategory = filters[0][1]; // 'All'
          });
        },

        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _SearchAndChipHeader(
                filters: filters,
                selectedCategory: selectedCategory,
                onSelect: (label) {
                  setState(() {
                    selectedCategory = label;
                  });
                },
                onCapture: () => _showCaptureDialog(context),
                searchController: _searchController,
                onSearch: _handleSearch,
              ),
            ),
            SliverToBoxAdapter(
              child: CurrentPage(
                key: ValueKey(selectedCategory),
                selectedchip: selectedCategory,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurrentPage extends StatelessWidget {
  final String selectedchip;
  const CurrentPage({super.key, required this.selectedchip});

  @override
  Widget build(BuildContext context) {
    switch (selectedchip) {
      case 'All':
        return AllPage();
      case 'Shirt':
        return ShirtPage();
      case 'Trousers':
        return TrouserPage();
      case 'Tshirt':
        return TshirtPage();
      case 'Tracks':
        return TracksPage();
      case 'Accesories':
        return AccessoriesPage();
      case 'Hoody':
        return HoodyPage();
      default:
        return Center(child: Text('No category found'));
    }
  }
}

class _SearchAndChipHeader extends SliverPersistentHeaderDelegate {
  final List<List<String>> filters;
  final String selectedCategory;
  final ValueChanged<String> onSelect;
  final VoidCallback onCapture;
  final TextEditingController searchController;
  final void Function(String) onSearch;

  _SearchAndChipHeader({
    required this.filters,
    required this.selectedCategory,
    required this.onSelect,
    required this.onCapture,
    required this.searchController,
    required this.onSearch,
  });

  @override
  double get minExtent => 320.h;
  @override
  double get maxExtent => 450.h;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return ClipPath(
      clipper: ConvexBottomCornersClipper(),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fade-out Trendera logo
              if (shrinkOffset < 25)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: (1 - (shrinkOffset / 25)).clamp(0.0, 1.0),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: ShaderMask(
                      shaderCallback:
                          (bounds) => LinearGradient(
                            colors: [Colors.red, Colors.blue],
                          ).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                      child: const Text(
                        'Trendera',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 16, top: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundImage:
                          user?.photoUrl != null
                              ? NetworkImage(
                                user!.photoUrl!,
                              ) // If you store a photo URL
                              : const AssetImage(
                                    'assets/images/userprofile.png',
                                  )
                                  as ImageProvider,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Hello, ${user?.displayName ?? ''}",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Fade-out welcome lines
              if (shrinkOffset < 25)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: (1 - (shrinkOffset / 25)).clamp(0.0, 1.0),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      top: 10,
                      bottom: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Find cool products fits",
                          style: TextStyle(fontSize: 22, color: Colors.red),
                        ),
                        Text(
                          "your style",
                          style: TextStyle(fontSize: 22, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: TextField(
                  controller: searchController,
                  onSubmitted: onSearch,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    contentPadding: const EdgeInsets.all(9),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 242, 242, 242),
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: onCapture,
                      icon: const Icon(Icons.qr_code_scanner_outlined),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filters.length,
                  itemBuilder: (_, index) {
                    final img = filters[index][0];
                    final label = filters[index][1];
                    final chip = Chipclass(
                      selectedfilterforchip: selectedCategory,
                      filterforchip: img,
                      currentfiltertextforchip: label,
                    );
                    return GestureDetector(
                      onTap: () => onSelect(label),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 250),
                          scale: selectedCategory == label ? 1.15 : 1.0,
                          child: chip,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchAndChipHeader oldDelegate) =>
      oldDelegate.selectedCategory != selectedCategory;
}

class ConvexBottomCornersClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 30;

    Path path = Path();
    path.moveTo(0, 0); // Top-left
    path.lineTo(0, size.height); // Down to bottom-left

    // Bottom-left outward curve
    path.quadraticBezierTo(
      0,
      size.height - radius,
      radius,
      size.height - radius,
    );

    // Line to just before bottom-right curve
    path.lineTo(size.width - radius, size.height - radius);

    // Bottom-right outward curve
    path.quadraticBezierTo(
      size.width,
      size.height - radius,
      size.width,
      size.height,
    );

    path.lineTo(size.width, 0); // Up to top-right
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
