import 'package:flutter/material.dart';

import 'package:project_mopro/core/services/firebase_sync_service.dart';

class StoreSettingsPage extends StatefulWidget {
  const StoreSettingsPage({Key? key}) : super(key: key);

  @override
  State<StoreSettingsPage> createState() => _StoreSettingsPageState();
}

class _StoreSettingsPageState extends State<StoreSettingsPage> {
  
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _black = Color(0xFF111111);
  static const Color _grey500 = Color.fromARGB(255, 104, 104, 104);
  static const Color _grey200 = Color(0xFFE8E8E8);
  static const Color _inputBg = Color(0xFFF5F5F5);

  final TextEditingController _namaTokoController = TextEditingController(text: 'Cosvoria Rent');
  final TextEditingController _provinsiController = TextEditingController(text: 'DKI Jakarta');
  final TextEditingController _kotaController = TextEditingController(text: 'Jakarta Selatan');
  final TextEditingController _whatsappController = TextEditingController(text: '0812-3456-7890');
  final TextEditingController _depositController = TextEditingController(text: 'Rp 50.000');
  final TextEditingController _ongkirController = TextEditingController(text: 'Rp 15.000');

  // Status untuk tombol Switch
  bool isModeTokoAktif = true;
  bool isWajibKtp = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final snapshot = await FirebaseSyncService.storeSettingsDoc().get();
      final data = snapshot.data() ?? FirebaseSyncService.defaultStoreSettings();

      _namaTokoController.text = data['storeName']?.toString() ?? _namaTokoController.text;
      _provinsiController.text = data['province']?.toString() ?? _provinsiController.text;
      _kotaController.text = data['city']?.toString() ?? _kotaController.text;
      _whatsappController.text = data['whatsapp']?.toString() ?? _whatsappController.text;
      _depositController.text = data['deposit']?.toString() ?? _depositController.text;
      _ongkirController.text = data['shipping']?.toString() ?? _ongkirController.text;
      isModeTokoAktif = data['isStoreActive'] ?? true;
      isWajibKtp = data['requiresKtpVerification'] ?? true;
    } catch (e) {
      debugPrint('Failed to load store settings: $e');
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _namaTokoController.dispose();
    _provinsiController.dispose();
    _kotaController.dispose();
    _whatsappController.dispose();
    _depositController.dispose();
    _ongkirController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: _black, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Store Settings',
          style: TextStyle(
            color: _black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
            letterSpacing: -0.3,
          ),
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField('Store Name', _namaTokoController),
                    _buildInputField('Primary Province', _provinsiController),
                    _buildInputField('Primary City', _kotaController),
                    _buildInputField('CS WhatsApp Number', _whatsappController),
                    _buildInputField('Default Deposit Fee', _depositController),
                    _buildInputField('Default Shipping Fee', _ongkirController),
                    
                    const SizedBox(height: 10),
                    const Divider(color: _grey200, height: 1),
                    const SizedBox(height: 15),

                    _buildSwitchTile(
                      title: 'Active Store Mode',
                      subtitle: 'Turn off to temporarily close all rentals',
                      value: isModeTokoAktif,
                      onChanged: (val) => setState(() => isModeTokoAktif = val),
                    ),
                    _buildSwitchTile(
                      title: 'Require ID (KTP) Verification',
                      subtitle: 'Customers must verify their identity before renting',
                      value: isWajibKtp,
                      onChanged: (val) => setState(() => isWajibKtp = val),
                    ),

                    const SizedBox(height: 30),

                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () async {
                            await FirebaseSyncService.saveStoreSettings({
                              'storeName': _namaTokoController.text.trim(),
                              'province': _provinsiController.text.trim(),
                              'city': _kotaController.text.trim(),
                              'whatsapp': _whatsappController.text.trim(),
                              'deposit': _depositController.text.trim(),
                              'shipping': _ongkirController.text.trim(),
                              'isStoreActive': isModeTokoAktif,
                              'requiresKtpVerification': isWajibKtp,
                            });

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Settings saved successfully!')),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: _black, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save Settings',
                            style: TextStyle(
                              color: _black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }


  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _grey500,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: const TextStyle(color: _black, fontFamily: 'Inter', fontSize: 16),
            decoration: InputDecoration(
              filled: true,
              fillColor: _inputBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
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
        ],
      ),
    );
  }

  
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _grey500,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: _black, 
              inactiveThumbColor: _grey500,
              inactiveTrackColor: _inputBg,
            ),
          ),
        ],
      ),
    );
  }
}