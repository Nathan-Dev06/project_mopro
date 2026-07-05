import 'package:flutter/material.dart';
import 'package:project_mopro/core/managers/costume_manager.dart';
import 'package:project_mopro/features/customer/pages/home_page.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                onChanged: (_) => setState(() {}),
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
              child: ValueListenableBuilder<List<CostumeData>>(
                valueListenable: CostumeManager.instance.costumesNotifier,
                builder: (context, allCostumes, child) {
                  final search = _searchController.text.trim().toLowerCase();
                  final filteredCostumes = allCostumes.where((item) {
                    return search.isEmpty ||
                        item.title.toLowerCase().contains(search) ||
                        item.series.toLowerCase().contains(search);
                  }).toList();

                  if (filteredCostumes.isEmpty) {
                    return const Center(
                      child: Text(
                        "Kostum tidak ditemukan.",
                        style: TextStyle(color: _grey500, fontFamily: 'Inter', fontSize: 14),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredCostumes.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filteredCostumes[index];
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
                                image: item.image.isNotEmpty
                                    ? (item.image.startsWith('assets/')
                                        ? DecorationImage(image: AssetImage(item.image), fit: BoxFit.cover)
                                        : DecorationImage(image: NetworkImage(item.image), fit: BoxFit.cover))
                                    : null,
                              ),
                              child: item.image.isEmpty
                                  ? const Icon(Icons.image_outlined, color: _grey500)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      color: _black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${item.price} / day',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      color: _grey500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Series: ${item.series} • Size: ${item.sizeDisplay}',
                                    style: const TextStyle(
                                      fontSize: 11,
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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: item.isReady ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.isReady ? 'Ready' : 'Rented',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                      color: item.isReady ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.edit_outlined, size: 20, color: _black),
                                  onPressed: () {
                                    final originalIndex = allCostumes.indexOf(item);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AdminEditProductPage(
                                          costume: item,
                                          costumeIndex: originalIndex != -1 ? originalIndex : null,
                                        ),
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