import 'package:flutter/material.dart';

class AdminEditProductPage extends StatefulWidget {
  final Map<String, dynamic>? productData;

  const AdminEditProductPage({Key? key, this.productData}) : super(key: key);

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
  late TextEditingController _stockController;
  late TextEditingController _ukuranController;

  String _selectedGender = "Pria";
  String _selectedStatus = "Ready";

  @override
  void initState() {
    super.initState();
    
    _namaController = TextEditingController(text: widget.productData?['name'] ?? '');
    _animeController = TextEditingController(text: widget.productData?['anime'] ?? '');
    _hargaController = TextEditingController(text: widget.productData?['price']?.toString() ?? '');
    _stockController = TextEditingController(text: widget.productData?['stock']?.toString() ?? '');
    _ukuranController = TextEditingController(text: widget.productData?['sizes'] ?? 'S, M, L, XL');
    
    if (widget.productData != null) {
      _selectedGender = widget.productData!['gender'] ?? "Pria";
      _selectedStatus = widget.productData!['status'] ?? "Ready";
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _animeController.dispose();
    _hargaController.dispose();
    _stockController.dispose();
    _ukuranController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.productData != null;

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
          isEdit ? "Edit Produk" : "Tambah Produk Baru",
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
                      _buildTextField("Nama Karakter", _namaController, "cth. Zhongli - Genshin Impact"),
                      const SizedBox(height: 16),
                      _buildTextField("Judul Anime / Game", _animeController, "cth. Genshin Impact / Sailor Moon"),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(child: _buildTextField("Harga / Hari (Rp)", _hargaController, "cth. 150000", isNumber: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField("Stock", _stockController, "cth. 2", isNumber: true)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField("Gender", ["Pria", "Wanita", "Unisex"], _selectedGender, (val) {
                              setState(() => _selectedGender = val!);
                            }),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdownField("Status", ["Ready", "Rented", "Maintenance"], _selectedStatus, (val) {
                              setState(() => _selectedStatus = val!);
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildTextField("Ukuran Tersedia", _ukuranController, "S, M, L, XL"),
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
                            // Simulasi interaksi upload foto
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Membuka Galeri/Kamera...")),
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEdit ? 'Produk Berhasil Diperbarui!' : 'Produk Baru Berhasil Ditambahkan!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      isEdit ? "Simpan Perubahan" : "Simpan Produk",
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