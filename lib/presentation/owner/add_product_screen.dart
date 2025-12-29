import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../core/widgets/widgets.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/form_validator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../providers/product_notifier.dart';

class AddProductScreen extends StatefulWidget {
  final dynamic product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  String? _selectedCategory;
  bool _isSubmitting = false;
  File? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? '',
    );
    _selectedCategory = widget.product?.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Tambah Produk' : 'Edit Produk'),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePreview(),
            const SizedBox(height: 24),
            CustomTextField(
              label: 'Nama Produk',
              hint: 'Masukkan nama produk',
              controller: _nameController,
              validator: (value) => FormValidator.validateProductName(value),
              prefixIcon: Icons.shopping_bag_outlined,
            ),
            const SizedBox(height: 12),
            _buildCategoryDropdown(),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Deskripsi',
              hint: 'Masukkan deskripsi produk',
              controller: _descriptionController,
              maxLines: 4,
              validator: (value) => FormValidator.validateDescription(value),
              prefixIcon: Icons.description_outlined,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Harga (Rp)',
              hint: 'Masukkan harga',
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) => FormValidator.validatePrice(value),
              prefixIcon: Icons.attach_money_outlined,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Stok',
              hint: 'Masukkan jumlah stok',
              controller: _stockController,
              keyboardType: TextInputType.number,
              validator: (value) => FormValidator.validateStock(value),
              prefixIcon: Icons.inventory_2_outlined,
            ),
            const SizedBox(height: 24),
            Consumer<ProductNotifier>(
              builder: (context, productNotifier, _) {
                return PrimaryButton(
                  label: _isSubmitting
                      ? 'Memproses...'
                      : (widget.product == null
                            ? 'Tambah Produk'
                            : 'Simpan Perubahan'),
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? () {} : _submitForm,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gambar Produk', style: AppTextStyles.titleSmall),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.bgSecondary,
              border: Border.all(
                color: _selectedImageFile != null
                    ? AppColors.primaryGreenLight
                    : AppColors.borderColor,
                width: 2,
              ),
            ),
            child: _selectedImageFile != null && _selectedImageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _selectedImageBytes!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_a_photo_outlined,
                        color: AppColors.primaryGreen,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap untuk pilih gambar',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'dari laptop atau device',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (_selectedImageFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedImageFile = null;
                    _selectedImageBytes = null;
                  });
                },
                icon: const Icon(Icons.clear, size: 18),
                label: const Text('Hapus gambar'),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageFile = File(pickedFile.path);
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Gagal memilih gambar: $e');
      }
    }
  }

  Widget _buildCategoryDropdown() {
    // Predefined categories
    final List<Map<String, String>> categories = [
      {'id': 'tenda', 'name': 'Tenda'},
      {'id': 'tas', 'name': 'Tas'},
      {'id': 'sepatu', 'name': 'Sepatu'},
      {'id': 'survival', 'name': 'Survival'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kategori', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _selectedCategory,
            isExpanded: true,
            hint: const Text('Pilih kategori'),
            underline: const SizedBox(),
            items: categories
                .map(
                  (category) => DropdownMenuItem<String>(
                    value: category['id'],
                    child: Text(category['name']!),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCategory = value);
              }
            },
          ),
        ),
        if (_selectedCategory == null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Pilih kategori terlebih dahulu',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.errorColor,
              ),
            ),
          ),
      ],
    );
  }

  void _submitForm() async {
    // Validate
    if (FormValidator.validateProductName(_nameController.text) != null) {
      context.showErrorSnackBar('Nama produk tidak valid');
      return;
    }
    if (FormValidator.validateDescription(_descriptionController.text) !=
        null) {
      context.showErrorSnackBar('Deskripsi tidak valid');
      return;
    }
    if (FormValidator.validatePrice(_priceController.text) != null) {
      context.showErrorSnackBar('Harga tidak valid');
      return;
    }
    if (FormValidator.validateStock(_stockController.text) != null) {
      context.showErrorSnackBar('Stok tidak valid');
      return;
    }
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      context.showErrorSnackBar('Pilih kategori');
      return;
    }
    setState(() => _isSubmitting = true);

    final productNotifier = context.read<ProductNotifier>();
    final price = double.parse(_priceController.text);
    final stock = int.parse(_stockController.text);

    bool success;

    if (widget.product == null) {
      // Create new product
      if (_selectedImageBytes != null) {
        // With image
        success = await productNotifier.createProductWithImageBytes(
          categoryId: _selectedCategory!,
          name: _nameController.text,
          description: _descriptionController.text,
          price: price,
          stock: stock,
          imageBytes: _selectedImageBytes!,
        );
      } else {
        // Without image
        success = await productNotifier.createProduct(
          name: _nameController.text,
          description: _descriptionController.text,
          price: price,
          stock: stock,
          categoryId: _selectedCategory!,
        );
      }
    } else {
      // Update existing product
      if (_selectedImageBytes != null) {
        // With new image
        success = await productNotifier.updateProductWithImageBytes(
          productId: widget.product.id,
          categoryId: _selectedCategory!,
          name: _nameController.text,
          description: _descriptionController.text,
          price: price,
          stock: stock,
          imageBytes: _selectedImageBytes!,
        );
      } else {
        // Without new image
        success = await productNotifier.updateProduct(
          productId: widget.product.id,
          name: _nameController.text,
          description: _descriptionController.text,
          price: price,
          stock: stock,
          categoryId: _selectedCategory!,
        );
      }
    }

    if (success && mounted) {
      context.showSuccessSnackBar(
        widget.product == null
            ? 'Produk berhasil ditambahkan'
            : 'Produk berhasil diperbarui',
      );
      Navigator.pop(context);
    } else if (mounted) {
      setState(() => _isSubmitting = false);
      context.showErrorSnackBar(
        productNotifier.error ?? 'Gagal menyimpan produk',
      );
    }
  }
}
