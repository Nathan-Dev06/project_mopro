import 'package:flutter/material.dart';
import 'package:project_mopro/features/customer/pages/home_page.dart';
import 'package:project_mopro/core/managers/costume_manager.dart';

class AdminEditProductPage extends StatefulWidget {
  final int? costumeIndex;
  final CostumeData? costume;
  final Map<String, dynamic>? productData;

  const AdminEditProductPage({
    Key? key,
    this.costumeIndex,
    this.costume,
    this.productData,
  }) : super(key: key);

  @override
  State<AdminEditProductPage> createState() => _AdminEditProductPageState();
}

class _AdminEditProductPageState extends State<AdminEditProductPage> {
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _black = Color(0xFF111111);
  static const Color _grey500 = Color(0xFF888888);
  static const Color _grey200 = Color(0xFFE8E8E8);

  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _namaController;
  late TextEditingController _animeController;
  late TextEditingController _hargaController;
  late TextEditingController _kondisiController;
  late TextEditingController _ukuranController;
  late TextEditingController _includeController;
  late TextEditingController _kategoriController;

  String _selectedStatus = "Ready";
  final Map<String, TextEditingController> _stockControllers = {};

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi controller dengan CostumeData (untuk edit) atau default (untuk tambah)
    _namaController = TextEditingController(text: widget.costume?.title ?? '');
    _animeController = TextEditingController(text: widget.costume?.series ?? '');
    _hargaController = TextEditingController(text: widget.costume?.price ?? '');
    _kondisiController = TextEditingController(text: widget.costume?.condition ?? '100%');
    _ukuranController = TextEditingController(text: widget.costume?.size ?? 'S, M, L, XL');
    _includeController = TextEditingController(text: widget.costume?.include ?? '');
    _kategoriController = TextEditingController(text: widget.costume?.category ?? 'Anime');
    
    _selectedStatus = widget.costume?.isReady == true ? "Ready" : "Rented";

    // Memicu rebuild untuk memperbarui form stok saat kolom ukuran diubah
    _ukuranController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _animeController.dispose();
    _hargaController.dispose();
    _kondisiController.dispose();
    _ukuranController.dispose();
    _includeController.dispose();
    _kategoriController.dispose();
    for (var ctrl in _stockControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  List<String> getParsedSizes() {
    final text = _ukuranController.text.trim();
    if (text.isEmpty) return [];
    if (text == 'All Size') return ['All Size'];
    return text
        .split(RegExp(r'[|,\-\n]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  TextEditingController _getControllerForSize(String size) {
    if (!_stockControllers.containsKey(size)) {
      int initialStock = 5;
      if (widget.costume?.sizeStocks != null && widget.costume!.sizeStocks!.containsKey(size)) {
        initialStock = widget.costume!.sizeStocks![size]!;
      }
      _stockControllers[size] = TextEditingController(text: initialStock.toString());
      _stockControllers[size]!.addListener(() {
        if (mounted) setState(() {});
      });
    }
    return _stockControllers[size]!;
  }

  int _calculateTotalStock() {
    int total = 0;
    final sizes = getParsedSizes();
    for (var sz in sizes) {
      final controller = _getControllerForSize(sz);
      total += int.tryParse(controller.text) ?? 0;
    }
    return total;
  }

  void _saveCostume() {
    if (_formKey.currentState!.validate()) {
      final finalStocks = <String, int>{};
      final sizes = getParsedSizes();
      for (var sz in sizes) {
        final controller = _getControllerForSize(sz);
        finalStocks[sz] = int.tryParse(controller.text.trim()) ?? 0;
      }

      final updatedCostume = CostumeData(
        title: _namaController.text,
        series: _animeController.text,
        price: _hargaController.text,
        condition: _kondisiController.text,
        image: widget.costume?.image ?? 'assets/images/default.jpg',
        include: _includeController.text,
        size: _ukuranController.text,
        isReady: _selectedStatus == "Ready",
        category: _kategoriController.text,
        rating: widget.costume?.rating ?? 4.8,
        reviewCount: widget.costume?.reviewCount ?? 12,
        sizeStocks: finalStocks,
      );

      if (widget.costumeIndex != null) {
        // Edit costume
        CostumeManager.instance.updateCostume(widget.costumeIndex!, updatedCostume);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Costume updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Add new costume
        CostumeManager.instance.addCostume(updatedCostume);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Costume added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.costume != null;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? "Edit Costume" : "Add New Costume",
          style: const TextStyle(
            color: _black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField("Costume Name", _namaController, "e.g., Monkey D. Luffy - One Piece"),
                      const SizedBox(height: 16),
                      _buildTextField("Anime / Game Title", _animeController, "e.g., One Piece / Genshin Impact"),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(child: _buildTextField("Price / Day (Rp)", _hargaController, "e.g., 150000", isNumber: false)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField("Condition", _kondisiController, "e.g., 95%")),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField("Status", ["Ready", "Rented"], _selectedStatus, (val) {
                              setState(() => _selectedStatus = val!);
                            }),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField("Category", _kategoriController, "e.g., Anime / Game")),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildTextField("Size", _ukuranController, "e.g., S, M, L, XL / All Size"),
                      const SizedBox(height: 16),

                      // Stock Management Section
                      _buildStockSection(),
                      const SizedBox(height: 16),

                      _buildTextField("Includes", _includeController, "e.g., Costume, wig, accessories"),
                      const SizedBox(height: 20),

                      // Upload Foto Box
                      const Text(
                        "Costume Photo",
                        style: TextStyle(color: _black, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _grey200, width: 1.5),
                        ),
                        child: InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Photo upload feature coming soon!")),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.cloud_upload_outlined, color: _grey500, size: 32),
                              SizedBox(height: 8),
                              Text(
                                "Click to upload photo",
                                style: TextStyle(color: _grey500, fontSize: 13, fontFamily: 'Inter'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tombol Simpan
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveCostume,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      isEdit ? "Save Changes" : "Save Costume",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockSection() {
    final sizes = getParsedSizes();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Stock Management",
              style: TextStyle(
                color: _black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "Total Stok: ${_calculateTotalStock()}",
                style: const TextStyle(
                  color: _black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (sizes.isEmpty)
          const Text(
            "Masukkan ukuran terlebih dahulu untuk mengatur stok.",
            style: TextStyle(color: _grey500, fontSize: 13, fontFamily: 'Inter', fontStyle: FontStyle.italic),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _grey200),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sizes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final sz = sizes[index];
                final controller = _getControllerForSize(sz);
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        "Ukuran $sz",
                        style: const TextStyle(
                          color: _black,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 38,
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: _black, fontSize: 13, fontFamily: 'Inter'),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: _grey200, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: _black, width: 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _black, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: _black, fontSize: 15, fontFamily: 'Inter'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _grey500, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _grey200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _black, width: 1.5),
            ),
          ),
          validator: (value) => value == null || value.isEmpty ? "This field cannot be empty" : null,
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String selectedValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _black, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontFamily: 'Inter')))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _grey200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _black, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}