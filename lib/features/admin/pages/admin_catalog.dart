import 'package:flutter/material.dart';
import 'package:project_mopro/features/admin/pages/admin_edit_product_page.dart'; 

class AdminCatalogPage extends StatefulWidget {
  const AdminCatalogPage({Key? key}) : super(key: key);

  @override
  State<AdminCatalogPage> createState() => _AdminCatalogPageState();
}

class _AdminCatalogPageState extends State<AdminCatalogPage> {
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _black = Color(0xFF111111);
  static const Color _grey500 = Color(0xFF888888);
  static const Color _grey200 = Color(0xFFE8E8E8);

  final TextEditingController _searchController = TextEditingController();

  // Data dummy catalog asli milikmu
  final List<Map<String, dynamic>> dummyCatalog = [
    {'name': 'Zhongli - Genshin Impact', 'price': 150000, 'stock': 2, 'anime': 'Genshin Impact', 'gender': 'Pria', 'status': 'Ready', 'sizes': 'S, M, L, XL'},
    {'name': 'Anya Forger - Spy x Family', 'price': 80000, 'stock': 5, 'anime': 'Spy x Family', 'gender': 'Wanita', 'status': 'Ready', 'sizes': 'M, L'},
    {'name': 'Akatsuki Cloak - Naruto', 'price': 50000, 'stock': 10, 'anime': 'Naruto', 'gender': 'Unisex', 'status': 'Ready', 'sizes': 'S, M, L, XL'},
    {'name': 'Maid Dress Classic', 'price': 100000, 'stock': 3, 'anime': 'Original / Other', 'gender': 'Wanita', 'status': 'Ready', 'sizes': 'S, M'},
  ];

 
  List<Map<String, dynamic>> _filteredCatalog = [];

  @override
  void initState() {
    super.initState();

    _filteredCatalog = dummyCatalog;

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredCatalog = dummyCatalog
          .where((item) => item['name']
              .toString()
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
     
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Catalog",
                    style: TextStyle(
                      color: _black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      letterSpacing: -0.3,
                    ),
                  ),
             
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminEditProductPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add New'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: _black, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  hintText: "Cari kostum...",
                  hintStyle: const TextStyle(color: _grey500, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: _grey500, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  filled: true,
                  fillColor: const Color(0xFFF6F6F6),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _black, width: 1),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _filteredCatalog.isEmpty
                  ? const Center(
                      child: Text(
                        "Kostum tidak ditemukan.",
                        style: TextStyle(color: _grey500, fontFamily: 'Inter', fontSize: 14),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredCatalog.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _filteredCatalog[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _grey200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.image_outlined, color: _grey500),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        color: _black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp ${item['price']} / day',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        fontFamily: 'Inter',
                                        color: _grey500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Stock: ${item['stock']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      color: _grey500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                   
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.edit_outlined, size: 20, color: _black),
                                    onPressed: () {
                           
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AdminEditProductPage(productData: item),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}