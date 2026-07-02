import 'package:flutter/material.dart';

class AdminCreateVoucherPage extends StatefulWidget {
  const AdminCreateVoucherPage({Key? key}) : super(key: key);

  @override
  State<AdminCreateVoucherPage> createState() => _AdminCreateVoucherPageState();
}

class _AdminCreateVoucherPageState extends State<AdminCreateVoucherPage> {
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _black = Color(0xFF111111);
  static const Color _grey500 = Color(0xFF888888);
  static const Color _grey200 = Color(0xFFE8E8E8);

  final _codeController = TextEditingController();
  final _descController = TextEditingController();
  final _valueController = TextEditingController();
  
  String _selectedDiscountType = 'Persentase';

  DateTime _startDate = DateTime(2026, 6, 14);
  DateTime _endDate = DateTime(2026, 7, 31);

  String _formatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    return "$day/$month/$year";
  }

  String _formatDateLong(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _black, 
              onPrimary: Colors.white,
              onSurface: _black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _black,
              onPrimary: Colors.white,
              onSurface: _black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _descController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Buat Voucher",
          style: TextStyle(
            color: _black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. KODE VOUCHER
              _buildLabel("Kode Voucher"),
              _buildTextField(
                controller: _codeController,
                hintText: "cth. ANIME25",
              ),
              const SizedBox(height: 18),

              // 2. DESKRIPSI
              _buildLabel("Deskripsi"),
              _buildTextField(
                controller: _descController,
                hintText: "Diskon untuk semua kostum",
              ),
              const SizedBox(height: 18),

              // 3. TIPE DISKON & NILAI
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Tipe Diskon"),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: _grey200, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedDiscountType,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, color: _black),
                              items: <String>['Persentase', 'Nominal Fixed'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value, style: const TextStyle(fontFamily: 'Inter', color: _black)),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedDiscountType = newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Nilai"),
                        _buildTextField(
                          controller: _valueController,
                          hintText: "20",
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 4. BERLAKU DARI & SAMPAI 
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Berlaku Dari"),
                        GestureDetector(
                          onTap: () => _selectStartDate(context),
                          child: _buildStaticDateTile(_formatDate(_startDate), Icons.calendar_today_outlined),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Sampai"),
                        GestureDetector(
                          onTap: () => _selectEndDate(context),
                          child: _buildStaticDateTile(_formatDate(_endDate), Icons.calendar_today_outlined),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
               
                    if (_codeController.text.trim().isNotEmpty) {
                      Navigator.pop(context, {
                        'code': _codeController.text.toUpperCase().trim(),
                        'desc': _descController.text.trim().isEmpty 
                            ? 'Diskon spesial khusus untukmu.' 
                            : _descController.text.trim(),
                        'exp': _formatDateLong(_endDate), 
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tolong isi Kode Voucher terlebih dahulu ya!'),
                          backgroundColor: Colors.black,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Buat Voucher",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: _black,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: _black, fontFamily: 'Inter'),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: _grey500, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _grey200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _black, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildStaticDateTile(String dateText, IconData? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: _grey200, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(dateText, style: const TextStyle(color: _black, fontFamily: 'Inter', fontSize: 14)),
          if (icon != null) Icon(icon, color: _grey500, size: 18),
        ],
      ),
    );
  }
}