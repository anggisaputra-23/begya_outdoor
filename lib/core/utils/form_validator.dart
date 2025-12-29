/// Form validation helpers untuk Begya Outdoor
class FormValidator {
  /// Validate email format
  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Email tidak boleh kosong';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value!)) {
      return 'Format email tidak valid';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Password tidak boleh kosong';
    }

    if (value!.length < 6) {
      return 'Password minimal 6 karakter';
    }

    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirm(String? value, String passwordValue) {
    if (value?.isEmpty ?? true) {
      return 'Konfirmasi password tidak boleh kosong';
    }

    if (value != passwordValue) {
      return 'Password tidak cocok';
    }

    return null;
  }

  /// Validate name
  static String? validateName(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Nama tidak boleh kosong';
    }

    if (value!.length < 3) {
      return 'Nama minimal 3 karakter';
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Nama hanya boleh mengandung huruf dan spasi';
    }

    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Nomor telepon tidak boleh kosong';
    }

    final phoneRegex = RegExp(r'^[0-9]{10,}$');
    final cleanedPhone = value!.replaceAll(RegExp(r'[^\d]'), '');

    if (!phoneRegex.hasMatch(cleanedPhone)) {
      return 'Nomor telepon tidak valid (minimal 10 digit)';
    }

    return null;
  }

  /// Validate address
  static String? validateAddress(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Alamat tidak boleh kosong';
    }

    if (value!.length < 5) {
      return 'Alamat minimal 5 karakter';
    }

    return null;
  }

  /// Validate product name
  static String? validateProductName(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Nama produk tidak boleh kosong';
    }

    if (value!.length < 3) {
      return 'Nama produk minimal 3 karakter';
    }

    if (value.length > 100) {
      return 'Nama produk maksimal 100 karakter';
    }

    return null;
  }

  /// Validate product description
  static String? validateDescription(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Deskripsi tidak boleh kosong';
    }

    return null;
  }

  /// Validate price
  static String? validatePrice(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Harga tidak boleh kosong';
    }

    try {
      final price = double.parse(value!);
      if (price <= 0) {
        return 'Harga harus lebih dari 0';
      }
      return null;
    } catch (e) {
      return 'Format harga tidak valid';
    }
  }

  /// Validate stock
  static String? validateStock(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Stok tidak boleh kosong';
    }

    try {
      final stock = int.parse(value!);
      if (stock < 0) {
        return 'Stok tidak boleh negatif';
      }
      return null;
    } catch (e) {
      return 'Format stok harus berupa angka';
    }
  }

  /// Validate quantity
  static String? validateQuantity(String? value, int maxStock) {
    if (value?.isEmpty ?? true) {
      return 'Jumlah tidak boleh kosong';
    }

    try {
      final quantity = int.parse(value!);
      if (quantity <= 0) {
        return 'Jumlah harus lebih dari 0';
      }
      if (quantity > maxStock) {
        return 'Jumlah tidak boleh lebih dari stok tersedia';
      }
      return null;
    } catch (e) {
      return 'Format jumlah harus berupa angka';
    }
  }

  /// Generic required field validator
  static String? validateRequired(String? value, String fieldName) {
    if (value?.isEmpty ?? true) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  /// Validate username
  static String? validateUsername(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Username tidak boleh kosong';
    }

    if (value!.length < 3) {
      return 'Username minimal 3 karakter';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username hanya boleh mengandung huruf, angka, dan underscore';
    }

    return null;
  }
}
