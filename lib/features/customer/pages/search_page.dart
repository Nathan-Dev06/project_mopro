import 'package:flutter/material.dart';
import 'package:project_mopro/features/customer/pages/home_page.dart';
import 'package:project_mopro/features/customer/pages/detail_costume_page.dart';
import 'package:project_mopro/features/customer/pages/category_page.dart';
import 'package:project_mopro/core/managers/wishlist_manager.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // â”€â”€ Design Tokens â”€â”€
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _black = Color(0xFF111111);
  static const Color _grey800 = Color(0xFF333333);
  static const Color _grey500 = Color(0xFF888888);
  static const Color _grey400 = Color(0xFFB0B0B0);
  static const Color _grey300 = Color(0xFFD5D5D5);
  static const Color _grey200 = Color(0xFFE8E8E8);
  static const Color _grey100 = Color(0xFFF5F5F5);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _showReadyOnly = false;

  final List<String> _recentSearches = [
    "Satoru Gojo",
    "Maid Outfit",
    "Genshin Impact",
  ];

  final List<String> _popularCategories = [
    "Anime",
    "Games",
    "Movies",
    "Props & Weapons",
    "Accessories",
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter costumes based on search query and ready status
    final filteredCostumes = _searchQuery.isEmpty
        ? <CostumeData>[]
        : kCostumes.where((c) {
            if (_showReadyOnly && !c.isReady) return false;
            return c.title.toLowerCase().contains(_searchQuery) ||
                c.series.toLowerCase().contains(_searchQuery) ||
                c.category.toLowerCase().contains(_searchQuery);
          }).toList();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SEARCH BAR & FILTER (Fixed at top)
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 16, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: _grey100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          color: _black,
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: _grey500,
                            size: 20,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded,
                                      color: _grey400, size: 18),
                                  onPressed: () => _searchController.clear(),
                                )
                              : null,
                          hintText: "Search costumes, series, or characters...",
                          hintStyle: const TextStyle(
                            color: _grey400,
                            fontSize: 13,
                            fontFamily: 'Inter',
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: _grey200, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune_rounded,
                          color: _black, size: 20),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setModalState) {
                                return Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: const BoxDecoration(
                                    color: _bg,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(24),
                                      topRight: Radius.circular(24),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Filters",
                                            style: TextStyle(
                                              color: _black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () => Navigator.pop(context),
                                            icon: const Icon(Icons.close_rounded, color: _black),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      GestureDetector(
                                        onTap: () {
                                          // Update state di dalam modal
                                          setModalState(() {
                                            _showReadyOnly = !_showReadyOnly;
                                          });
                                          // Update state di halaman utama (SearchPage)
                                          setState(() {});
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: Row(
                                          children: [
                                            Icon(
                                              _showReadyOnly
                                                  ? Icons.check_box_rounded
                                                  : Icons.check_box_outline_blank_rounded,
                                              color: _showReadyOnly
                                                  ? const Color(0xFF22C55E)
                                                  : _grey500,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              "Show Ready Only",
                                              style: TextStyle(
                                                color: _showReadyOnly ? _black : _grey500,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 48), // Spacing for bottom safe area
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),



            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: _searchQuery.isEmpty
                    ? _buildIdleState()
                    : _buildSearchResults(filteredCostumes),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2. RECENT SEARCHES
        if (_recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Searches",
                style: TextStyle(
                  color: _black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _recentSearches.clear();
                  });
                },
                child: const Text(
                  "Clear All",
                  style: TextStyle(
                    color: _grey500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = _recentSearches[index];
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.history_rounded,
                          color: _grey400, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        _recentSearches[index],
                        style: const TextStyle(
                          color: _grey800,
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],

        // 3. TRENDING CATEGORIES
        const Text(
          "Popular Categories",
          style: TextStyle(
            color: _black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: _popularCategories.take(3).map((category) {
            return GestureDetector(
              onTap: () {
                _searchController.text = category;
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _bg,
                  border: Border.all(color: _grey200, width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    color: _black,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 36),

        // 4. RECOMMENDED (Dummy)
        const Text(
          "You Might Like",
          style: TextStyle(
            color: _black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: Builder(builder: (context) {
            final dummyItems = kCostumes
                .where((c) => !_showReadyOnly || c.isReady)
                .take(4)
                .toList();

            return ListView.separated(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: dummyItems.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 160,
                  child: _buildCostumeCard(dummyItems[index]),
                );
              },
            );
          }),
        ),
        const SizedBox(height: 36),

        // 5. ALL CATEGORY CAROUSELS
        ..._popularCategories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _buildCategoryCarousel(category),
          );
        }).toList(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCategoryCarousel(String categoryName) {
    final List<CostumeData> categoryItems = kCostumes
        .where((c) => c.category.toLowerCase() == categoryName.toLowerCase())
        .where((c) => !_showReadyOnly || c.isReady)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              categoryName,
              style: const TextStyle(
                color: _black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CategoryPage(categoryName: categoryName),
                  ),
                );
              },
              behavior: HitTestBehavior.opaque,
              child: const Text(
                "See All >",
                style: TextStyle(
                  color: _grey500,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: categoryItems.isEmpty
              ? const Center(
                  child: Text("No costumes yet",
                      style: TextStyle(color: _grey500)),
                )
              : ListView.separated(
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount:
                      categoryItems.length > 5 ? 5 : categoryItems.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 160,
                      child: _buildCostumeCard(categoryItems[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(List<CostumeData> results) {
    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Center(
          child: Column(
            children: const [
              Icon(Icons.search_off_rounded, size: 64, color: _grey300),
              SizedBox(height: 16),
              Text(
                "No results found",
                style: TextStyle(
                  color: _black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Try searching for something else\nor use a different keyword.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _grey500,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${results.length} results for '$_searchQuery'",
          style: const TextStyle(
            color: _black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 24,
            childAspectRatio: 0.62,
          ),
          itemCount: results.length,
          itemBuilder: (context, index) {
            return _buildCostumeCard(results[index]);
          },
        ),
      ],
    );
  }

  Widget _buildCostumeCard(CostumeData data) {
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
                color: _grey100,
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
                          color: _grey100,
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
                        valueListenable: WishlistManager.instance.wishlistNotifier,
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
                              isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isLiked ? Colors.red : _black,
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
              color: _black,
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
            style: const TextStyle(
              color: _grey500,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          // Price
          Text(
            "Rp ${data.price} / 3 Days",
            style: const TextStyle(
              color: _black,
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
