import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:project_mopro/core/services/firebase_sync_service.dart';

class AdminManageUsersPage extends StatefulWidget {
  const AdminManageUsersPage({Key? key}) : super(key: key);

  @override
  State<AdminManageUsersPage> createState() => _AdminManageUsersPageState();
}

class _AdminManageUsersPageState extends State<AdminManageUsersPage> {
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _black = Color(0xFF111111);
  static const Color _grey500 = Color(0xFF888888);
  static const Color _grey200 = Color(0xFFE8E8E8);
  static const Color _inputBg = Color(0xFFF3F4F6); 
  
  static const Color _blueBadgeBg = Color(0xFFE0F2FE); 
  static const Color _blueBadgeText = Color(0xFF0284C7); 

  final TextEditingController _searchController = TextEditingController();
  String _selectedTab = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _resolveRole(Map<String, dynamic> data) {
    final role = data['role']?.toString();
    if (role != null && role.isNotEmpty) return role;
    return data['isAdmin'] == true ? 'Admin' : 'Customer';
  }

  List<Map<String, String>> _mapUsers(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': (data['name'] ?? 'Unknown').toString(),
        'email': (data['email'] ?? '').toString(),
        'role': _resolveRole(data),
      };
    }).toList();
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
          "Manage Users",
          style: TextStyle(
            color: _black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // ── BAR PENCARIAN ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: _inputBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: _black),
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, color: _grey500),
                    hintText: "Cari user...",
                    hintStyle: TextStyle(color: _grey500),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildTabButton("Semua"),
                  const SizedBox(width: 10),
                  _buildTabButton("Admin"),
                  const SizedBox(width: 10),
                  _buildTabButton("Customer"),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── DAFTAR USER ──
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseSyncService.usersCollection().snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Gagal memuat data user.',
                        style: TextStyle(color: _grey500, fontFamily: 'Inter'),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final search = _searchController.text.trim().toLowerCase();
                  final users = _mapUsers(snapshot.data!);
                  final filteredUsers = users.where((user) {
                    final matchesRole = _selectedTab == 'Semua' || user['role'] == _selectedTab;
                    final matchesSearch = search.isEmpty ||
                        user['name']!.toLowerCase().contains(search) ||
                        user['email']!.toLowerCase().contains(search);
                    return matchesRole && matchesSearch;
                  }).toList();

                  if (filteredUsers.isEmpty) {
                    return const Center(
                      child: Text(
                        'Tidak ada user yang cocok.',
                        style: TextStyle(color: _grey500, fontFamily: 'Inter'),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return _buildUserItem(
                        name: user['name']!,
                        email: user['email']!,
                        role: user['role']!,
                      );
                    },
                  );
                },
              ),
            ),

         
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    // Memanggil fungsi bottom sheet form input
                    _showAddAdminBottomSheet(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _grey500, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, color: _black, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Tambah Admin Baru',
                        style: TextStyle(
                          color: _black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAdminBottomSheet(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    String selectedRole = 'Admin'; 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder( 
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20, 
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
        
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: _grey200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const Text(
                      'Tambah Admin Baru',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        color: _black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildFormTextField(label: 'Nama Lengkap', controller: nameController, hint: 'Masukkan nama admin baru'),
                    const SizedBox(height: 12),

                    _buildFormTextField(label: 'Email', controller: emailController, hint: 'contohadmin@gmail.com', keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 12),

                    _buildFormTextField(label: 'Password Sementara', controller: passwordController, hint: 'Minimal 6 karakter', isPassword: true),
                    const SizedBox(height: 16),

                    const Text(
                      'Level Akses (Role)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter', color: _black),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: _inputBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedRole,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: _grey500),
                          items: <String>['Admin', 'Customer'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: const TextStyle(fontFamily: 'Inter')),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setModalState(() {
                              selectedRole = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Aksi Simpan Data
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _black, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);
      
                          if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Semua data wajib diisi ya, Sweety!')),
                            );
                            return;
                          }

                          final email = emailController.text.trim().toLowerCase();

                          await FirebaseSyncService.upsertUserRecord(
                            userId: 'manual_$email',
                            data: {
                              'name': nameController.text.trim(),
                              'email': email,
                              'role': selectedRole,
                              'isAdmin': selectedRole == 'Admin',
                              'accountSource': 'admin-panel',
                              'verificationStatus': 'approved',
                            },
                          );

                          if (!mounted) return;

                          navigator.pop(); 
                          
                          messenger.showSnackBar(
                            SnackBar(content: Text('${nameController.text} berhasil diundang sebagai $selectedRole!')),
                          );
                        },
                        child: const Text(
                          'Simpan & Kirim Undangan',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Inter'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFormTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter', color: _black)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _inputBg,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            style: const TextStyle(color: _black),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: _grey500, fontSize: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  // Widget Pembantu untuk Membuat Button Tab Filter
  Widget _buildTabButton(String label) {
    bool isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _black : _inputBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? _bg : _grey500,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  // Widget Pembantu untuk Baris Item User
  Widget _buildUserItem({
    required String name,
    required String email,
    required String role,
  }) {
    String initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _grey200, width: 1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _inputBg,
            child: Text(
              initials,
              style: const TextStyle(color: _black, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: _black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    color: _grey500,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: role == 'Admin' ? _blueBadgeBg : _inputBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              role,
              style: TextStyle(
                color: role == 'Admin' ? _blueBadgeText : _grey500,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}