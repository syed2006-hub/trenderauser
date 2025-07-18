import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trendera/model_providers/order_provider.dart';

class MyOrderPage extends StatefulWidget {
  const MyOrderPage({super.key});

  @override
  State<MyOrderPage> createState() => _MyOrderPageState();
}

class _MyOrderPageState extends State<MyOrderPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchMyOrders(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.myOrders;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Column(
        children: [
          // ✅ Black Header
          SafeArea(
            child: Container(
              width: double.infinity,
              height: 70,
              color: Theme.of(context).colorScheme.secondary,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 10,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back_ios_new_outlined),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "My Order",
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.shopping_bag),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ White Body
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child:
                  orderProvider.isLoading
                      ? ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: 4,
                        itemBuilder:
                            (context, index) => const OrderShimmerCard(),
                      )
                      : orders.isEmpty
                      ? const Center(child: Text("No orders yet"))
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final product = orders[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading:
                                  product.imageUrl.isNotEmpty
                                      ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          product.imageUrl.first,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey[200],
                                              child: Icon(
                                                Icons.broken_image,
                                                color: Colors.grey[600],
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                      : Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                        ),
                                      ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (product.selectedSize!.isNotEmpty)
                                    Row(
                                      children: [
                                        Text("Size: ${product.selectedSize}"),
                                        const SizedBox(width: 12),
                                        Text("Qty: ${product.totalquantity}"),
                                      ],
                                    ),
                                  if (product.selectedSize!.isEmpty)
                                    Text("Qty: ${product.totalquantity}"),
                                  const SizedBox(height: 4),
                                  Text(
                                    "₹${product.price.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              trailing:
                                  product.paymentStatus == "success"
                                      ? Column(
                                        children: [
                                          ClipOval(
                                            child: Material(
                                              color: Colors.lightGreen,
                                              child: InkWell(
                                                child: SizedBox(
                                                  width: 40,
                                                  height: 40,
                                                  child: Icon(
                                                    Icons.done_all,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Text("Status"),
                                        ],
                                      )
                                      : const Icon(
                                        Icons.cancel_outlined,
                                        color: Colors.red,
                                      ),
                            ),
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Order Shimmer Widget
class OrderShimmerCard extends StatelessWidget {
  const OrderShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image shimmer
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Title & price shimmer
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: double.infinity,
                      height: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(width: 80, height: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
