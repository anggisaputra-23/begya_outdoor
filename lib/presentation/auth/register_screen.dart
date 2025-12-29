import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/widgets.dart';
import '../../providers/auth_notifier.dart';

/// Register Screen untuk mendaftar akun baru
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  String _selectedRole = 'customer'; // 'customer' atau 'owner'

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      context.showErrorSnackBar(
        'Anda harus setuju dengan syarat dan ketentuan',
      );
      return;
    }

    setState(() => _isLoading = true);

    final authNotifier = context.read<AuthNotifier>();
    final success = await authNotifier.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text,
      phone: _phoneController.text,
      role: _selectedRole,
    );

    if (success && mounted) {
      context.showSuccessSnackBar('Akun berhasil dibuat!');
      context.go(_selectedRole == 'owner' ? '/owner-dashboard' : '/home');
    } else if (mounted) {
      setState(() => _isLoading = false);
      context.showErrorSnackBar(authNotifier.error ?? 'Pendaftaran gagal');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => GoRouter.of(context).pop(),
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),

                  const SizedBox(height: 24),

                  // Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.person_add_outlined,
                            size: 40,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text('Buat Akun Baru', style: AppTextStyles.heading2),
                        const SizedBox(height: 8),
                        Text(
                          'Daftar untuk bergabung dengan Begya Outdoor',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Full Name
                  CustomTextField(
                    label: 'Nama Lengkap',
                    hint: 'Masukkan nama lengkap Anda',
                    controller: _nameController,
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Email
                  CustomTextField(
                    label: 'Email',
                    hint: 'Masukkan email Anda',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!value!.isValidEmail()) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Phone
                  CustomTextField(
                    label: 'Nomor Telepon',
                    hint: 'Contoh: 082xxxxxxxxx',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Nomor telepon tidak boleh kosong';
                      }
                      if (!value!.isValidPhone()) {
                        return 'Format nomor telepon tidak valid';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Password
                  CustomTextField(
                    label: 'Password',
                    hint: 'Minimal 6 karakter',
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: _showPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    onSuffixIconPressed: () {
                      setState(() => _showPassword = !_showPassword);
                    },
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Password tidak boleh kosong';
                      }
                      if (value!.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Confirm Password
                  CustomTextField(
                    label: 'Konfirmasi Password',
                    hint: 'Ketik ulang password Anda',
                    controller: _confirmPasswordController,
                    obscureText: !_showConfirmPassword,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: _showConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    onSuffixIconPressed: () {
                      setState(
                        () => _showConfirmPassword = !_showConfirmPassword,
                      );
                    },
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Konfirmasi password tidak boleh kosong';
                      }
                      if (value != _passwordController.text) {
                        return 'Password tidak cocok';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Role Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tipe Akun', style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedRole = 'customer'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _selectedRole == 'customer'
                                        ? AppColors.primaryGreen
                                        : AppColors.borderColor,
                                    width: _selectedRole == 'customer' ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: _selectedRole == 'customer'
                                      ? AppColors.primaryGreen.withOpacity(0.05)
                                      : Colors.transparent,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.shopping_cart_outlined,
                                      color: _selectedRole == 'customer'
                                          ? AppColors.primaryGreen
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Pembeli',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: _selectedRole == 'customer'
                                            ? AppColors.primaryGreen
                                            : AppColors.textSecondary,
                                        fontWeight: _selectedRole == 'customer'
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedRole = 'owner'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _selectedRole == 'owner'
                                        ? AppColors.primaryGreen
                                        : AppColors.borderColor,
                                    width: _selectedRole == 'owner' ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: _selectedRole == 'owner'
                                      ? AppColors.primaryGreen.withOpacity(0.05)
                                      : Colors.transparent,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.store_outlined,
                                      color: _selectedRole == 'owner'
                                          ? AppColors.primaryGreen
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Penjual',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: _selectedRole == 'owner'
                                            ? AppColors.primaryGreen
                                            : AppColors.textSecondary,
                                        fontWeight: _selectedRole == 'owner'
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Terms Checkbox
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() => _agreeToTerms = value ?? false);
                          },
                          activeColor: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Saya setuju dengan syarat dan ketentuan',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Register Button
                  PrimaryButton(
                    label: 'Daftar',
                    isLoading: _isLoading,
                    onPressed: _handleRegister,
                  ),

                  const SizedBox(height: 20),

                  // Login Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: AppTextStyles.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () => GoRouter.of(context).pop(),
                          child: Text(
                            'Masuk di sini',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
