import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {
      _formKey.currentState?.reset();
    }));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isLogin => _tabController.index == 0;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await AuthService().login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await AuthService().register(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        String message = 'Bir hata oluştu.';
        final errorStr = e.toString();
        if (errorStr.contains('user-not-found')) {
          message = 'Bu e-posta ile kayıtlı kullanıcı bulunamadı.';
        } else if (errorStr.contains('wrong-password') || errorStr.contains('invalid-credential')) {
          message = 'Hatalı e-posta veya şifre.';
        } else if (errorStr.contains('email-already-in-use')) {
          message = 'Bu e-posta adresi zaten kullanılıyor.';
        } else if (errorStr.contains('weak-password')) {
          message = 'Şifre en az 6 karakter olmalıdır.';
        } else if (errorStr.contains('invalid-email')) {
          message = 'Geçersiz e-posta adresi.';
        } else {
          message = 'Hata: $errorStr'; // Orijinal hatayı ekrana bas
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo / Başlık
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 56,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "YKS Rehber",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Akıllı Ders Takip Uygulaması",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Cam Kart
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.6),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Tab Bar
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: TabBar(
                                  controller: _tabController,
                                  indicator: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  dividerColor: Colors.transparent,
                                  labelColor: const Color(0xFF4F46E5),
                                  unselectedLabelColor: const Color(0xFF64748B),
                                  labelStyle: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                  unselectedLabelStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                  tabs: const [
                                    Tab(text: "Giriş Yap"),
                                    Tab(text: "Kayıt Ol"),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Form
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // E-posta
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: _inputDecoration(
                                        "E-posta",
                                        Icons.email_rounded,
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'E-posta boş bırakılamaz';
                                        }
                                        if (!val.contains('@') || !val.contains('.')) {
                                          return 'Geçerli bir e-posta girin';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    // Şifre
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      decoration: _inputDecoration(
                                        "Şifre",
                                        Icons.lock_rounded,
                                        suffix: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                            color: const Color(0xFF64748B),
                                            size: 20,
                                          ),
                                          onPressed: () => setState(
                                              () => _obscurePassword = !_obscurePassword),
                                        ),
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Şifre boş bırakılamaz';
                                        }
                                        if (val.length < 6) {
                                          return 'Şifre en az 6 karakter olmalı';
                                        }
                                        return null;
                                      },
                                    ),

                                    // Şifre Tekrar (sadece kayıt modunda)
                                    if (!_isLogin) ...[
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _confirmPasswordController,
                                        obscureText: _obscureConfirm,
                                        decoration: _inputDecoration(
                                          "Şifre Tekrar",
                                          Icons.lock_outline_rounded,
                                          suffix: IconButton(
                                            icon: Icon(
                                              _obscureConfirm
                                                  ? Icons.visibility_off_rounded
                                                  : Icons.visibility_rounded,
                                              color: const Color(0xFF64748B),
                                              size: 20,
                                            ),
                                            onPressed: () => setState(
                                                () => _obscureConfirm = !_obscureConfirm),
                                          ),
                                        ),
                                        validator: (val) {
                                          if (val != _passwordController.text) {
                                            return 'Şifreler eşleşmiyor';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],

                                    const SizedBox(height: 28),

                                    // Giriş/Kayıt Butonu
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: _isLoading ? null : _submit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF4F46E5),
                                          disabledBackgroundColor:
                                              const Color(0xFF4F46E5).withOpacity(0.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.5,
                                                ),
                                              )
                                            : Text(
                                                _isLogin ? "Giriş Yap" : "Kayıt Ol",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 17,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
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
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF4F46E5), size: 22),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.8), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE0E7FF), Color(0xFFF3E8FF), Color(0xFFF8FAFC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: -80,
          left: -60,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: 60,
              sigmaY: 60,
              tileMode: TileMode.decal,
            ),
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF818CF8).withOpacity(0.5),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 60,
          right: -70,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: 70,
              sigmaY: 70,
              tileMode: TileMode.decal,
            ),
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFC084FC).withOpacity(0.4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
