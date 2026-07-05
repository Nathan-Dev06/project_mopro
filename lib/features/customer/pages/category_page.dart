import 'package:flutter/material.dart';
import 'package:project_mopro/features/customer/pages/home_page.dart'; // import kCostumes and CostumeData
import 'package:project_mopro/features/customer/pages/detail_costume_page.dart';
import 'package:project_mopro/core/managers/wishlist_manager.dart';

class CategoryPage extends StatelessWidget {
  final String categoryName;

  const CategoryPage({Key? key, required this.categoryName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter data berdasarkan categoryName
    final List<CostumeData> results = kCostumes
        .where((c) => c.category.toLowerCase() == categoryName.toLowerCase())
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          categoryName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: results.isEmpty
          ? const Center(
              child: Text(
                "No costumes in this category.",
                style: TextStyle(color: Colors.grey, fontFamily: 'Inter'),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
                childAspectRatio: 0.62,
              ),
              itemCount: results.length,
              itemBuilder: (context, index) {
                return _buildCostumeCard(context, results[index]);
              },
            ),
    );
  }

  Widget _buildCostumeCard(BuildContext context, CostumeData data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailCostumePage(costumeData: data.toMap()),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Canvas
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox.expand(
                      child: Image.asset(
                        data.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Color(0x000ffbbb),
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Status Badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: data.isReady
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        data.isReady ? "Ready" : "Rented",
                        style: TextStyle(
                          color: data.isReady
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFEF4444),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  // Favorite Icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        WishlistManager.instance.toggleWishlist(data.title);
                      },
                      child: ValueListenableBuilder<List<String>>(
                        valueListenable:
                            WishlistManager.instance.wishlistNotifier,
                        builder: (context, wishlist, _) {
                          final isLiked = wishlist.contains(data.title);
                          return Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isLiked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isLiked ? Colors.red : Colors.black,
                              size: 14,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Series
          Text(
            data.series,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 2),
          // Title
          Text(
            data.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          // Price
          Text(
            "Rp ${data.price} / 3 Days",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
