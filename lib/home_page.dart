import 'package:flutter/material.dart';
import 'detail_costume_page.dart';

// =============================================
// DESIGN SYSTEM — Kick Avenue Aesthetic
// Clean, Light, Premium Minimalist
// Monochromatic: Black, White, Soft Greys
// =============================================

// ==================== DATA MODELS ====================
class CostumeData {
  final String title;
  final String series;
  final String price;
  final String condition;
  final String image;
  final String include;
  final String size; // e.g. "S|M|L|XL" or "All Size"
  final bool isReady;
  final String category;
  final double rating;
  final int reviewCount;

  const CostumeData({
    required this.title,
    required this.series,
    required this.price,
    required this.condition,
    required this.image,
    required this.include,
    required this.size,
    required this.isReady,
    this.category = 'Anime',
    this.rating = 4.8,
    this.reviewCount = 12,
  });

  /// Size list from string. "All Size" → ['All Size']
  List<String> get sizeList {
    if (size == 'All Size') return ['All Size'];
    if (size.contains('|')) {
      return size.split('|').map((s) => s.trim()).toList();
    }
    if (size.contains(',')) {
      return size.split(',').map((s) => s.trim()).toList();
    }
    if (size.contains(' - ')) {
      return size.split(' - ').map((s) => s.trim()).toList();
    }
    return [size];
  }

  bool get hasMultipleSizes => sizeList.length > 1;

  /// Compact size display: "S|M" → "S|M"
  String get sizeDisplay {
    if (size == 'All Size') return 'All Size';
    return sizeList.join('|');
  }

  factory CostumeData.fromMap(Map<String, dynamic> map) {
    return CostumeData(
      title: map['title'] ?? '',
      series: map['series'] ?? '',
      price: map['price'] ?? '0',
      condition: map['condition'] ?? '100%',
      image: map['image'] ?? '',
      include: map['include'] ?? '',
      size: map['size'] ?? 'All Size',
      isReady: map['isReady'] ?? true,
      category: map['category'] ?? 'Anime',
      rating: (map['rating'] ?? 4.8).toDouble(),
      reviewCount: map['reviewCount'] ?? 12,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'series': series,
        'price': price,
        'condition': condition,
        'image': image,
        'include': include,
        'size': size,
        'isReady': isReady,
        'category': category,
        'rating': rating,
        'reviewCount': reviewCount,
      };
}

// ==================== DESIGN TOKENS ====================
/// Strict monochromatic palette — Kick Avenue inspired
class _C {
  static const Color bg = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5); // light grey product bg
  static const Color surfaceAlt = Color(0xFFF9F9F9); // alternate surface
  static const Color black = Color(0xFF111111); // primary text & CTA
  static const Color grey800 = Color(0xFF333333); // secondary text
  static const Color grey500 = Color(0xFF888888); // muted text
  static const Color grey400 = Color(0xFFB0B0B0); // tertiary text
  static const Color grey300 = Color(0xFFD5D5D5); // borders
  static const Color grey200 = Color(0xFFE8E8E8); // hairline
  static const Color grey100 = Color(0xFFF2F2F2); // search bg
  static const Color white = Color(0xFFFFFFFF);
  static const Color readyGreen = Color(0xFF22C55E); // availability: Ready
  static const Color readyGreenBg = Color(0xFFDCFCE7);
  static const Color rentedRed = Color(0xFFEF4444); // availability: Rented
  static const Color rentedRedBg = Color(0xFFFEE2E2);
  static const Color trustMint = Color(0xFFE8FBF3); // trust badge bg
  static const Color trustMintText = Color(0xFF0D9F6E); // trust badge text
}

