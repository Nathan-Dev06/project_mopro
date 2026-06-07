import 'package:flutter/material.dart';
import 'detail_costume_page.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({Key? key}) : super(key: key);

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  // PALET WARNA CLEAN & LIGHT
  final Color bgColor = Colors.white;
  final Color cardImageBg = const Color(0xFFF5F5F5); // Abu-abu terang
  final Color textPrimary = Colors.black;
  final Color textSecondary = const Color(0xFF888888);
  final Color priceColor = const Color(0xFF00A651); // Hijau khas harga

  int _selectedIndex = 0;

  // DATABASE KOSTUM (Katalog Pop-Culture Realistis)
  final List<Map<String, dynamic>> costumes = [
    {
      "title": "Bundle Monkey D. Luffy (Wano)",
      "series": "One Piece",
      "price": "120.000",
      "condition": "95%",
      // Link gambar sementara bernuansa merah/kuning khas Luffy
      "image":
          "https://images.unsplash.com/photo-1605806616949-1e87b487cb2a?q=80&w=1000&auto=format&fit=crop",
      "include":
          "Kemeja Merah Terbuka, Celana Pendek, Topi Jerami, Sabuk Kuning",
      "size": "L - XL",
      "isReady": true,
    },
    {
      "title": "Satoru Gojo (Hidden Inventory)",
      "series": "Jujutsu Kaisen",
      "price": "145.000",
      "condition": "98%",
      // Link gambar nuansa cool/dark
      "image":
          "https://images.unsplash.com/photo-1514316454349-f5091726a575?q=80&w=1000&auto=format&fit=crop",
      "include":
          "Kemeja Hitam, Celana Panjang, Kacamata Hitam Bulat, Wig Putih (Sudah Styling)",
      "size": "M - L",
      "isReady": false,
    },
    {
      "title": "Dalí Mask & Jumpsuit Perampok",
      "series": "Money Heist (Netflix)",
      "price": "100.000",
      "condition": "90%",
      // Link gambar nuansa topeng/jumpsuit merah
      "image":
          "https://images.unsplash.com/photo-1627455829638-3486be0092f2?q=80&w=1000&auto=format&fit=crop",
      "include":
          "Jumpsuit Merah (Resleting Depan), Topeng Salvador Dalí, Sarung Tangan Hitam, Prop Senjata Dummy",
      "size": "All Size",
      "isReady": true,
    },
    {
      "title": "Spider-Man (Miles Morales)",
      "series": "Marvel / Spider-Verse",
      "price": "180.000",
      "condition": "99%",
      // Link gambar Spiderman
      "image":
          "https://images.unsplash.com/photo-1635805737707-575885ab0820?q=80&w=1000&auto=format&fit=crop",
      "include":
          "Full Body Suit (Spandex Premium), Topeng Lensa Jaring, Jaket Hoodie Hijau, Celana Pendek Abu-abu",
      "size": "M (Fit Body)",
      "isReady": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          "COSVORIA",
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: textPrimary),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 20, left: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.black,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SEARCH BAR ---
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 45,
                decoration: BoxDecoration(
                  color: cardImageBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: textPrimary),
                        decoration: InputDecoration(
                          hintText: "Search for costume, anime, or series...",
                          hintStyle:
                              TextStyle(color: textSecondary, fontSize: 13),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- PROMO BANNER ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      bottom: -20,
                      child: Icon(Icons.local_fire_department,
                          size: 150, color: Colors.white.withOpacity(0.1)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "NEW ARRIVALS",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Explore the latest collections for your next event.",
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- HORIZONTAL SLIDER 1 (KATALOG TERBARU) ---
            _buildSectionHeader("Katalog Terbaru", "Selengkapnya"),
            const SizedBox(height: 15),
            SizedBox(
              height: 360,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: costumes.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return _buildPortraitCard(costumes[index], context);
                },
              ),
            ),

            const SizedBox(height: 30),

            // --- HORIZONTAL SLIDER 2 (REKOMENDASI) ---
            _buildSectionHeader("Rekomendasi", "Selengkapnya"),
            const SizedBox(height: 15),
            SizedBox(
              height: 360,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: costumes.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return _buildPortraitCard(
                      costumes.reversed.toList()[index], context);
                },
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
                icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.home_filled)),
                label: "Home"),
            BottomNavigationBarItem(
                icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.search)),
                label: "Browse"),
            BottomNavigationBarItem(
                icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.favorite_border_rounded)),
                label: "Saved"),
            BottomNavigationBarItem(
                icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.person_outline_rounded)),
                label: "Profile"),
          ],
        ),
      ),
    );
  }

  // WIDGET HEADER SECTION
  Widget _buildSectionHeader(String title, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
                color: textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              action,
              style: TextStyle(color: textSecondary, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET KARTU PRODUK PORTRAIT
  Widget _buildPortraitCard(Map<String, dynamic> data, BuildContext context) {
    bool isReady = data['isReady'] ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailCostumePage(costumeData: data),
          ),
        );
      },
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KOTAK GAMBAR PORTRAIT
            Stack(
              children: [
                Container(
                  height: 220,
                  width: 150,
                  decoration: BoxDecoration(
                    color: cardImageBg,
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(data['image'] ?? ""),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Badge Ketersediaan
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isReady ? Colors.white : Colors.black,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey[300]!, width: 0.5),
                    ),
                    child: Text(
                      isReady ? "Ready" : "Rented",
                      style: TextStyle(
                        color: isReady ? Colors.black : Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. NAMA KARAKTER
            Text(
              data['title'] ?? "",
              style: TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // 3. HARGA SEWA
            Text(
              "Rp ${data['price'] ?? "0"} / 3 hari",
              style: TextStyle(
                  color: priceColor, fontSize: 13, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),

            // 4. DETAIL SERIES
            Row(
              children: [
                Icon(Icons.movie_creation_outlined,
                    size: 12, color: textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    data['series'] ?? "",
                    style: TextStyle(color: textSecondary, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 5. CHIPS UKURAN & KONDISI
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    data['size'] ?? "All Size",
                    style: TextStyle(
                        color: textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    data['condition'] ?? "-",
                    style: TextStyle(
                        color: textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
