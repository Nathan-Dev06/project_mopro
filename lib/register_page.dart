import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'login_page.dart';
import 'main.dart';

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
      setState(() => _error = 'Password dan konfirmasi tidak cocok');
      return;
    }
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 300));
    final ok = AuthService.register(_emailCtrl.text.trim(), _nameCtrl.text.trim(), _passwordCtrl.text);
    setState(() { _loading = false; });
    if (ok) {
      // Auto-login the new user and navigate to main wrapper
      AuthService.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainNavigationWrapper(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (route) => false,
      );
    } else {
      setState(() => _error = 'Email sudah terdaftar');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF111111);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7F3FF), Color(0xFFE6F7F1)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 6))],
                  ),
                  child: const Center(child: Icon(Icons.checkroom_rounded, size: 38, color: Color(0xFF111111))),
                ),
                const SizedBox(height: 12),
                const Text('Buat Akun', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 18),

                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameCtrl,
                                decoration: InputDecoration(prefixIcon: const Icon(Icons.person_outline), labelText: 'Nama', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                                validator: (v) => (v==null||v.isEmpty)?'Masukkan nama':null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _emailCtrl,
                                decoration: InputDecoration(prefixIcon: const Icon(Icons.email_outlined), labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                                validator: (v) => (v==null||v.isEmpty)?'Masukkan email':null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscure,
                                decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_outline_rounded), labelText: 'Password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), suffixIcon: IconButton(icon: Icon(_obscure?Icons.visibility_off:Icons.visibility), onPressed: () => setState(()=>_obscure=!_obscure))),
                                validator: (v) => (v==null||v.isEmpty)?'Masukkan password':null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _confirmCtrl,
                                obscureText: _obscure,
                                decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_outline_rounded), labelText: 'Konfirmasi Password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                                validator: (v) => (v==null||v.isEmpty)?'Konfirmasi password':null,
                              ),
                              const SizedBox(height: 12),
                              if (_error != null) Padding(padding: const EdgeInsets.only(bottom:8.0), child: Text(_error!, style: const TextStyle(color: Colors.red))),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                  onPressed: _loading ? null : _doRegister,
                                  child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Daftar', style: TextStyle(fontWeight: FontWeight.w700)),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Sudah punya akun? '),
                                  TextButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())); }, child: const Text('Masuk')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
