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
    super.dispose();
  }

  void _saveCostume() {
    if (_formKey.currentState!.validate()) {
      final updatedCostume = CostumeData(
        title: _namaController.text,
        series: _animeController.text,
        price: _hargaController.text,
        condition: _kondisiController.text,
        image: widget.costume?.image ?? '', // Biarkan gambar tetap sama untuk sementara
        include: _includeController.text,
        size: _ukuranController.text,
        isReady: _selectedStatus == "Ready",
        category: _kategoriController.text,
        rating: widget.costume?.rating ?? 4.8,
        reviewCount: widget.costume?.reviewCount ?? 12,
      );

      if (widget.costumeIndex != null) {
        // Edit costume
        CostumeManager.instance.updateCostume(widget.costumeIndex!, updatedCostume);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kostum berhasil diperbarui!'),
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
          isEdit ? "Edit Kostum" : "Tambah Kostum Baru",
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
                      _buildTextField("Nama Kostum", _namaController, "cth. Monkey D. Luffy - One Piece"),
                      const SizedBox(height: 16),
                      _buildTextField("Judul Anime / Game", _animeController, "cth. One Piece / Genshin Impact"),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(child: _buildTextField("Harga / Hari (Rp)", _hargaController, "cth. 150000", isNumber: false)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField("Kondisi", _kondisiController, "cth. 95%")),
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
                          Expanded(child: _buildTextField("Kategori", _kategoriController, "cth. Anime / Game")),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildTextField("Ukuran", _ukuranController, "cth. S, M, L, XL / All Size"),
                      const SizedBox(height: 16),

                      _buildTextField("Include", _includeController, "cth. Kostum, wig, aksesoris"),
                      const SizedBox(height: 20),

                      // Upload Foto Box
                      const Text(
                        "Foto Kostum",
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
                              const SnackBar(content: Text("Fitur upload foto akan datang!")),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.cloud_upload_outlined, color: _grey500, size: 32),
                              SizedBox(height: 8),
                              Text(
                                "Klik untuk upload foto",
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
                      isEdit ? "Simpan Perubahan" : "Simpan Kostum",
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
          validator: (value) => value == null || value.isEmpty ? "Field ini tidak boleh kosong" : null,
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