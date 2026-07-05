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

  final TextEditingController _searchController = TextEditingController();

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
          "Manage Customers",
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
                    hintText: "Search customer...",
                    hintStyle: TextStyle(color: _grey500),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── DAFTAR CUSTOMER ──
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseSyncService.usersCollection().snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Failed to load customer data.',
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
                    final matchesRole = user['role'] == 'Customer';
                    final matchesSearch = search.isEmpty ||
                        user['name']!.toLowerCase().contains(search) ||
                        user['email']!.toLowerCase().contains(search);
                    return matchesRole && matchesSearch;
                  }).toList();

                  if (filteredUsers.isEmpty) {
                    return const Center(
                      child: Text(
                        'No matching customers found.',
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

  // Widget Pembantu untuk Baris Item User
  Widget _buildUserItem({
    required String name,
    required String email,
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
        ],
      ),
    );
  }
}