// ==================== STATIC COSTUME DATA ====================
const List<CostumeData> kCostumes = [
  // ── ANIME ──
  CostumeData(
    title: "Monkey D. Luffy (Wano)",
    series: "One Piece",
    price: "120,000",
    condition: "95%",
    image: "images/luffy_wano.jpg",
    include: "Red Kimono, Fire Pattern Haori, Straw Hat, Wooden Sandals",
    size: "L|XL",
    isReady: true,
    category: "Anime",
    rating: 4.9,
    reviewCount: 34,
  ),
  CostumeData(
    title: "Satoru Gojo (Hidden Inventory)",
    series: "Jujutsu Kaisen",
    price: "145,000",
    condition: "98%",
    image: "images/gojo.jpg",
    include: "Black Shirt, Trousers, Black Sunglasses, White Wig",
    size: "S|M|L",
    isReady: false,
    category: "Anime",
    rating: 5.0,
    reviewCount: 58,
  ),
  CostumeData(
    title: "Nezuko Kamado Full Set",
    series: "Demon Slayer",
    price: "135,000",
    condition: "97%",
    image: "images/nezuko.jpg",
    include: "Pink Kimono, Red Obi, Bamboo Prop, Long Black Wig",
    size: "S|M",
    isReady: true,
    category: "Anime",
    rating: 4.8,
    reviewCount: 29,
  ),
  CostumeData(
    title: "Tanjiro Kamado",
    series: "Demon Slayer",
    price: "130,000",
    condition: "96%",
    image: "images/tanjiro.jpg",
    include: "Checkered Haori, Black Kimono, Wig, Hanafuda Earrings",
    size: "S|M|L|XL",
    isReady: true,
    category: "Anime",
    rating: 4.7,
    reviewCount: 22,
  ),
  CostumeData(
    title: "Zero Two (002)",
    series: "Darling in the FranXX",
    price: "155,000",
    condition: "99%",
    image: "images/zero_two.jpg",
    include: "Red Uniform, Horn Headband, Long Pink Wig, Gloves",
    size: "S|M",
    isReady: true,
    category: "Anime",
    rating: 4.9,
    reviewCount: 41,
  ),

  // ── GAMES ──
  CostumeData(
    title: "Link (Breath of The Wild)",
    series: "The Legend of Zelda",
    price: "160,000",
    condition: "93%",
    image: "images/link.jpg",
    include: "Blue Shirt, Brown Pants, Leather Belt, Sword & Shield Prop",
    size: "M|L",
    isReady: true,
    category: "Games",
    rating: 4.6,
    reviewCount: 18,
  ),
  CostumeData(
    title: "Kratos (God of War)",
    series: "God of War",
    price: "200,000",
    condition: "91%",
    image: "images/kratos.jpg",
    include: "Full Armor, Grey Body Paint, Leviathan Axe Prop, Cape",
    size: "L|XL",
    isReady: true,
    category: "Games",
    rating: 4.8,
    reviewCount: 15,
  ),
  CostumeData(
    title: "Jinx (Arcane)",
    series: "League of Legends / Arcane",
    price: "170,000",
    condition: "97%",
    image: "images/jinx.jpg",
    include: "Blue Jacket, Shorts, Blue Braid Wig, Minigun Prop",
    size: "S|M|L",
    isReady: false,
    category: "Games",
    rating: 4.9,
    reviewCount: 27,
  ),

  // ── MOVIES ──
  CostumeData(
    title: "Dalí Mask & Jumpsuit",
    series: "Money Heist (Netflix)",
    price: "100,000",
    condition: "90%",
    image: "images/money_heist.jpg",
    include: "Red Jumpsuit, Dalí Mask, Gloves, Weapon Prop",
    size: "All Size",
    isReady: true,
    category: "Movies",
    rating: 4.7,
    reviewCount: 21,
  ),
  CostumeData(
    title: "Spider-Man (Miles Morales)",
    series: "Marvel / Spider-Verse",
    price: "180,000",
    condition: "99%",
    image: "images/spiderman.jpg",
    include: "Full Body Suit, Lens Mask, Hoodie Jacket, Shorts",
    size: "S|M|L",
    isReady: true,
    category: "Movies",
    rating: 4.9,
    reviewCount: 47,
  ),
  CostumeData(
    title: "Thanos Armor Full",
    series: "Avengers: Endgame",
    price: "250,000",
    condition: "88%",
    image: "images/thanos.jpg",
    include: "Full Armor Set, Helmet, Infinity Gauntlet, Purple Cape",
    size: "XL",
    isReady: true,
    category: "Movies",
    rating: 4.5,
    reviewCount: 11,
  ),

  // ── EXTRAS ──
  CostumeData(
    title: "UA High Uniform (Izuku)",
    series: "My Hero Academia",
    price: "110,000",
    condition: "96%",
    image: "images/izuku.jpg",
    include: "Blue Blazer, Trousers, Tie, UA Emblem",
    size: "S|M|L",
    isReady: true,
    category: "Anime",
    rating: 4.8,
    reviewCount: 33,
  ),
  CostumeData(
    title: "Emilia (Re:Zero)",
    series: "Re:Zero",
    price: "165,000",
    condition: "98%",
    image: "images/emilia.jpg",
    include: "White-Purple Gown, Flower Crown, Long Silver Wig, Cloak",
    size: "S|M",
    isReady: true,
    category: "Anime",
    rating: 4.9,
    reviewCount: 38,
  ),
  CostumeData(
    title: "Batman (Dark Knight)",
    series: "DC Comics",
    price: "195,000",
    condition: "94%",
    image: "images/batman.jpg",
    include: "Full Black Bodysuit, Cape, Cowl, Utility Belt, Batarang",
    size: "M|L|XL",
    isReady: true,
    category: "Movies",
    rating: 4.8,
    reviewCount: 31,
  ),
  CostumeData(
    title: "Wonder Woman",
    series: "DC Comics",
    price: "185,000",
    condition: "96%",
    image: "images/wonder_women.jpg",
    include: "Gold-Red Armor, Tiara, Lasso Prop, Shield & Sword",
    size: "S|M|L",
    isReady: true,
    category: "Movies",
    rating: 4.9,
    reviewCount: 24,
  ),
];

