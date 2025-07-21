import 'dart:io';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trendera/Gemini_service/gemini_service.dart';
import 'package:trendera/chip%20class/chip_class.dart';
import 'package:trendera/homepage/home_all_productpage.dart';
import 'package:trendera/homepage/animated_gradient_text.dart';
import 'package:trendera/homepage/filter_details.dart';
import 'package:trendera/model_providers/cart_provider.dart';
import 'package:trendera/model_providers/favorite_provider.dart';
import 'package:trendera/model_providers/product_model.dart';
import 'package:trendera/search_result_page/search_result_page.dart';
import 'package:trendera/model_providers/user_model.dart';
import 'package:trendera/shimmers/product_simmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String value) {
    if (value.trim().isNotEmpty) {
      final allProducts =
          Provider.of<ProductProvider>(context, listen: false).allProducts;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => SearchResultPage(
                query: value.trim(),
                listProducts: allProducts,
              ),
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
        listProducts: allProducts,
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
      setState(() {
        isLoading = true;
      });
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
      setState(() {
        isLoading = false;
      });
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Column(
        children: [
          // 🔺 Header
          SafeArea(
            child: Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.secondary,
              child: Center(
                child: _SearchAndChipHeader(
                  filters: filters,
                  onSelect: (page) {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (context) => page));
                  },
                  onCapture: () => _showCaptureDialog(context),
                  searchController: _searchController,
                  onSearch: _handleSearch,
                ),
              ),
            ),
          ),

          // 🔺 Content
          Expanded(
            child: RefreshIndicator(
              color: Colors.red,
              onRefresh: () async {
                await fetchInitialData(context);
              },
              child: Container(
                padding: EdgeInsets.only(top: 25),
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child:
                    isLoading
                        ? Padding(
                          padding: const EdgeInsets.only(top: 150),
                          child: ProductSimmer(),
                        )
                        : Padding(
                          padding: const EdgeInsets.only(bottom:60.0),
                          child: AllPage(),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchAndChipHeader extends StatelessWidget {
  final List<List<dynamic>> filters;
  final ValueChanged<Widget> onSelect;
  final VoidCallback onCapture;
  final TextEditingController searchController;
  final void Function(String) onSearch;

  const _SearchAndChipHeader({
    required this.filters,
    required this.onSelect,
    required this.onCapture,
    required this.searchController,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fade-out Trendera logo
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: ShaderMask(
                shaderCallback:
                    (bounds) => LinearGradient(
                      colors: [Colors.white, Colors.black],
                    ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                child: FadeTypewriterText(
                  text: 'Trendera',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
                            : const AssetImage('assets/images/userprofile.png')
                                as ImageProvider,
                  ),
                  const SizedBox(width: 10),
                  FadeTypewriterText(
                    text: "Hello, ${user?.displayName ?? ''}",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                ],
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
            SizedBox(height: 10,),
            Center(
              child: Wrap(
                spacing: 18,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children:
                    filters.map((filter) {
                      final img = filter[0];
                      final label = filter[1];
                      final widget = filter[2];
                      final chip = Chipclass(
                        filterforchip: img,
                        currentfiltertextforchip: label,
                      );
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: GestureDetector(
                          onTap: () => onSelect(widget),
                          child: chip,
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
