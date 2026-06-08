import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'detail_costume_page.dart';

// =============================================
// TDD: Test-Driven Design Notes
// - Data model terpisah dari UI logic
// - Semua widget punya Key unik
// - State management terisolasi
// - Tidak ada hardcoded value
// =============================================

// ==================== DATA MODELS ====================
class CostumeData {
  final String title;
  final String series;
  final String price;
  final String condition;
  final String image;
  final String include;
  final String size; // e.g. "S|M|L|XL" atau "All Size"
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

  /// Daftar ukuran sebagai list. "All Size" → ['All Size']
  List<String> get sizeList {
    if (size == 'All Size') return ['All Size'];
    // Support format "L - XL", "S|M|L", "S, M, L", "M (Fit Body)"
    if (size.contains('|'))
      return size.split('|').map((s) => s.trim()).toList();
    if (size.contains(','))
      return size.split(',').map((s) => s.trim()).toList();
    if (size.contains(' - '))
      return size.split(' - ').map((s) => s.trim()).toList();
    return [size];
  }

  bool get hasMultipleSizes => sizeList.length > 1;

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

class CategoryData {
  final IconData icon;
  final String name;
  final Color accentColor;
  const CategoryData(
      {required this.icon, required this.name, required this.accentColor});
}

class EventData {
  final String title;
  final String date;
  final String location;
  final String image;
  final int attendees;
  const EventData(
      {required this.title,
      required this.date,
      required this.location,
      required this.image,
      required this.attendees});
}

// ==================== CONSTANTS ====================
class CosvoriaColors {
  static const Color bgColor = Color(0xFFFFFFFF);
  static const Color bgSurface = Color(0xFFF8F7F5);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color hairline = Color(0xFFEEECE8);
  static const Color hairlineStrong = Color(0xFFE5E5E0);
  static const Color textPrimary = Color(0xFF1C1917);
  static const Color textSecondary = Color(0xFF716B64);
  static const Color textTertiary = Color(0xFFA8A29E);
  static const Color accent = Color(0xFF0F9F7E);
  static const Color accentLight = Color(0xFFE6F7F4);
  static const Color accentWarm = Color(0xFFFF6B6B);
  static const Color accentGold = Color(0xFFD4A843);
  static const Color orbMint = Color(0xFF99E2CE);
  static const Color orbLavender = Color(0xFFD4C7EB);
  static const Color orbSky = Color(0xFFBCD5EF);
  static const Color orbRose = Color(0xFFF0CCD4);
  static const Color orbYellow = Color(0xFFFEF3C7);
}

// ==================== STATIC DATA ====================
const List<CategoryData> kCategories = [
  CategoryData(
      icon: Icons.whatshot_rounded,
      name: "Trending",
      accentColor: Color(0xFFFF6B6B)),
  CategoryData(
      icon: Icons.flash_on_rounded,
      name: "Anime",
      accentColor: Color(0xFF8B5CF6)),
  CategoryData(
      icon: Icons.sports_esports_rounded,
      name: "Games",
      accentColor: Color(0xFF0EA5E9)),
  CategoryData(
      icon: Icons.movie_filter_rounded,
      name: "Movies",
      accentColor: Color(0xFFEC4899)),
  CategoryData(
      icon: Icons.checkroom_rounded,
      name: "Armor",
      accentColor: Color(0xFFD4A843)),
  CategoryData(
      icon: Icons.school_rounded,
      name: "School",
      accentColor: Color(0xFF0F9F7E)),
  CategoryData(
      icon: Icons.auto_awesome_rounded,
      name: "Fantasy",
      accentColor: Color(0xFFD946EF)),
  CategoryData(
      icon: Icons.sports_martial_arts_rounded,
      name: "Hero",
      accentColor: Color(0xFFF59E0B)),
];

// Peta: nama kategori → list kostum yang tampil
// "Trending" = semua isReady=true, dihandle di logic

const List<CostumeData> kCostumes = [
  // ── ANIME ──────────────────────────────────────────────────────────────
  CostumeData(
    title: "Monkey D. Luffy (Wano)",
    series: "One Piece",
    price: "120.000",
    condition: "95%",
    image:
        "https://images.unsplash.com/photo-1601850494422-3cf16ebf66e7?q=80&w=800&auto=format&fit=crop",
    include: "Kimono Merah, Haori Motif Api, Topi Jerami, Sandal Kayu",
    size: "L|XL",
    isReady: true,
    category: "Anime",
    rating: 4.9,
    reviewCount: 34,
  ),
  CostumeData(
    title: "Satoru Gojo (Hidden Inventory)",
    series: "Jujutsu Kaisen",
    price: "145.000",
    condition: "98%",
    image:
        "https://images.unsplash.com/photo-1555680202-c86f0e12f086?q=80&w=800&auto=format&fit=crop",
    include: "Kemeja Hitam, Celana Panjang, Kacamata Hitam, Wig Putih",
    size: "S|M|L",
    isReady: false,
    category: "Anime",
    rating: 5.0,
    reviewCount: 58,
  ),
  CostumeData(
    title: "Nezuko Kamado Full Set",
    series: "Demon Slayer",
    price: "135.000",
    condition: "97%",
    image:
        "https://images.unsplash.com/photo-1578662996442-48f60103fc96?q=80&w=800&auto=format&fit=crop",
    include: "Kimono Pink, Obi Merah, Bambu Prop, Wig Hitam Panjang",
    size: "S|M",
    isReady: true,
    category: "Anime",
    rating: 4.8,
    reviewCount: 29,
  ),
  CostumeData(
    title: "Tanjiro Kamado",
    series: "Demon Slayer",
    price: "130.000",
    condition: "96%",
    image:
        "https://images.unsplash.com/photo-1580477667995-2b94f01c9516?q=80&w=800&auto=format&fit=crop",
    include: "Haori Kotak-kotak, Kimono Hitam, Wig, Anting Hanafuda",
    size: "S|M|L|XL",
    isReady: true,
    category: "Anime",
    rating: 4.7,
    reviewCount: 22,
  ),
  CostumeData(
    title: "Zero Two (002)",
    series: "Darling in the FranXX",
    price: "155.000",
    condition: "99%",
    image:
        "https://images.unsplash.com/photo-1528360983277-13d401cdc186?q=80&w=800&auto=format&fit=crop",
    include:
        "Seragam Merah, Bando Tanduk, Wig Merah Muda Panjang, Sarung Tangan",
    size: "S|M",
    isReady: true,
    category: "Anime",
    rating: 4.9,
    reviewCount: 41,
  ),

  // ── GAMES ──────────────────────────────────────────────────────────────
  CostumeData(
    title: "Link (Breath of The Wild)",
    series: "The Legend of Zelda",
    price: "160.000",
    condition: "93%",
    image:
        "https://images.unsplash.com/photo-1607853202273-797f1c22a38e?q=80&w=800&auto=format&fit=crop",
    include: "Kemeja Biru, Celana Coklat, Sabuk Kulit, Pedang & Perisai Prop",
    size: "M|L",
    isReady: true,
    category: "Games",
    rating: 4.6,
    reviewCount: 18,
  ),
  CostumeData(
    title: "Kratos (God of War)",
    series: "God of War",
    price: "200.000",
    condition: "91%",
    image:
        "https://images.unsplash.com/photo-1612198188060-c7c2a3b66eae?q=80&w=800&auto=format&fit=crop",
    include: "Armor Penuh, Cat Tubuh Abu, Kapak Leviathan Prop, Jubah",
    size: "L|XL",
    isReady: true,
    category: "Games",
    rating: 4.8,
    reviewCount: 15,
  ),
  CostumeData(
    title: "Jinx (Arcane)",
    series: "League of Legends / Arcane",
    price: "170.000",
    condition: "97%",
    image:
        "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=800&auto=format&fit=crop",
    include: "Jaket Biru, Celana Pendek, Wig Kepang Biru, Minigun Prop",
    size: "S|M|L",
    isReady: false,
    category: "Games",
    rating: 4.9,
    reviewCount: 27,
  ),

  // ── MOVIES ─────────────────────────────────────────────────────────────
  CostumeData(
    title: "Dalí Mask & Jumpsuit",
    series: "Money Heist (Netflix)",
    price: "100.000",
    condition: "90%",
    image:
        "https://images.unsplash.com/photo-1627455829638-3486be0092f2?q=80&w=800&auto=format&fit=crop",
    include: "Jumpsuit Merah, Topeng Dalí, Sarung Tangan, Prop Senjata",
    size: "All Size",
    isReady: true,
    category: "Movies",
    rating: 4.7,
    reviewCount: 21,
  ),
  CostumeData(
    title: "Spider-Man (Miles Morales)",
    series: "Marvel / Spider-Verse",
    price: "180.000",
    condition: "99%",
    image:
        "https://images.unsplash.com/photo-1635805737707-575885ab0820?q=80&w=800&auto=format&fit=crop",
    include: "Full Body Suit, Topeng Lensa, Jaket Hoodie, Celana Pendek",
    size: "S|M|L",
    isReady: true,
    category: "Movies",
    rating: 4.9,
    reviewCount: 47,
  ),
  CostumeData(
    title: "Thanos Armor Full",
    series: "Avengers: Endgame",
    price: "250.000",
    condition: "88%",
    image:
        "https://images.unsplash.com/photo-1559583985-c80d8ad9b29f?q=80&w=800&auto=format&fit=crop",
    include: "Full Armor Set, Helm, Sarung Tangan Infinity, Jubah Ungu",
    size: "XL",
    isReady: true,
    category: "Movies",
    rating: 4.5,
    reviewCount: 11,
  ),

  // ── ARMOR ──────────────────────────────────────────────────────────────
  CostumeData(
    title: "Dark Knight Armor",
    series: "Fantasy Original",
    price: "220.000",
    condition: "92%",
    image:
        "https://images.unsplash.com/photo-1578662996442-48f60103fc96?q=80&w=800&auto=format&fit=crop",
    include: "Full Plate Armor, Helm Bertanduk, Jubah Hitam, Perisai",
    size: "L|XL",
    isReady: true,
    category: "Armor",
    rating: 4.7,
    reviewCount: 9,
  ),
  CostumeData(
    title: "Spartan Warrior 300",
    series: "300 (Film)",
    price: "175.000",
    condition: "94%",
    image:
        "https://images.unsplash.com/photo-1612198188060-c7c2a3b66eae?q=80&w=800&auto=format&fit=crop",
    include: "Armor Perunggu, Helm Spartan, Perisai Merah, Tombak Prop",
    size: "M|L|XL",
    isReady: true,
    category: "Armor",
    rating: 4.6,
    reviewCount: 13,
  ),

  // ── SCHOOL ─────────────────────────────────────────────────────────────
  CostumeData(
    title: "Seragam UA High (Izuku)",
    series: "My Hero Academia",
    price: "110.000",
    condition: "96%",
    image:
        "https://images.unsplash.com/photo-1580477667995-2b94f01c9516?q=80&w=800&auto=format&fit=crop",
    include: "Jas Biru, Celana Panjang, Dasi, Emblem UA",
    size: "S|M|L",
    isReady: true,
    category: "School",
    rating: 4.8,
    reviewCount: 33,
  ),
  CostumeData(
    title: "Seragam Karasuno (Haikyuu)",
    series: "Haikyuu!!",
    price: "95.000",
    condition: "97%",
    image:
        "https://images.unsplash.com/photo-1555680202-c86f0e12f086?q=80&w=800&auto=format&fit=crop",
    include: "Jersey Hitam No.10, Celana Pendek, Knee Pad",
    size: "S|M|L|XL",
    isReady: false,
    category: "School",
    rating: 4.7,
    reviewCount: 26,
  ),

  // ── FANTASY ────────────────────────────────────────────────────────────
  CostumeData(
    title: "Emilia (Re:Zero)",
    series: "Re:Zero",
    price: "165.000",
    condition: "98%",
    image:
        "https://images.unsplash.com/photo-1528360983277-13d401cdc186?q=80&w=800&auto=format&fit=crop",
    include: "Gaun Putih Ungu, Mahkota Bunga, Wig Perak Panjang, Mantel",
    size: "S|M",
    isReady: true,
    category: "Fantasy",
    rating: 4.9,
    reviewCount: 38,
  ),
  CostumeData(
    title: "Gandalf the White",
    series: "Lord of the Rings",
    price: "140.000",
    condition: "90%",
    image:
        "https://images.unsplash.com/photo-1601850494422-3cf16ebf66e7?q=80&w=800&auto=format&fit=crop",
    include: "Jubah Panjang Putih, Topi Kerucut, Janggut, Tongkat Sihir",
    size: "L|XL",
    isReady: true,
    category: "Fantasy",
    rating: 4.5,
    reviewCount: 8,
  ),

  // ── HERO ───────────────────────────────────────────────────────────────
  CostumeData(
    title: "Batman (Dark Knight)",
    series: "DC Comics",
    price: "195.000",
    condition: "94%",
    image:
        "https://images.unsplash.com/photo-1559583985-c80d8ad9b29f?q=80&w=800&auto=format&fit=crop",
    include:
        "Full Bodysuit Hitam, Cape, Helm Telinga, Sabuk Utilitas, Batarang",
    size: "M|L|XL",
    isReady: true,
    category: "Hero",
    rating: 4.8,
    reviewCount: 31,
  ),
  CostumeData(
    title: "Wonder Woman",
    series: "DC Comics",
    price: "185.000",
    condition: "96%",
    image:
        "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=800&auto=format&fit=crop",
    include: "Armor Emas-Merah, Tiara, Lasso Prop, Perisai & Pedang",
    size: "S|M|L",
    isReady: true,
    category: "Hero",
    rating: 4.9,
    reviewCount: 24,
  ),
];

const List<EventData> kEvents = [
  EventData(
    title: "Indonesia Comic Con 2025",
    date: "14–16 Nov 2025",
    location: "JCC Senayan, Jakarta",
    image:
        "https://images.unsplash.com/photo-1612036782180-6f0b6cd846fe?q=80&w=800&auto=format&fit=crop",
    attendees: 1240,
  ),
  EventData(
    title: "Cosplay Euphoria Night",
    date: "30 Nov 2025",
    location: "Bandung Convention Centre",
    image:
        "https://images.unsplash.com/photo-1578662996442-48f60103fc96?q=80&w=800&auto=format&fit=crop",
    attendees: 320,
  ),
  EventData(
    title: "AniFest Yogyakarta",
    date: "7 Des 2025",
    location: "Jogja Expo Center",
    image:
        "https://images.unsplash.com/photo-1601814933824-fd0b574dd592?q=80&w=800&auto=format&fit=crop",
    attendees: 580,
  ),
];

// ==================== MAIN WIDGET ====================
class MainHomePage extends StatefulWidget {
  const MainHomePage({Key? key}) : super(key: key);
  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _selectedCategory = 0;
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();

