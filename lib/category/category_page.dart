import 'dart:io';
import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trendera/Gemini_service/gemini_service.dart';
import 'package:trendera/category/current_category_selection.dart';
import 'package:trendera/model_providers/filter_product_provider.dart';
import 'package:trendera/search_result_page/search_result_page.dart';
import 'package:flutter/material.dart';
import 'package:trendera/model_providers/product_model.dart';
import 'package:trendera/shimmers/product_simmer.dart';

class CategoryPage extends StatefulWidget {
  final List<ProductModel> listproducts;
  final String wentFrom;
  final List<String> listcategories;
  const CategoryPage({
    super.key,
    required this.listproducts,
    required this.wentFrom,
    required this.listcategories,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final TextEditingController _searchController = TextEditingController();
  late String selectedCategory;
  late List<String> categories;
  bool _isLoading = false;

  @override
  void initState() {
    categories = widget.listcategories;
    selectedCategory = categories[0];
    super.initState();
    Future.microtask(() {
      Provider.of<FilterProvider>(context, listen: false).fetchAllProducts();
    });
  }

  Future<void> _handleRefresh() async {
    // Call your data fetch logic here
    _isLoading = true;
    try {
      await Provider.of<FilterProvider>(
        context,
        listen: false,
      ).fetchAllProducts();
      await Future.delayed(const Duration(seconds: 1));
      setState(() {});
      _isLoading = false;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      _isLoading = false;
    }
  }

  void _handleSearch(String value) {
    if (value.trim().isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => SearchResultPage(
                query: value.trim(),
                listProducts: widget.listproducts,
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
      barrierColor: Colors.black38,
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
      final products = widget.listproducts;

      final geminiService = GeminiService();
      final results = await geminiService.fetchSimilarProducts(
        imageFile: imageFile,
        listProducts: products,
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

  @override
  Widget build(BuildContext context) {
    for (var product in widget.listproducts) {
      print('Product: ${product.title}, Category: ${product.category}');
    }
    print(widget.listcategories);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SafeArea(
        child: Column(
          children: [
            // Search + Scanner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // Search bar with image scanner icon
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.arrow_back_ios_new_outlined),
                      ),
                      Spacer(flex: 3),
                      Text(
                        widget.wentFrom,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Spacer(flex: 4),
                    ],
                  ),
                  TextField(
                    controller: _searchController,
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
                        onPressed: () => _showCaptureDialog(context),
                        icon: Icon(Icons.qr_code_scanner_outlined),
                      ),
                    ),
                    onSubmitted: (value) => _handleSearch(value),
                  ),

                  // Category chips
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = selectedCategory == category;

                          return buildCategoryTab(
                            category: category,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() => selectedCategory = category);
                              // optionally: filter logic here
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // White background content
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child:
                    _isLoading
                        ? ProductSimmer()
                        :RefreshIndicator(
                          onRefresh: _handleRefresh,
                          color: Colors.red,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: CurrentPage(
                              key: ValueKey(selectedCategory),
                              selectedCategory: selectedCategory,
                              listCategories: widget.listcategories,
                              wentFrom: widget.wentFrom,
                            ),
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// This builds a single category tab
Widget buildCategoryTab({
  required String category,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 3,
          width: 30,
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            category.toUpperCase(),
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ],
    ),
  );
}