// ==================== MAIN HOME PAGE ====================
class MainHomePage extends StatefulWidget {
  const MainHomePage({Key? key}) : super(key: key);
  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  final TextEditingController _searchController = TextEditingController();

  // ── Kick Avenue-style category filter tab state ──
  String _selectedTab = 'All';
  static const List<String> _categoryTabs = [
    'All',
    'Anime',
    'Games',
    'Movies',
    'Props & Weapons',
    'Accessories',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('main_home_page_scaffold'),
      backgroundColor: _C.bg,
      // ── Section A: Top App Bar ──
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        key: const Key('home_scroll_view'),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section B: Immediate Search & Filter ──
            const SizedBox(height: 4),
            _buildSearchAndFilter(),

            // ── Kick Avenue-style Category Filter Tabs ──
            const SizedBox(height: 10),
            _buildCategoryTabs(),

            // ── Section D: Compact Promo Banner ──
            const SizedBox(height: 14),
            _buildPromoBanner(),

            // ── Section E: Trust Badges Bar ──
            const SizedBox(height: 14),
            _buildTrustBadges(),

            // ── Section G: Main Catalog Grid ──
            const SizedBox(height: 14),
            _buildCatalogHeader(),
            const SizedBox(height: 10),
            _buildCatalogGrid(),

            // Bottom padding
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  A. TOP APP BAR
  //  Bold "COSVORIA" on left, Notification + Profile on right
  // ══════════════════════════════════════════════════════════════
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      key: const Key('cosvoria_app_bar'),
      backgroundColor: _C.bg,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 52,
      centerTitle: false,
      title: const Text(
        "COSVORIA",
        style: TextStyle(
          color: _C.black,
          fontWeight: FontWeight.w900,
          letterSpacing: 3,
          fontSize: 18,
        ),
      ),
      actions: [
        // Notification bell icon
        IconButton(
          key: const Key('notification_button'),
          icon: const Icon(Icons.notifications_none_rounded,
              color: _C.black, size: 22),
          onPressed: () {},
          splashRadius: 20,
        ),
        // Profile circle avatar
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 2),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _C.surface,
              border: Border.all(color: _C.grey300, width: 1),
            ),
            child:
                const Icon(Icons.person_rounded, color: _C.grey500, size: 16),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  B. IMMEDIATE SEARCH & FILTER
  //  Clean grey horizontal Row: SearchBar + solid black Filter btn
  // ══════════════════════════════════════════════════════════════
  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: _C.grey100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search_rounded, color: _C.grey400, size: 20),
            const SizedBox(width: 10),
            // Search input field
            Expanded(
              child: TextField(
                key: const Key('search_field'),
                controller: _searchController,
                style: const TextStyle(
                  color: _C.black,
                  fontSize: 13,
                ),
                decoration: const InputDecoration(
                  hintText: "Search costumes, anime, or characters...",
                  hintStyle: TextStyle(
                    color: _C.grey400,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Solid black square filter button with tuning icon
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  color: _C.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.tune_rounded, size: 16, color: _C.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  KICK AVENUE-STYLE CATEGORY FILTER TABS
  //  Pure text, no icons — active tab has bold black text + underline
  //  Uses SingleChildScrollView + BouncingScrollPhysics
  // ══════════════════════════════════════════════════════════════
  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 36,
      child: SingleChildScrollView(
        key: const Key('category_tabs_scroll'),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _categoryTabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isActive = _selectedTab == tab;

            return GestureDetector(
              key: Key('category_tab_$index'),
              onTap: () {
                setState(() => _selectedTab = tab);
              },
              child: Padding(
                // Comfortable horizontal spacing between tabs
                padding: EdgeInsets.only(
                  right: index < _categoryTabs.length - 1 ? 24 : 0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tab label text
                    Text(
                      tab,
                      style: TextStyle(
                        color: isActive ? _C.black : _C.grey500,
                        fontSize: 13,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Active underline indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 2,
                      width: isActive ? 20 : 0,
                      decoration: BoxDecoration(
                        color: _C.black,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  D. COMPACT PROMO BANNER
  //  Minimalist light grey promo container
  //  Only ONE "Claim Voucher" CTA — no duplicate buttons
  // ══════════════════════════════════════════════════════════════
  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        key: const Key('promo_banner'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Promo text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Promo badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _C.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "LIMITED OFFER",
                      style: TextStyle(
                        color: _C.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Main promo copy
                  const Text(
                    "EUPHORIA DEALS II",
                    style: TextStyle(
                      color: _C.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Get 20% OFF for your first rental!",
                    style: TextStyle(
                      color: _C.grey500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Single prominent CTA: "Claim Voucher"
                  GestureDetector(
                    key: const Key('claim_voucher_button'),
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: _C.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Claim Voucher",
                        style: TextStyle(
                          color: _C.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Large decorative percentage text
            Text(
              "20%",
              style: TextStyle(
                color: _C.grey300.withOpacity(0.6),
                fontSize: 48,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  E. TRUST BADGES BAR
  //  Thin horizontal bar — soft mint green/teal background
  //  3 badges: "100% Premium", "Fresh & Clean", "Fast Delivery"
  // ══════════════════════════════════════════════════════════════
  Widget _buildTrustBadges() {
    return const SizedBox.shrink();
  }

  // ══════════════════════════════════════════════════════════════
  //  G. MAIN CATALOG GRID — 2-Column Portrait
  //  Section Title: "Costume Catalog" (font size 16, bold)
  // ══════════════════════════════════════════════════════════════
  Widget _buildCatalogHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        "Costume Catalog",
        style: TextStyle(
          color: _C.black,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildCatalogGrid() {
    // Filter costumes berdasarkan tab yang dipilih
    final filteredCostumes = _selectedTab == 'All'
        ? kCostumes
        : kCostumes
            .where((costume) => costume.category == _selectedTab)
            .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: filteredCostumes.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'No costumes available in this category',
                  style: TextStyle(
                    color: _C.grey500,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          : GridView.builder(
              key: const Key('costume_catalog_grid'),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: filteredCostumes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.60,
              ),
              itemBuilder: (context, index) =>
                  _CatalogProductCard(data: filteredCostumes[index]),
            ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  CATALOG PRODUCT CARD (Stateless for performance)
//  Each card: grey bg image, title, series, price, size, condition,
//  availability badge. Taps navigate to DetailCostumePage.
// ═══════════════════════════════════════════════════════════════════
class _CatalogProductCard extends StatelessWidget {
  final CostumeData data;
  const _CatalogProductCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('catalog_card_${data.title}'),
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
          // ── Image Canvas: 1:1 Square ──
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Layer 1: Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox.expand(
                      child: Image.asset(
                        data.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF5F5F5),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Color(0xFFBBB),
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Layer 3: Status Badge (Left Top)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: data.isReady ? _C.readyGreenBg : _C.rentedRedBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        data.isReady ? "Ready" : "Rented",
                        style: TextStyle(
                          color: data.isReady ? _C.readyGreen : _C.rentedRed,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  // Layer 2: Favorite Icon (Right Top)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _C.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        color: _C.black,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Typography Section ──
          const SizedBox(height: 10),

          // Series/Brand — Bold Black
          Text(
            data.series,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _C.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          // Costume Name — Dark Grey, 2 lines
          Text(
            data.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 12,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          // Label: "Lowest Rental Price"
          const Text(
            "Lowest Rental Price",
            style: TextStyle(
              color: Color(0xFF999999),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 2),

          // Price — Bold Black
          Text(
            "Rp ${data.price}",
            style: const TextStyle(
              color: _C.black,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