  // ScrollController untuk scroll ke katalog
  final ScrollController _scrollController = ScrollController();
  // GlobalKey untuk katalog "Jelajahi Semua"
  final GlobalKey _catalogKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Scroll halus ke section katalog
  void _scrollToCatalog() {
    final ctx = _catalogKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
    }
  }

  /// Filter kostum berdasarkan kategori aktif
  List<CostumeData> get _filteredCostumes {
    final catName = kCategories[_selectedCategory].name;
    if (catName == 'Trending') {
      return kCostumes.where((c) => c.isReady).toList();
    }
    return kCostumes.where((c) => c.category == catName).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('main_home_page_scaffold'),
      backgroundColor: CosvoriaColors.bgColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildAnimatedOrbs(),
          _buildMainContent(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── APP BAR ──────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      key: const Key('cosvoria_app_bar'),
      backgroundColor: Colors.white.withOpacity(0.92),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                color: CosvoriaColors.textPrimary,
                borderRadius: BorderRadius.circular(7)),
            child: const Center(
              child: Text("C",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      fontFamily: 'Georgia')),
            ),
          ),
          const SizedBox(width: 8),
          const Text("COSVORIA",
              style: TextStyle(
                  color: CosvoriaColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  fontSize: 16,
                  fontFamily: 'Georgia')),
        ],
      ),
      centerTitle: false,
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              key: const Key('notification_button'),
              icon: const Icon(Icons.notifications_none_rounded,
                  color: CosvoriaColors.textPrimary),
              onPressed: () {},
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: CosvoriaColors.accentWarm, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 4),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: CosvoriaColors.hairlineStrong, width: 1.5)),
            child: const CircleAvatar(
              radius: 14,
              backgroundColor: CosvoriaColors.bgSurface,
              child: Icon(Icons.person_rounded,
                  color: CosvoriaColors.textSecondary, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  // ── ANIMATED ORBS ─────────────────────────────────────────────────────
  Widget _buildAnimatedOrbs() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final t = _animationController.value * 2 * math.pi;
        return Stack(children: [
          _orb(
              top: -40 + math.cos(t) * 50,
              right: -40 + math.sin(t) * 60,
              size: 280,
              color: CosvoriaColors.orbLavender,
              opacity: 0.20),
          _orb(
              top: 280 + math.sin(t * 1.2) * 60,
              right: -100 + math.cos(t * 1.2) * 70,
              size: 340,
              color: CosvoriaColors.orbSky,
              opacity: 0.20),
          _orb(
              top: 520 + math.cos(t * 0.7) * 60,
              left: -80 + math.sin(t * 0.7) * 80,
              size: 300,
              color: CosvoriaColors.orbRose,
              opacity: 0.18),
          _orb(
              bottom: -80 + math.sin(t * 0.9) * 80,
              right: -60 + math.cos(t * 0.9) * 60,
              size: 350,
              color: CosvoriaColors.orbMint,
              opacity: 0.18),
          _orb(
              top: 800 + math.sin(t * 1.1) * 50,
              left: -30 + math.cos(t * 1.1) * 40,
              size: 250,
              color: CosvoriaColors.orbYellow,
              opacity: 0.15),
        ]);
      },
    );
  }

  Widget _orb(
      {double? top,
      double? bottom,
      double? left,
      double? right,
      required double size,
      required Color color,
      required double opacity}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            color.withOpacity(opacity),
            color.withOpacity(opacity * 0.2),
            Colors.transparent,
          ], stops: const [
            0.0,
            0.5,
            1.0
          ]),
        ),
      ),
    );
  }

  // ── MAIN CONTENT ──────────────────────────────────────────────────────
  Widget _buildMainContent() {
    return SingleChildScrollView(
      key: const Key('home_scroll_view'),
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreeting(),
          _buildSearchBar(),
          const SizedBox(height: 20),
          _buildCategoryChips(),
          const SizedBox(height: 20),
          _buildHeroBanner(),
          const SizedBox(height: 20),
          _buildBenefitBadges(),
          const SizedBox(height: 28),
          _buildSectionHeader("Lagi Rame Disewa 🔥", "Lihat Semua"),
          const SizedBox(height: 14),
          _buildHorizontalCostumeList(
              kCostumes.where((c) => c.isReady).take(6).toList()),
          const SizedBox(height: 32),
          _buildFlashRentalBanner(),
          const SizedBox(height: 32),
          _buildSectionHeader("Baru Mendarat ✨", "Lihat Semua"),
          const SizedBox(height: 14),
          _buildHorizontalCostumeList(kCostumes.reversed.take(6).toList()),
          const SizedBox(height: 32),
          _buildEventSection(),
          const SizedBox(height: 32),
          _buildCosplayerReviewSection(),
          const SizedBox(height: 32),
          // ── "Jelajahi Semua" dengan filter ─────────────────────────
          _buildSectionHeader("Jelajahi Semua", "Filter"),
          const SizedBox(height: 14),
          // Category pill row sebagai filter "Jelajahi Semua"
          _buildFilterPillRow(),
          const SizedBox(height: 14),
          // Grid hasil filter — key dipasang di sini untuk scroll target
          SizedBox(key: _catalogKey, child: _buildCostumeGrid()),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  // ── GREETING ──────────────────────────────────────────────────────────
  Widget _buildGreeting() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: CosvoriaColors.accentLight,
                borderRadius: BorderRadius.circular(99)),
            child: Row(children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 12, color: CosvoriaColors.accent),
              const SizedBox(width: 4),
              const Text("Cosplay Euphoria Mode",
                  style: TextStyle(
                      color: CosvoriaColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3)),
            ]),
          ),
          const SizedBox(height: 10),
          const Text("Halo, Cosplayer! ✨",
              style: TextStyle(
                  color: CosvoriaColors.textSecondary,
                  fontSize: 14,
                  fontFamily: 'Inter')),
          const SizedBox(height: 4),
          RichText(
            text: const TextSpan(children: [
              TextSpan(
                  text: "Siap menjadi ",
                  style: TextStyle(
                      color: CosvoriaColors.textPrimary,
                      fontFamily: 'Georgia',
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.5,
                      height: 1.2)),
              TextSpan(
                  text: "siapa",
                  style: TextStyle(
                      color: CosvoriaColors.textPrimary,
                      fontFamily: 'Georgia',
                      fontSize: 26,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                      height: 1.2)),
              TextSpan(
                  text: " hari ini?",
                  style: TextStyle(
                      color: CosvoriaColors.textPrimary,
                      fontFamily: 'Georgia',
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.5,
                      height: 1.2)),
            ]),
          ),
        ],
      ),
    );
  }

  // ── SEARCH BAR ────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: CosvoriaColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: CosvoriaColors.hairlineStrong),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(children: [
          const SizedBox(width: 16),
          const Icon(Icons.search_rounded,
              color: CosvoriaColors.textTertiary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              key: const Key('search_field'),
              controller: _searchController,
              style: const TextStyle(
                  color: CosvoriaColors.textPrimary,
                  fontFamily: 'Inter',
                  fontSize: 14),
              decoration: const InputDecoration(
                hintText: "Cari kostum, anime, atau karakter...",
                hintStyle: TextStyle(
                    color: CosvoriaColors.textTertiary,
                    fontSize: 13,
                    fontFamily: 'Inter'),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: CosvoriaColors.textPrimary,
                borderRadius: BorderRadius.circular(9)),
            child:
                const Icon(Icons.tune_rounded, size: 16, color: Colors.white),
          ),
        ]),
      ),
    );
  }

  // ── CATEGORY CHIPS ────────────────────────────────────────────────────
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        key: const Key('category_list'),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: kCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final cat = kCategories[index];
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            key: Key('category_chip_$index'),
            onTap: () {
              setState(() => _selectedCategory = index);
              // Scroll ke katalog saat tap kategori
              Future.delayed(
                  const Duration(milliseconds: 80), _scrollToCatalog);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? CosvoriaColors.textPrimary
                        : CosvoriaColors.cardBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isSelected
                            ? CosvoriaColors.textPrimary
                            : CosvoriaColors.hairlineStrong,
                        width: isSelected ? 2 : 1),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                                color: CosvoriaColors.textPrimary
                                    .withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ]
                        : [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 5,
                                offset: const Offset(0, 2))
                          ],
                  ),
                  child: Icon(cat.icon,
                      color: isSelected
                          ? Colors.white
                          : CosvoriaColors.textSecondary,
                      size: 24),
                ),
                const SizedBox(height: 7),
                Text(cat.name,
                    style: TextStyle(
                        color: isSelected
                            ? CosvoriaColors.textPrimary
                            : CosvoriaColors.textSecondary,
                        fontSize: 11,
                        fontFamily: 'Inter',
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── HERO BANNER ───────────────────────────────────────────────────────
  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        // FIX: gunakan IntrinsicHeight agar tidak overflow
        decoration: BoxDecoration(
          color: CosvoriaColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CosvoriaColors.hairlineStrong),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 24,
                offset: const Offset(0, 12))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final t = _animationController.value * 2 * math.pi;
              final dx = math.sin(t * 1.5) * 25;
              final dy = math.cos(t * 2.0) * 15;
              return Stack(children: [
                Positioned(
                  right: -50 + dx,
                  top: -50 + dy,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        CosvoriaColors.orbLavender.withOpacity(0.35),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),
                Positioned(
                  left: -30 - dx * 0.5,
                  bottom: -40 - dy * 0.5,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        CosvoriaColors.orbMint.withOpacity(0.3),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),
                child!,
              ]);
            },
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize:
                    MainAxisSize.min, // ← FIX overflow: min bukan expand
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                        color: CosvoriaColors.textPrimary,
                        borderRadius: BorderRadius.circular(5)),
                    child: const Text("EUPHORIA DEALS ✦",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5)),
                  ),
                  const SizedBox(height: 12),
                  const Text("Cosvoria\nRealm",
                      style: TextStyle(
                          color: CosvoriaColors.textPrimary,
                          fontFamily: 'Georgia',
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.5,
                          height: 1.1)),
                  const SizedBox(height: 10),
                  const Text(
                      "Masuki alter ego fantasi Anda.\nDiskon 20% untuk rental pertama!",
                      style: TextStyle(
                          color: CosvoriaColors.textSecondary,
                          fontFamily: 'Inter',
                          fontSize: 12,
                          height: 1.5)),
                  const SizedBox(height: 18),
                  Row(children: [
                    GestureDetector(
                      key: const Key('claim_voucher_button'),
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                            color: CosvoriaColors.textPrimary,
                            borderRadius: BorderRadius.circular(999)),
                        child: const Text("Klaim Voucher",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      key: const Key('sewa_sekarang_button'),
                      onTap: _scrollToCatalog, // ← scroll ke katalog
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border:
                              Border.all(color: CosvoriaColors.hairlineStrong),
                        ),
                        child: const Text("Sewa Sekarang",
                            style: TextStyle(
                                color: CosvoriaColors.textSecondary,
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── BENEFIT BADGES ────────────────────────────────────────────────────
  Widget _buildBenefitBadges() {
    final benefits = [
      {"icon": Icons.verified_rounded, "title": "100% Ori/Premium"},
      {"icon": Icons.dry_cleaning_rounded, "title": "Pasti Wangi"},
      {"icon": Icons.local_shipping_rounded, "title": "Kirim Cepat"},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: CosvoriaColors.accentLight,
            borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: benefits
              .map((b) => Row(children: [
                    Icon(b['icon'] as IconData,
                        size: 15, color: CosvoriaColors.accent),
                    const SizedBox(width: 5),
                    Text(b['title'] as String,
                        style: const TextStyle(
                            color: CosvoriaColors.accent,
                            fontSize: 11,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600)),
                  ]))
              .toList(),
        ),
      ),
    );
  }

  // ── FLASH RENTAL BANNER ───────────────────────────────────────────────
  Widget _buildFlashRentalBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
        decoration: BoxDecoration(
            color: CosvoriaColors.textPrimary,
            borderRadius: BorderRadius.circular(18)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: CosvoriaColors.accentWarm,
                        borderRadius: BorderRadius.circular(4)),
                    child: const Text("⚡ FLASH RENTAL",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                  ),
                  const SizedBox(height: 10),
                  const Text("Sewa 3 hari,\ndapat 5 hari!",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Georgia',
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          height: 1.2)),
                  const SizedBox(height: 8),
                  Text("Hanya sampai 31 Des 2025 · Berlaku semua kostum",
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontFamily: 'Inter',
                          fontSize: 11,
                          height: 1.5)),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: _scrollToCatalog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999)),
                      child: const Text("Sewa Sekarang",
                          style: TextStyle(
                              color: CosvoriaColors.textPrimary,
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text("+2",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.08),
                    fontSize: 72,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w900,
                    height: 1)),
          ],
        ),
      ),
    );
  }

  // ── EVENT SECTION ─────────────────────────────────────────────────────
  Widget _buildEventSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Event Cosplay 🎭", "Semua Event"),
        const SizedBox(height: 14),
        SizedBox(
          height: 178,
          child: ListView.separated(
            key: const Key('event_list'),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: kEvents.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) => _buildEventCard(kEvents[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(EventData event) {
    return Container(
      key: Key('event_card_${event.title}'),
      width: 240,
      decoration: BoxDecoration(
        color: CosvoriaColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CosvoriaColors.hairlineStrong),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 96,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              image: DecorationImage(
                  image: NetworkImage(event.image), fit: BoxFit.cover),
            ),
            child: Stack(children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3)
                      ]),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: CosvoriaColors.accentWarm,
                      borderRadius: BorderRadius.circular(99)),
                  child: Text("${event.attendees} hadir",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(event.title,
                  style: const TextStyle(
                      color: CosvoriaColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 5),
              Row(children: [
                const Icon(Icons.calendar_month_outlined,
                    size: 12, color: CosvoriaColors.textTertiary),
                const SizedBox(width: 4),
                Text(event.date,
                    style: const TextStyle(
                        color: CosvoriaColors.textSecondary,
                        fontSize: 11,
                        fontFamily: 'Inter')),
              ]),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.location_on_outlined,
                    size: 12, color: CosvoriaColors.textTertiary),
                const SizedBox(width: 4),
                Expanded(
                    child: Text(event.location,
                        style: const TextStyle(
                            color: CosvoriaColors.textSecondary,
                            fontSize: 11,
                            fontFamily: 'Inter'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
              ]),
            ]),
          ),
        ],
      ),
    );
  }

  // ── REVIEW SECTION ────────────────────────────────────────────────────
  Widget _buildCosplayerReviewSection() {
    final reviews = [
      {
        "name": "Rina S.",
        "avatar": "R",
        "avatarColor": const Color(0xFFE8D5F5),
        "avatarText": const Color(0xFF8B5CF6),
        "text":
            "Kostum Gojo-nya beneran premium banget, wig-nya halus! Pasti balik lagi.",
        "rating": 5,
        "costume": "Satoru Gojo"
      },
      {
        "name": "Bagas P.",
        "avatar": "B",
        "avatarColor": const Color(0xFFD1FAE5),
        "avatarText": const Color(0xFF0F9F7E),
        "text":
            "Pengiriman cepat, kondisi kostum 98% sesuai deskripsi. Recommended!",
        "rating": 5,
        "costume": "Miles Morales"
      },
      {
        "name": "Tiara A.",
        "avatar": "T",
        "avatarColor": const Color(0xFFFFE4E6),
        "avatarText": const Color(0xFFFF6B6B),
        "text":
            "Suka banget sama set Nezuko-nya. Detail kimono sangat oke untuk foto cosplay.",
        "rating": 5,
        "costume": "Nezuko Kamado"
      },
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Kata Mereka 💬", "Semua Review"),
        const SizedBox(height: 14),
        SizedBox(
          height: 148,
          child: ListView.separated(
            key: const Key('review_list'),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final r = reviews[index];
              return Container(
                key: Key('review_card_$index'),
                width: 230,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CosvoriaColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: CosvoriaColors.hairlineStrong),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: r['avatarColor'] as Color,
                          child: Text(r['avatar'] as String,
                              style: TextStyle(
                                  color: r['avatarText'] as Color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(r['name'] as String,
                                  style: const TextStyle(
                                      color: CosvoriaColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      fontFamily: 'Inter')),
                              Text(r['costume'] as String,
                                  style: const TextStyle(
                                      color: CosvoriaColors.textTertiary,
                                      fontSize: 10,
                                      fontFamily: 'Inter')),
                            ])),
                        Row(
                            children: List.generate(
                                r['rating'] as int,
                                (_) => const Icon(Icons.star_rounded,
                                    size: 11,
                                    color: CosvoriaColors.accentGold))),
                      ]),
                      const SizedBox(height: 10),
                      Text(r['text'] as String,
                          style: const TextStyle(
                              color: CosvoriaColors.textSecondary,
                              fontSize: 11.5,
                              fontFamily: 'Inter',
                              height: 1.5),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis),
                    ]),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── HORIZONTAL COSTUME LIST ───────────────────────────────────────────
  Widget _buildHorizontalCostumeList(List<CostumeData> costumes) {
    return SizedBox(
      height: 310,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: costumes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) =>
            _buildPortraitCard(costumes[index], context),
      ),
    );
  }

  // ── FILTER PILL ROW (di "Jelajahi Semua") ────────────────────────────
  Widget _buildFilterPillRow() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: kCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            key: Key('filter_pill_$index'),
            onTap: () => setState(() => _selectedCategory = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? CosvoriaColors.textPrimary
                    : CosvoriaColors.cardBg,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                    color: isSelected
                        ? CosvoriaColors.textPrimary
                        : CosvoriaColors.hairlineStrong),
              ),
              child: Text(kCategories[index].name,
                  style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : CosvoriaColors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500)),
            ),
          );
        },
      ),
    );
  }

  // ── COSTUME GRID ──────────────────────────────────────────────────────
  Widget _buildCostumeGrid() {
    final filtered = _filteredCostumes;
    if (filtered.isEmpty) {
      return Padding(
        // <--- HAPUS 'const' di sini
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 40), // Pindah ke sini
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              // <--- Tambahkan 'const' di sini untuk isi list
              Icon(Icons.search_off_rounded,
                  size: 40, color: CosvoriaColors.textTertiary),
              SizedBox(height: 12),
              Text(
                "Belum ada kostum di kategori ini.",
                style: TextStyle(
                  color: CosvoriaColors.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        key: Key('costume_grid_${kCategories[_selectedCategory].name}'),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: filtered.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisExtent: 320,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) =>
            _buildPortraitCard(filtered[index], context, isGrid: true),
      ),
    );
  }

  // ── SECTION HEADER ────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  color: CosvoriaColors.textPrimary,
                  fontFamily: 'Georgia',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2)),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                  color: CosvoriaColors.cardBg,
                  border: Border.all(color: CosvoriaColors.hairlineStrong),
                  borderRadius: BorderRadius.circular(9999)),
              child: Text(action,
                  style: const TextStyle(
                      color: CosvoriaColors.textSecondary,
                      fontSize: 11,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  // ── PORTRAIT CARD ─────────────────────────────────────────────────────
  Widget _buildPortraitCard(CostumeData data, BuildContext context,
      {bool isGrid = false}) {
    final double imgH = isGrid ? 170 : 180;
    final double cardW = isGrid ? double.infinity : 148.0;

    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Gambar
        Stack(children: [
          Container(
            height: imgH,
            width: cardW,
            decoration: BoxDecoration(
              color: CosvoriaColors.bgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: CosvoriaColors.hairline),
              image: DecorationImage(
                  image: NetworkImage(data.image),
                  fit: BoxFit.cover,
                  onError: (_, __) {}),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ],
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                  color: data.isReady
                      ? CosvoriaColors.textPrimary
                      : CosvoriaColors.bgSurface,
                  borderRadius: BorderRadius.circular(99),
                  border: data.isReady
                      ? null
                      : Border.all(color: CosvoriaColors.hairlineStrong)),
              child: Text(data.isReady ? "Ready" : "Disewa",
                  style: TextStyle(
                      color: data.isReady
                          ? Colors.white
                          : CosvoriaColors.textSecondary,
                      fontSize: 9,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700)),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(99)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.star_rounded,
                    size: 10, color: CosvoriaColors.accentGold),
                const SizedBox(width: 2),
                Text(data.rating.toStringAsFixed(1),
                    style: const TextStyle(
                        color: CosvoriaColors.textPrimary,
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 9),
        // ── Judul
        Text(data.title,
            style: const TextStyle(
                color: CosvoriaColors.textPrimary,
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        // ── Harga
        Text("Rp ${data.price} / 3 hari",
            style: const TextStyle(
                color: CosvoriaColors.accent,
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        // ── Series
        Row(children: [
          const Icon(Icons.movie_creation_outlined,
              size: 11, color: CosvoriaColors.textTertiary),
          const SizedBox(width: 4),
          Expanded(
              child: Text(data.series,
                  style: const TextStyle(
                      color: CosvoriaColors.textSecondary,
                      fontSize: 10,
                      fontFamily: 'Inter'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
        ]),
        const SizedBox(height: 8),
        // ── Tombol pilih ukuran (jika > 1 ukuran)
        if (data.hasMultipleSizes)
          _SizeSelectorInline(sizeList: data.sizeList)
        else
          _buildTag(data.size),
      ],
    );

    return GestureDetector(
      key: Key('costume_card_${data.title}'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  DetailCostumePage(costumeData: data.toMap())),
        );
      },
      child: isGrid ? cardContent : SizedBox(width: 148, child: cardContent),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: CosvoriaColors.bgSurface,
          border: Border.all(color: CosvoriaColors.hairline),
          borderRadius: BorderRadius.circular(9999)),
      child: Text(label,
          style: const TextStyle(
              color: CosvoriaColors.textSecondary,
              fontSize: 9,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600)),
    );
  }

  // ── BOTTOM NAV ────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(color: CosvoriaColors.hairlineStrong, width: 1))),
      child: BottomNavigationBar(
        key: const Key('bottom_nav'),
        backgroundColor: CosvoriaColors.cardBg,
        elevation: 0,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: CosvoriaColors.textPrimary,
        unselectedItemColor: CosvoriaColors.textTertiary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter'),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Inter'),
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.home_filled)),
              label: "Home"),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.search_rounded)),
              label: "Browse"),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.calendar_month_outlined)),
              label: "Events"),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.favorite_border_rounded)),
              label: "Saved"),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.person_outline_rounded)),
              label: "Profil"),
        ],
      ),
    );
  }
}

