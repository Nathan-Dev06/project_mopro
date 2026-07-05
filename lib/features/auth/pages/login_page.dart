import 'package:flutter/material.dart';
import 'package:project_mopro/features/auth/pages/register_page.dart';
import 'package:project_mopro/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_mopro/features/auth/pages/forgot_password_page.dart';
import 'package:project_mopro/features/admin/admin_navigation.dart';
import 'package:project_mopro/core/models/user_profile.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  Future<void> _doLogin() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );

    if (!mounted) return;

    setState(() => _loading = false);

    // Ambil data user dari Firestore untuk cek role (sinkronisasi dengan database)
    User? currentUser = FirebaseAuth.instance.currentUser;
    bool isAdmin = false;
    
    if (currentUser != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
        if (doc.exists) {
          isAdmin = doc.data()?['isAdmin'] ?? false;
          // Update local profile
          UserProfile.isAdmin = isAdmin;
          UserProfile.name = doc.data()?['name'] ?? '';
          UserProfile.email = doc.data()?['email'] ?? '';
        }
      } catch (e) {
        debugPrint('Error fetching user role: $e');
      }
    }

    if (!mounted) return;

    if (isAdmin) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AdminNavigationWrapper(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainNavigationWrapper(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (route) => false,
      );
    }

  } on FirebaseAuthException catch (e) {
    String message;

    switch (e.code) {
      case 'user-not-found':
        message = 'Email not registered';
        break;

      case 'wrong-password':
        message = 'Incorrect password';
        break;

      case 'invalid-email':
        message = 'Invalid email format';
        break;

      case 'invalid-credential':
        message = 'Incorrect email or password';
        break;

      default:
        message = e.message ?? 'Login failed';
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Minimalist Header
                const Icon(Icons.checkroom_rounded, size: 48, color: inkPrimary),
                const SizedBox(height: 24),
                const Text(
                  'Welcome to Cosvoria',
                  textAlign: TextAlign.center,
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
                  'Premium Cosplay Rental',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: inkSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 48),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email Field
                      TextFormField(
                        controller: _emailCtrl,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: inkPrimary),
                        decoration: InputDecoration(
                          hintText: 'Email address or username',
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
                        validator: (v) => (v == null || v.isEmpty) ? 'Please enter your email' : null,
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
                        validator: (v) => (v == null || v.isEmpty) ? 'Please enter your password' : null,
                      ),
                      const SizedBox(height: 12),

                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                        ),

                      // Login Button
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: inkPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _loading ? null : _doLogin,
                        child: _loading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            : const Text('Log in', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                      ),
                      const SizedBox(height: 16),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: inkSecondary,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordPage()));
                            },
                            child: const Text('Forgot password?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: inkPrimary,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage()));
                            },
                            child: const Text('Create account', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Social Login Section
                Row(
                  children: const [
                    Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('or continue with', style: TextStyle(color: inkSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                    Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: const [
                    Expanded(child: _SocialButton(icon: Icons.apple)),
                    SizedBox(width: 12),
                    Expanded(child: _SocialButton(icon: Icons.g_mobiledata)),
                    SizedBox(width: 12),
                    Expanded(child: _SocialButton(icon: Icons.facebook)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  
  const _SocialButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF111111),
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      onPressed: () {},
      child: Icon(icon, size: 28),
    );
  }
}
