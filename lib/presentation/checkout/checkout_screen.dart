import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/widgets.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/form_validator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../data/models/models.dart';
import '../../providers/cart_notifier.dart';
import '../../providers/order_notifier.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double shippingCost;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.shippingCost,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late PageController _pageController;
  int _currentStep = 0;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedShipping;
  String? _selectedPaymentMethod;
  bool _agreeToTerms = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _selectedShipping = 'reguler';
    _selectedPaymentMethod = 'transfer';

    // Listen untuk order success/error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderNotifier>().addListener(_handleOrderResponse);
    });
  }

  void _handleOrderResponse() {
    final orderNotifier = context.read<OrderNotifier>();

    if (orderNotifier.isLoading) {
      return; // Still loading
    }

    if (orderNotifier.error != null) {
      setState(() => _isProcessing = false);
      context.showErrorSnackBar(orderNotifier.error ?? 'Gagal membuat pesanan');
      orderNotifier.clearError();
      return;
    }

    if (orderNotifier.currentOrder != null) {
      setState(() => _isProcessing = false);
      context.showSuccessSnackBar('Pesanan berhasil dibuat!');

      // Clear cart
      context.read<CartNotifier>().clearCart();

      // Navigate back
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    context.read<OrderNotifier>().removeListener(_handleOrderResponse);
    super.dispose();
  }

  double _getShippingCost() {
    return _selectedShipping == 'express' ? 100000 : 50000;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentStep > 0) {
          _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
          centerTitle: true,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_currentStep > 0) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Column(
          children: [
            // Progress Indicator
            _buildProgressBar(),
            const SizedBox(height: 16),
            // Steps Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentStep = index);
                },
                children: [
                  _buildCustomerInfoStep(),
                  _buildShippingPaymentStep(),
                  _buildReviewStep(),
                ],
              ),
            ),
            // Navigation Buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Column(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? AppColors.primaryGreen
                        : AppColors.bgSecondary,
                    border: Border.all(
                      color: isActive
                          ? AppColors.primaryGreen
                          : AppColors.borderColor,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: AppTextStyles.buttonText.copyWith(
                        color: isActive
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ['Info', 'Pengiriman', 'Review'][index],
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isActive
                        ? AppColors.primaryGreen
                        : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCustomerInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informasi Pengiriman', style: AppTextStyles.headingThree),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Nama Lengkap',
            hint: 'Masukkan nama lengkap',
            controller: _nameController,
            validator: (value) => FormValidator.validateName(value),
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Email',
            hint: 'Masukkan email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => FormValidator.validateEmail(value),
            prefixIcon: Icons.email_outlined,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'No. Telepon',
            hint: 'Masukkan nomor telepon',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) => FormValidator.validatePhone(value),
            prefixIcon: Icons.phone_outlined,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Alamat Pengiriman',
            hint: 'Masukkan alamat lengkap',
            controller: _addressController,
            maxLines: 3,
            validator: (value) => FormValidator.validateAddress(value),
            prefixIcon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Catatan (Opsional)',
            hint: 'Tambahkan catatan untuk penjual',
            controller: _notesController,
            maxLines: 2,
            prefixIcon: Icons.note_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildShippingPaymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Metode Pengiriman', style: AppTextStyles.headingThree),
          const SizedBox(height: 12),
          _buildShippingOption('reguler', 'Reguler (5-7 hari)', 50000),
          const SizedBox(height: 8),
          _buildShippingOption('express', 'Express (1-2 hari)', 100000),
          const SizedBox(height: 24),
          Text('Metode Pembayaran', style: AppTextStyles.headingThree),
          const SizedBox(height: 12),
          _buildPaymentOption(
            'transfer',
            'Transfer Bank',
            Icons.account_balance_outlined,
          ),
          const SizedBox(height: 8),
          _buildPaymentOption(
            'ewallet',
            'E-Wallet (GoPay, OVO, Dana)',
            Icons.mobile_screen_share_outlined,
          ),
          const SizedBox(height: 8),
          _buildPaymentOption(
            'cod',
            'Bayar di Tempat (COD)',
            Icons.local_shipping_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildShippingOption(String value, String label, double cost) {
    return GestureDetector(
      onTap: () => setState(() => _selectedShipping = value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedShipping == value
                ? AppColors.primaryGreen
                : AppColors.borderColor,
            width: _selectedShipping == value ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: _selectedShipping == value
              ? AppColors.primaryGreen.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Radio(
              value: value,
              groupValue: _selectedShipping,
              onChanged: (val) => setState(() => _selectedShipping = val),
              activeColor: AppColors.primaryGreen,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.bodyMedium),
                  Text(
                    'Rp ${(cost / 1000).toStringAsFixed(0)}k',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedPaymentMethod == value
                ? AppColors.primaryGreen
                : AppColors.borderColor,
            width: _selectedPaymentMethod == value ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: _selectedPaymentMethod == value
              ? AppColors.primaryGreen.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Radio(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (val) => setState(() => _selectedPaymentMethod = val),
              activeColor: AppColors.primaryGreen,
            ),
            Icon(icon, color: AppColors.primaryGreen, size: 24),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    final total = widget.subtotal + _getShippingCost();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan Pesanan', style: AppTextStyles.headingThree),
          const SizedBox(height: 16),
          // Items List
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: List.generate(widget.cartItems.length, (index) {
                  final item = widget.cartItems[index];
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: AppTextStyles.bodyMedium,
                                ),
                                Text(
                                  'x${item.quantity}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            (item.totalPrice as num).toCurrency(),
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                      if (index < widget.cartItems.length - 1)
                        Divider(color: AppColors.borderColor, height: 12),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Customer Info Review
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Nama', style: AppTextStyles.bodySmall),
                      Text(
                        _nameController.text,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Email', style: AppTextStyles.bodySmall),
                      Text(
                        _emailController.text,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Telepon', style: AppTextStyles.bodySmall),
                      Text(
                        _phoneController.text,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Pricing Summary
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal', style: AppTextStyles.bodyMedium),
                      Text(
                        (widget.subtotal as num).toCurrency(),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ongkir', style: AppTextStyles.bodyMedium),
                      Text(
                        (_getShippingCost() as num).toCurrency(),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: AppColors.borderColor),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: AppTextStyles.titleSmall),
                      Text(
                        (total as num).toCurrency(),
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Terms Agreement
          Row(
            children: [
              Checkbox(
                value: _agreeToTerms,
                onChanged: (value) =>
                    setState(() => _agreeToTerms = value ?? false),
                activeColor: AppColors.primaryGreen,
              ),
              Expanded(
                child: Text(
                  'Saya setuju dengan syarat dan ketentuan',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        top: 12,
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: SecondaryButton(
                label: 'Kembali',
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: _currentStep == 2
                ? Consumer2<OrderNotifier, CartNotifier>(
                    builder: (context, orderNotifier, cartNotifier, _) {
                      return PrimaryButton(
                        label: _isProcessing ? 'Memproses...' : 'Buat Pesanan',
                        isLoading: _isProcessing,
                        isDisabled: !_agreeToTerms || _isProcessing,
                        onPressed: !_agreeToTerms || _isProcessing
                            ? () {}
                            : () {
                                if (_validateStep0() && _agreeToTerms) {
                                  setState(() => _isProcessing = true);

                                  orderNotifier.createOrder(
                                    customerName: _nameController.text,
                                    customerEmail: _emailController.text,
                                    customerPhone: _phoneController.text,
                                    customerAddress: _addressController.text,
                                    items: widget.cartItems,
                                    subtotal: widget.subtotal,
                                    shippingCost: _getShippingCost(),
                                    paymentMethod:
                                        _selectedPaymentMethod ?? 'transfer',
                                    notes: _notesController.text,
                                  );
                                }
                              },
                      );
                    },
                  )
                : PrimaryButton(
                    label: 'Lanjut',
                    onPressed: () {
                      if (_currentStep == 0 && _validateStep0()) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else if (_currentStep == 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool _validateStep0() {
    if (FormValidator.validateName(_nameController.text) != null) {
      context.showErrorSnackBar('Nama tidak valid');
      return false;
    }
    if (FormValidator.validateEmail(_emailController.text) != null) {
      context.showErrorSnackBar('Email tidak valid');
      return false;
    }
    if (FormValidator.validatePhone(_phoneController.text) != null) {
      context.showErrorSnackBar('No. telepon tidak valid');
      return false;
    }
    if (FormValidator.validateAddress(_addressController.text) != null) {
      context.showErrorSnackBar('Alamat tidak valid');
      return false;
    }
    return true;
  }
}
