import 'package:flutter/material.dart';
import 'detail_costume_page.dart'; // 1. PASTIKAN SUDAH IMPORT FILE DETAILNYA

class MainHomePage extends StatefulWidget {
  const MainHomePage({Key? key}) : super(key: key);

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  // WARNA TEMA PREMIUM
  final Color bgColor = const Color(0xFF0A0516);
  final Color cardColor = const Color(0xFF160D29);
  final Color accentGold = const Color(0xFFFFD700);
  final Color neonPurple = const Color(0xFF9B51E0);

  int _selectedIndex = 0;
  String _selectedCategory = "Semua";

  // 2. DATABASE KOSTUM (Data ini yang akan dikirim ke halaman detail saat kartu diklik)
  final List<Map<String, dynamic>> costumes = [
    {
      "title": "Raiden Shogun",
      "series": "Genshin Impact",
      "price": "150k",
      "rating": "4.9",
      "image":
          "https://images.unsplash.com/photo-1618336753974-aae8e04506aa?q=80&w=1000", // Contoh gambar placeholder
      "include": "Full Set Costume, Armor, Wig",
      "size": "S-M (LD 85-92 cm)",
      "location": "Jakarta Pusat",
      "seller": "Inazuma Store"
    },
    {
      "title": "Kafka",
      "series": "Honkai Star Rail",
      "price": "165k",
      "rating": "5.0",
      "image":
          "https://images.unsplash.com/photo-1608889175123-8ee362201f81?q=80&w=1000",
      "include": "Costume, Wig, Glasses, Prop Gun",
      "size": "L (LD 95 cm)",
      "location": "Surabaya",
      "seller": "Stellar Rent"
    },
    {
      "title": "Genshin Aether",
      "series": "Genshin Impact",
      "price": "120k",
      "rating": "4.8",
      "image":
          "https://images.unsplash.com/photo-1578632738908-4521c726eec7?q=80&w=1000",
      "include": "Costume, Wig, Sword Prop",
      "size": "M (All Size)",
      "location": "Bandung",
      "seller": "Teyvat Gear"
    },
    {
      "title": "March 7th",
      "series": "Honkai Star Rail",
      "price": "135k",
      "rating": "4.9",
      "image":
          "https://images.unsplash.com/photo-1541562232579-512a21360020?q=80&w=1000",
      "include": "Full Costume, Wig, Bow Prop",
      "size": "S (LD 80-88 cm)",
      "location": "Lamongan, Jatim",
      "seller": "Princeuuu Rent"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER SECTION ---
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Selamat Datang ✨",
                          style: TextStyle(
                              color: Colors.purple[100],
                              fontSize: 14,
                              letterSpacing: 1),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Hey, Kaelen!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: accentGold, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: accentGold.withOpacity(0.3),
                              blurRadius: 10)
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFF2D1B4E),
                        child: Icon(Icons.person_outline, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),

              // --- SEARCH & FILTER BAR ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        height: 55,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: const TextField(
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            icon: Icon(Icons.search_rounded,
                                color: Colors.purpleAccent),
                            hintText: "Cari karakter, anime, atau game...",
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.tune_rounded, color: accentGold),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // --- FEATURED BANNER ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4A148C), Color(0xFF1A0033)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A148C).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: accentGold.withOpacity(0.06),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: accentGold,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Text(
                                "PROMO BULAN INI",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Diskon 30% Sewa Pertama",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Gunakan kode voucher: COSFEST30",
                              style: TextStyle(
                                  color: Colors.purple[100], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- CATEGORIES ---
              SizedBox(
                height: 45,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: 20),
                  children: [
                    _buildCategoryChip("Semua"),
                    _buildCategoryChip("Anime"),
                    _buildCategoryChip("Genshin Impact"),
                    _buildCategoryChip("Honkai Star Rail"),
                    _buildCategoryChip("VTuber"),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // --- POPULAR SECTION ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Rekomendasi Populer",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5),
                    ),
                    Text(
                      "Lihat Semua",
                      style: TextStyle(
                          color: accentGold,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // --- 3. GRID KATALOG (SUDAH DIHUBUNGKAN KE LIST COSTUMES) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  itemCount:
                      costumes.length, // Dinamis sesuai panjang List data
                  itemBuilder: (context, index) {
                    // Mengirim item map dan context agar kartu bisa mengarah ke Detail
                    return _buildModernCostumeCard(
                        costumes[index], index, context);
                  },
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        height: 65,
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 25,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: accentGold,
            unselectedItemColor: Colors.grey[600],
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_rounded, size: 26), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_rounded, size: 26),
                  label: "Pesanan"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_rounded, size: 26), label: "Suka"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded, size: 26), label: "Profil"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String name) {
    bool isSelected = _selectedCategory == name;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = name),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [accentGold, const Color(0xFFFFA500)])
              : null,
          color: isSelected ? null : cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.05)),
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey[400],
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // --- 4. WIDGET KARTU KOSTUM (SUDAH DIBUNGKUS GESTUREDTECTOR & NAVIGASI) ---
  Widget _buildModernCostumeCard(
      Map<String, dynamic> data, int index, BuildContext context) {
    final List<List<Color>> meshGradients = [
      [const Color(0xFF3A1C71), const Color(0xFFD76D77)],
      [const Color(0xFF1E3C72), const Color(0xFF2A5298)],
      [const Color(0xFF0F2027), const Color(0xFF203A43)],
      [const Color(0xFF11998e), const Color(0xFF38ef7d)],
    ];

    return GestureDetector(
      onTap: () {
        // AKSI DIKLIK: Berpindah ke DetailCostumePage membawa data map spesifik
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailCostumePage(costumeData: data),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: meshGradients[index % meshGradients.length],
                  ),
                ),
                child: const Center(
                  child: Opacity(
                    opacity: 0.15,
                    child:
                        Icon(Icons.auto_awesome, color: Colors.white, size: 60),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded, color: accentGold, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        data['rating'], // AMBIL DARI DATA MAP
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['series'].toUpperCase(), // AMBIL DARI DATA MAP
                        style: TextStyle(
                            color: accentGold,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['title'], // AMBIL DARI DATA MAP
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Harga Sewa",
                                  style: TextStyle(
                                      color: Colors.grey[500], fontSize: 9)),
                              Text(
                                "Rp ${data['price']}/hari", // AMBIL DARI DATA MAP
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 16),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
