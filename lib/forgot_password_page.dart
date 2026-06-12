import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  bool _loading = false;
  String? _message;

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _message = "Masukkan email";
      });
      return;
    }

    final emailRegex = RegExp(
      r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
    );

    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _message = "Format email tidak valid";
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      setState(() {
        _message =
            "Link reset password telah dikirim ke email Anda.";
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _message = e.message ?? "Gagal mengirim email reset";
      });
    }

    setState(() {
      _loading = false;
    });
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
          colors: [
            Color(0xFFF7F3FF),
            Color(0xFFE6F7F1),
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 40,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock_reset_rounded,
                    size: 44,
                    color: Color(0xFF111111),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'RESET PASSWORD',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Masukkan email yang terdaftar',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 22),

              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.email_outlined),
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                          ),
                          onPressed:
                              _loading ? null : _resetPassword,
                          child: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Kirim Link Reset',
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),

                      if (_message != null) ...[
                        const SizedBox(height: 12),

                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _message!
                                    .toLowerCase()
                                    .contains('dikirim')
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          child: Text(
                            _message!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _message!
                                      .toLowerCase()
                                      .contains('dikirim')
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 18,
                        ),
                        label:
                            const Text('Kembali ke Login'),
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