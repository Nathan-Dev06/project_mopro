import 'package:flutter/material.dart';
import 'package:project_mopro/features/auth/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  String? _error;
  bool _loading = false;
  bool _obscure = true;

  Future<void> _doRegister() async {
  if (!_formKey.currentState!.validate()) return;

  if (_passwordCtrl.text != _confirmCtrl.text) {
    setState(() {
      _error = 'Password dan konfirmasi tidak cocok';
    });
    return;
  }

  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    UserCredential credential =
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: _emailCtrl.text.trim(),
    password: _passwordCtrl.text.trim(),
    );

    await FirebaseFirestore.instance
    .collection('users')
    .doc(credential.user!.uid)
    .set({
    'name': _nameCtrl.text.trim(),
    'email': _emailCtrl.text.trim(),
    'phone': '',
    'address': '',
    'role': 'Customer',
    'isAdmin': false,
    'verificationStatus': 'pending',
    'verificationRequestedAtLabel': DateTime.now().toIso8601String(),

    // Wallet
    'deposit_balance': 0,
    'cosmo_points': 0,
    });

    await FirebaseAuth.instance.currentUser?.updateDisplayName(
  _nameCtrl.text.trim(),
);

await FirebaseAuth.instance.currentUser?.reload();

// Logout setelah register agar user wajib login
await FirebaseAuth.instance.signOut();

if (!mounted) return;

setState(() {
  _loading = false;
});

// Kembali ke halaman login
Navigator.of(context).pushAndRemoveUntil(
  PageRouteBuilder(
    pageBuilder: (_, __, ___) => const LoginPage(),
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 400),
  ),
  (route) => false,
);
  } on FirebaseAuthException catch (e) {
    String message;

    switch (e.code) {
      case 'email-already-in-use':
        message = 'Email sudah terdaftar';
        break;

      case 'weak-password':
        message = 'Password minimal 6 karakter';
        break;

      case 'invalid-email':
        message = 'Format email tidak valid';
        break;

      default:
        message = e.message ?? 'Registrasi gagal';
    }

    setState(() {
      _loading = false;
      _error = message;
    });
  } catch (e) {
    setState(() {
      _loading = false;
      _error = e.toString();
    });
  }
}

  @override
  Widget build(BuildContext context) {
    // Colors for minimalist design
    const bgLight = Color(0xFFFAFAFA);
    const inkPrimary = Color(0xFF111111);
    const inkSecondary = Color(0xFF6B7280);
    const fieldBg = Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: inkPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Minimalist Header
                const Text(
                  'Create an account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: inkPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join the premium cosplay community',
                  style: TextStyle(
                    fontSize: 14,
                    color: inkSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 40),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name Field
                      TextFormField(
                        controller: _nameCtrl,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: inkPrimary),
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          hintStyle: const TextStyle(color: inkSecondary, fontSize: 15),
                          filled: true,
                          fillColor: fieldBg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: inkSecondary, size: 22),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Masukkan nama' : null,
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      TextFormField(
                        controller: _emailCtrl,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: inkPrimary),
                        decoration: InputDecoration(
                          hintText: 'Email address',
                          hintStyle: const TextStyle(color: inkSecondary, fontSize: 15),
                          filled: true,
                          fillColor: fieldBg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.email_outlined, color: inkSecondary, size: 22),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Masukkan email' : null,
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: inkPrimary),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: const TextStyle(color: inkSecondary, fontSize: 15),
                          filled: true,
                          fillColor: fieldBg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: inkSecondary, size: 22),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: inkSecondary, size: 20),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Masukkan password' : null,
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmCtrl,
                        obscureText: _obscure,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: inkPrimary),
                        decoration: InputDecoration(
                          hintText: 'Confirm password',
                          hintStyle: const TextStyle(color: inkSecondary, fontSize: 15),
                          filled: true,
                          fillColor: fieldBg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: inkSecondary, size: 22),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Konfirmasi password' : null,
                      ),
                      const SizedBox(height: 12),

                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                        ),

                      // Register Button
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: inkPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _loading ? null : _doRegister,
                        child: _loading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            : const Text('Sign up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                      ),
                      const SizedBox(height: 24),

                      // Login Redirect
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? ', style: TextStyle(color: inkSecondary, fontSize: 14)),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: inkPrimary,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Log in', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
