// File: lib/screens/register_screen.dart
// Kaam: Naya account banana — username, email, password, optional referral code
// Firebase mein user save karna + username uniqueness check

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String? prefillReferral;

  const RegisterScreen({super.key, this.prefillReferral});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _referralCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.prefillReferral != null) {
      _referralCtrl.text = widget.prefillReferral!;
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _referralCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final result = await AuthService().register(
      username: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      referralCode: _referralCtrl.text.trim().isEmpty
          ? null
          : _referralCtrl.text.trim(),
    );

    setState(() => _loading = false);

    if (!mounted) return;

    if (result.isSuccess) {
      Helpers.showSnackBar(context, 'Welcome! You got 100 coins bonus 🎉');
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      Helpers.showSnackBar(context, result.errorMessage!, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              const Text(
                'Create Account',
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Join and start earning daily rewards',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),

              // New user bonus badge
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🎁', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 8),
                    Text(
                      'Get 100 coins FREE on joining!',
                      style: TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Username
                    TextFormField(
                      controller: _usernameCtrl,
                      style: const TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: AppStrings.username,
                        hintText: 'e.g. john123',
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary),
                        helperText: 'Lowercase letters, numbers, underscore (3-20)',
                        helperStyle: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Username required';
                        if (!Helpers.isValidUsername(v)) {
                          return AppStrings.usernameInvalid;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: AppStrings.email,
                        prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email required';
                        if (!Helpers.isValidEmail(v)) return 'Invalid email';
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: AppStrings.password,
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password required';
                        if (!Helpers.isValidPassword(v)) return AppStrings.weakPassword;
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Referral code (optional)
                    TextFormField(
                      controller: _referralCtrl,
                      style: const TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: AppStrings.referralCode,
                        prefixIcon: Icon(Icons.card_giftcard_outlined, color: AppColors.textSecondary),
                        hintText: 'e.g. JOHN1234',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Create Account'),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: const Text(
                    AppStrings.alreadyHaveAccount,
                    style: TextStyle(color: AppColors.accent),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
