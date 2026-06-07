import 'package:flutter/material.dart';
import 'detail_costume_page.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({Key? key}) : super(key: key);

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  // PALET WARNA KICK AVENUE STYLE (CLEAN & LIGHT)
  final Color bgColor = Colors.white;
  final Color cardImageBg = const Color(0xFFF5F5F5); // Abu-abu terang
  final Color textPrimary = Colors.black;
  final Color textSecondary = const Color(0xFF888888);
  final Color priceColor = const Color(0xFF00A651); // Hijau khas harga

  int _selectedIndex = 0;

  // DATABASE KOSTUM (Sistem 1 Vendor)
  final List<Map<String, dynamic>> costumes = [
    {
      "title": "Raiden Shogun",
      "series": "Genshin Impact",
      "price": "150.000",
      "image":
          "https://images.unsplash.com/photo-1618336753974-aae8e04506aa?q=80&w=1000",
      "include": "Full Set Costume, Armor, Wig",
      "size": "S-M",
      "isReady": true,
    },
    {
      "title": "Kafka",
      "series": "Honkai Star Rail",
      "price": "165.000",
      "image":
          "https://images.unsplash.com/photo-1608889175123-8ee362201f81?q=80&w=1000",
      "include": "Costume, Wig, Glasses, Prop Gun",
      "size": "L",
      "isReady": false,
    },
    {
      "title": "Genshin Aether",
      "series": "Genshin Impact",
      "price": "120.000",
      "image":
          "https://images.unsplash.com/photo-1578632738908-4521c726eec7?q=80&w=1000",
      "include": "Costume, Wig, Sword Prop",
      "size": "All Size",
      "isReady": true,
    },
    {
      "title": "March 7th",
      "series": "Honkai Star Rail",
      "price": "135.000",
      "image":
          "https://images.unsplash.com/photo-1541562232579-512a21360020?q=80&w=1000",
      "include": "Full Costume, Wig, Bow Prop",
      "size": "S",
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
              // TINGGI DITAMBAH JADI 360 KARENA FOTO PORTRAIT LEBIH PANJANG
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

  // WIDGET KARTU PRODUK PORTRAIT (Adaptasi 1 Vendor)
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
        width: 150, // Kartu lebih ramping
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KOTAK GAMBAR PORTRAIT
            Stack(
              children: [
                Container(
                  height: 220, // Tinggi gambar diperbesar jadi Portrait
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

            // 4. DETAIL SERIES (Pakai Icon kecil)
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

            // 5. CHIPS UKURAN & KONDISI (Adaptasi dari Referensi)
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