// =============================================
// Stateful inline size selector
// Menampilkan chip ukuran di dalam card;
// state lokal agar tidak rebuild seluruh halaman.
// =============================================
class _SizeSelectorInline extends StatefulWidget {
  final List<String> sizeList;
  const _SizeSelectorInline({required this.sizeList});

  @override
  State<_SizeSelectorInline> createState() => _SizeSelectorInlineState();
}

class _SizeSelectorInlineState extends State<_SizeSelectorInline> {
  int _selected = -1; // -1 = belum pilih

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Ukuran:",
            style: TextStyle(
                color: CosvoriaColors.textTertiary,
                fontSize: 9,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: List.generate(widget.sizeList.length, (i) {
            final isChosen = _selected == i;
            return GestureDetector(
              key: Key('size_chip_${widget.sizeList[i]}'),
              onTap: () {
                setState(() => _selected = i);
                // cegah bubble tap ke GestureDetector parent (navigate)
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isChosen
                      ? CosvoriaColors.textPrimary
                      : CosvoriaColors.bgSurface,
                  border: Border.all(
                      color: isChosen
                          ? CosvoriaColors.textPrimary
                          : CosvoriaColors.hairlineStrong),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(widget.sizeList[i],
                    style: TextStyle(
                        color: isChosen
                            ? Colors.white
                            : CosvoriaColors.textSecondary,
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700)),
              ),
            );
          }),
        ),
      ],
    );
  }
}
