import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_mopro/features/customer/pages/booking_page.dart';
import 'package:project_mopro/core/managers/wishlist_manager.dart';
import 'package:intl/intl.dart';
import 'package:project_mopro/features/customer/pages/review_details_page.dart';

class DetailCostumePage extends StatefulWidget {
  final Map<String, dynamic> costumeData;

  const DetailCostumePage({Key? key, required this.costumeData})
      : super(key: key);

  @override
  State<DetailCostumePage> createState() => _DetailCostumePageState();
}

class _DetailCostumePageState extends State<DetailCostumePage>
    with SingleTickerProviderStateMixin {
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  DESIGN SYSTEM â€” Clean, Light, Minimalist (Kick Avenue Ã— Zara)
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  static const Color _bgColor = Color(0xFFFAFAFA);
  static const Color _surfaceColor = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF78716C);
  static const Color _textTertiary = Color(0xFFA8A29E);
  static const Color _hairline = Color(0xFFE7E5E4);
  static const Color _accentGreen = Color(0xFF16A34A);
  static const Color _accentGreenBg = Color(0xFFDCFCE7);
  static const Color _accentRed = Color(0xFFDC2626);
  static const Color _accentRedBg = Color(0xFFFEE2E2);
  static const Color _gold = Color(0xFFF59E0B);


  late String _selectedSize;
  late AnimationController _favController;
  late Animation<double> _favScale;
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  // Shortcut accessor
  Map<String, dynamic> get data => widget.costumeData;
  bool get isReady => data['isReady'] == true;
  
  List<String> get images {
    if (data['images'] != null && data['images'] is List) {
      return List<String>.from(data['images']);
    } else if (data['image'] != null) {
      return [data['image']];
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    // Inisialisasi size dari data kostum, fallback ke 'M'
    _selectedSize = _normalizeSize(widget.costumeData['size'] ?? 'M');
    _favController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _favScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _favController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _favController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    WishlistManager.instance.toggleWishlist(data['title']);
    _favController.forward().then((_) => _favController.reverse());
    HapticFeedback.lightImpact();
  }

  Future<void> _checkIdentityAndProceed(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showVerificationDialog(
        context,
        title: 'Login Required',
        message: 'Please login first before renting a costume.',
        icon: Icons.login_rounded,
      );
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      final data = doc.data();
      final status = data?['verificationStatus']?.toString() ?? 'unverified';

      if (status == 'approved') {
        // Verified — proceed to booking
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingPage(costumeData: this.data),
          ),
        );
      } else if (status == 'pending') {
        _showVerificationDialog(
          context,
          title: 'Verification Pending',
          message:
              'Your identity verification is still being reviewed. Please wait for admin approval before renting costumes.',
          icon: Icons.hourglass_top_rounded,
        );
      } else {
        _showVerificationDialog(
          context,
          title: 'Identity Verification Required',
          message:
              'You must verify your identity (KTP) before renting costumes. Go to Profile → Verify Identity to submit your KTP number.',
          icon: Icons.verified_user_outlined,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to check verification status. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showVerificationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: const Color(0xFFF59E0B)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF78716C),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Understood',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  BUILD
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // â”€â”€ Scrollable Content â”€â”€
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(child: _buildMainInfo()),
              SliverToBoxAdapter(child: _buildRatingRow()),
              SliverToBoxAdapter(child: _buildDivider()),
              SliverToBoxAdapter(child: _buildPriceSection()),
              SliverToBoxAdapter(child: _buildDivider()),
              SliverToBoxAdapter(child: _buildSpecifications()),
              SliverToBoxAdapter(child: _buildDivider()),
              SliverToBoxAdapter(child: _buildConditionMinus()),
              SliverToBoxAdapter(child: _buildDivider()),
              SliverToBoxAdapter(child: _buildSizeGuide()),
              SliverToBoxAdapter(child: _buildDivider()),
              SliverToBoxAdapter(child: _buildShippingInfo()),
              SliverToBoxAdapter(child: _buildDivider()),
              SliverToBoxAdapter(child: _buildIncludeList()),
              SliverToBoxAdapter(child: _buildTrustBanner()),
              SliverToBoxAdapter(child: _buildRentalPolicy()),
              SliverToBoxAdapter(child: _buildDivider()),
              SliverToBoxAdapter(child: _buildCustomerReviews()),
              // Bottom padding so content doesnt hide behind sticky bar
              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          ),

          // â”€â”€ Sticky Bottom Action Bar â”€â”€
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildStickyBottomBar(context),
          ),
        ],
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  1. SLIVER APP BAR â€” Collapsible Header Image
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 460,
      pinned: true,
      stretch: true,
      backgroundColor: _surfaceColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      // â”€â”€ Leading: Back Button â”€â”€
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _circleButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
      ),
      // â”€â”€ Actions: Share & Favorite â”€â”€
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: _circleButton(
            icon: Icons.share_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Link kostum disalin!'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, right: 8.0),
          child: ValueListenableBuilder<List<String>>(
            valueListenable: WishlistManager.instance.wishlistNotifier,
            builder: (context, wishlist, _) {
              final isLiked = wishlist.contains(data['title']);
              return ScaleTransition(
                scale: _favScale,
                child: _circleButton(
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  iconColor: isLiked ? _accentRed : _textPrimary,
                  onTap: _toggleFavorite,
                ),
              );
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // â”€â”€ Hero Image Carousel â”€â”€
            images.isNotEmpty
                ? PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final imageUrl = images[index];
                      final isNetwork = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
                      
                      if (isNetwork) {
                        return Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: _bgColor,
                            child: const Center(
                              child: Icon(Icons.broken_image_outlined,
                                  size: 48, color: _textTertiary),
                            ),
                          ),
                        );
                      } else {
                        return Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: _bgColor,
                            child: const Center(
                              child: Icon(Icons.broken_image_outlined,
                                  size: 48, color: _textTertiary),
                            ),
                          ),
                        );
                      }
                    },
                  )
                : Container(
                    color: _bgColor,
                    child: const Center(
                      child: Icon(Icons.image_outlined,
                          size: 48, color: _textTertiary),
                    ),
                  ),

            // â”€â”€ Top gradient for status bar readability â”€â”€
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.30),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // â”€â”€ Bottom gradient for smooth transition â”€â”€
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      _bgColor.withOpacity(0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // â”€â”€ Image counter badge â”€â”€
            if (images.isNotEmpty)
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_library_outlined, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '${_currentImageIndex + 1} / ${images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  2. MAIN PRODUCT INFO â€” Badge, Title, Series
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildMainInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isReady ? _accentGreenBg : _accentRedBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isReady ? 'READY TO RENT' : 'RENTED',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: isReady ? _accentGreen : _accentRed,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            data['title'] ?? 'Nama Kostum',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),

          // Series
          Text(
            (data['series'] ?? 'Unknown Series').toString().toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
              letterSpacing: 2.5,
            ),
          ),
        ],
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  RATING ROW â€” Stars + Condition
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildRatingRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          // Stars
          ...List.generate(5, (i) {
            return Icon(
              i < 4 ? Icons.star_rounded : Icons.star_half_rounded,
              size: 18,
              color: _gold,
            );
          }),
          const SizedBox(width: 6),
          const Text(
            '4.9',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            '(52 Ulasan)',
            style: TextStyle(
              fontSize: 12,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  PRICE SECTION
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildPriceSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _hairline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HARGA SEWA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: _textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Rp ${data['price'] ?? '0'}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '/ 3 Hari',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _hairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'WAJIB DEPOSIT',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: _textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rp ${data['deposit'] ?? '50.000'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  3. SIZE GUIDE â€” Interactive Size Selector
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  static const List<String> _availableSizes = ['S', 'M', 'L', 'XL'];

  /// Normalisasi nilai size dari data ke salah satu opsi valid.
  /// Contoh: "S|M" â†’ "S", "All Size" â†’ "M", "l" â†’ "L"
  String _normalizeSize(String raw) {
    final s = raw.toUpperCase().trim();
    if (s == 'XL') return 'XL';
    if (s == 'L') return 'L';
    if (s.contains('S')) return 'S';
    if (s.contains('M')) return 'M';
    return 'M'; // fallback default
  }

  Widget _buildSizeGuide() {
    // Ambil info ukuran berdasarkan size yang sedang aktif dipilih
    final sizeInfo = _getSizeInfo(_selectedSize);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // â”€â”€ Header: Judul + Size Chips â”€â”€
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.straighten_rounded, size: 18, color: _textPrimary),
                  SizedBox(width: 8),
                  Text(
                    'Panduan Ukuran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                ],
              ),
              // â”€â”€ Interactive Size Chips â”€â”€
              Row(
                mainAxisSize: MainAxisSize.min,
                children: _availableSizes.map((s) {
                  final bool isActive = _selectedSize == s;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: GestureDetector(
                      onTap: () {
                        if (_selectedSize != s) {
                          setState(() => _selectedSize = s);
                          HapticFeedback.selectionClick();
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        width: 40,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isActive ? _textPrimary : _surfaceColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isActive ? _textPrimary : _hairline,
                            width: isActive ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          s,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isActive ? Colors.white : _textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // â”€â”€ Size Detail Boxes â€” 3 horizontal cards â”€â”€
          Row(
            children: [
              _sizeDetailCard(
                icon: Icons.expand_rounded,
                label: 'Lebar Dada (LD)',
                value: sizeInfo['LD']!,
              ),
              const SizedBox(width: 10),
              _sizeDetailCard(
                icon: Icons.height_rounded,
                label: 'Panjang Baju',
                value: sizeInfo['Panjang']!,
              ),
              const SizedBox(width: 10),
              _sizeDetailCard(
                icon: Icons.person_outline_rounded,
                label: 'Tinggi Badan',
                value: sizeInfo['TB']!,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Fit Notes
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.straighten_rounded, size: 16, color: _textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data['fit_notes'] ?? 'Fit Notes: Kostum ini true to size, namun bagian lingkar dada sedikit sempit. Bahan tidak stretch.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    }
    Widget _sizeDetailCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _hairline),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: _textSecondary),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _textTertiary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                value,
                key: ValueKey<String>(value),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mapping ukuran dinamis berdasarkan standar kostum cosplay.
  Map<String, String> _getSizeInfo(String size) {
    switch (size) {
      case 'XL':
        return {
          'LD': '104 - 110 cm',
          'Panjang': '125 cm',
          'TB': '170 - 180 cm',
        };
      case 'L':
        return {
          'LD': '96 - 102 cm',
          'Panjang': '120 cm',
          'TB': '160 - 170 cm',
        };
      case 'S':
      case 'M':
      default:
        return {
          'LD': '90 - 95 cm',
          'Panjang': '115 cm',
          'TB': '150 - 160 cm',
        };
    }
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  4. KELENGKAPAN PAKET SEWA â€” Bullet Points
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildIncludeList() {
    final String rawInclude =
        data['include'] ?? 'Tidak ada deskripsi kelengkapan';
    final List<String> items =
        rawInclude.split(', ').where((e) => e.trim().isNotEmpty).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.inventory_2_outlined, size: 18, color: _textPrimary),
              SizedBox(width: 8),
              Text(
                'Kelengkapan Paket Sewa',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _hairline),
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final isLast = entry.key == items.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _accentGreenBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: _accentGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value.trim(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  5. TRUST & HYGIENE BANNER
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildTrustBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFECFDF5), // mint/emerald very light
              Color(0xFFF0FDFA), // teal very light
              Color(0xFFECFEFF), // cyan very light
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD1FAE5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFA7F3D0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_laundry_service_rounded,
                size: 22,
                color: Color(0xFF059669),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Higienis & Siap Pakai',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF065F46),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kostum sudah dicuci dengan laundry profesional, wangi, dan wig sudah di\u2011styling ulang \u2014 siap pakai langsung!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF047857),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  NEW HELPER SECTIONS: Specs, Condition, Shipping
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildSpecifications() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.style_outlined, size: 18, color: _textPrimary),
              SizedBox(width: 8),
              Text(
                'Spesifikasi Kostum',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _specItem(
                  label: 'Brand / Maker',
                  value: data['maker'] ?? 'Uwowo Cosplay / Setara',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _specItem(
                  label: 'Bahan Utama',
                  value: data['material'] ?? 'Premium Jacquard & Katun',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _specItem(
                  label: 'Berat Kostum',
                  value: data['weight'] ?? '1.2 kg',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _specItem(
                  label: 'Detail Ekstra',
                  value: data['extra_details'] ?? 'Wig pre-styled (Manmei)',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _specItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildConditionMinus() {
    final String minus = data['minus'] ?? 'Secara keseluruhan mulus (90%). Terdapat sedikit noda pudar di bagian kerah dalam (tidak terlihat saat dipakai), dan 1 aksesoris kecil diganti baru.';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline_rounded, size: 18, color: _accentRed),
              SizedBox(width: 8),
              Text(
                'Kondisi & Defect (Minus)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _accentRedBg.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Text(
              minus,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF991B1B), // Dark red
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInfo() {
    final String location = data['location'] ?? 'Jakarta Selatan, DKI Jakarta';
    final bool canInstant = data['can_instant'] ?? true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.local_shipping_outlined, size: 18, color: _textPrimary),
              SizedBox(width: 8),
              Text(
                'Pengiriman & Lokasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: _hairline),
                ),
                child: const Icon(Icons.location_on_outlined, size: 20, color: _textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dikirim dari',
                      style: TextStyle(fontSize: 11, color: _textTertiary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    if (canInstant) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(Icons.bolt_rounded, size: 12, color: _gold),
                          SizedBox(width: 4),
                          Text(
                            'Mendukung Kurir Instan (GoSend/Grab)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _gold,
                            ),
                          ),
                        ],
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  6. RENTAL & DEPOSIT POLICY
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildRentalPolicy() {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final depositVal = data['deposit'] ?? 50000;
    final depositAmt = depositVal is int ? depositVal : int.tryParse(depositVal.toString()) ?? 50000;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.assignment_outlined, size: 18, color: _textPrimary),
              SizedBox(width: 8),
              Text(
                'Ketentuan Sewa',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _hairline),
            ),
            child: Column(
              children: [
                _policyItem(
                  icon: Icons.shield_outlined,
                  iconBg: const Color(0xFFFEF3C7),
                  iconColor: const Color(0xFFD97706),
                  title: 'Wajib Deposit ${formatCurrency.format(depositAmt)}',
                  subtitle:
                      'Uang jaminan dikembalikan penuh 1x24 jam setelah kostum kami terima kembali dalam kondisi baik.',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(color: _hairline, height: 1),
                ),
                _policyItem(
                  icon: Icons.do_not_disturb_alt_outlined,
                  iconBg: const Color(0xFFE0E7FF),
                  iconColor: const Color(0xFF4F46E5),
                  title: 'Tidak Perlu Dicuci',
                  subtitle:
                      'Jangan mencuci kostum/wig sendiri untuk menghindari kerusakan. Kami yang akan mencucinya.',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(color: _hairline, height: 1),
                ),
                _policyItem(
                  icon: Icons.warning_amber_rounded,
                  iconBg: const Color(0xFFFEE2E2),
                  iconColor: const Color(0xFFDC2626),
                  title: 'Denda Keterlambatan & Kerusakan',
                  subtitle:
                      'Keterlambatan didenda Rp 25.000/hari. Kerusakan cacat permanen akan memotong uang deposit.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _policyItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: _textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  7. CUSTOMER REVIEWS
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildCustomerReviews() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rate_review_outlined,
                  size: 18, color: _textPrimary),
              const SizedBox(width: 8),
              const Text(
                'Ulasan Penyewa',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewDetailsPage(
                        costumeTitle: data['title'] ?? 'Kostum',
                        reviewItems: [
                          {
                            'name': 'Arisa M.',
                            'date': '2 minggu lalu',
                            'rating': 5,
                            'comment':
                                'Kostumnya bagus banget, jahitannya rapi dan bahannya nyaman dipakai seharian. Wig-nya juga udah di-styling, jadi tinggal pakai. Pasti sewa lagi! 🔥',
                            'avatar': 'A',
                            'avatarColor': const Color(0xFFC4B5FD),
                          },
                          {
                            'name': 'Riko S.',
                            'date': '1 bulan lalu',
                            'rating': 5,
                            'comment':
                                'Detail kostumnya sangat akurat, pokoknya worth it buat event cosplay. Pelayanannya juga ramah dan fast response. Recommended! ⭐',
                            'avatar': 'R',
                            'avatarColor': const Color(0xFFFBCFE8),
                          },
                        ],
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textSecondary.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 12, color: _textSecondary.withOpacity(0.7)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Review 1
          _reviewCard(
            name: 'Arisa M.',
            date: '2 minggu lalu',
            rating: 5,
            comment:
                'Kostumnya bagus banget, jahitannya rapi dan bahannya nyaman dipakai seharian. Wig-nya juga udah di-styling, jadi tinggal pakai. Pasti sewa lagi! ðŸ”¥',
            avatar: 'A',
            avatarColor: const Color(0xFFC4B5FD),
          ),
          const SizedBox(height: 12),

          // Review 2
          _reviewCard(
            name: 'Riko S.',
            date: '1 bulan lalu',
            rating: 5,
            comment:
                'Detail kostumnya sangat akurat, pokoknya worth it buat event cosplay. Pelayanannya juga ramah dan fast response. Recommended! â­',
            avatar: 'R',
            avatarColor: const Color(0xFFFBCFE8),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard({
    required String name,
    required String date,
    required int rating,
    required String comment,
    required String avatar,
    required Color avatarColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: avatarColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    avatar,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name & Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // Stars
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  rating,
                  (_) => const Icon(Icons.star_rounded, size: 14, color: _gold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: _textSecondary,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  8. STICKY BOTTOM ACTION BAR
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildStickyBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: _surfaceColor,
        border: const Border(
          top: BorderSide(color: _hairline, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Price info
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Sewa',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _textTertiary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Rp ${data['price'] ?? '0'}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '/ 3 Hari',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Right: CTA Button
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () => _checkIdentityAndProceed(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _textPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Cek & Pilih Tanggal',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  HELPER WIDGETS
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = _textPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Divider(color: _hairline, height: 1),
    );
  }
}
