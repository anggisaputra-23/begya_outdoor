import 'package:flutter/material.dart';

/// Helper untuk membuat spacing yang konsisten
class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Helper untuk border radius yang konsisten
class Radii {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double full = 99999;
}

/// Helper untuk shadow
class Shadows {
  static const BoxShadow light = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 4,
    offset: Offset(0, 1),
  );

  static const BoxShadow medium = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow large = BoxShadow(
    color: Color(0x24000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  static List<BoxShadow> listShadow = [light, medium];
}

/// Extension untuk BuildContext
extension BuildContextExtension on BuildContext {
  // Media Query Helpers
  bool get isSmallScreen => MediaQuery.of(this).size.width < 600;

  bool get isMediumScreen =>
      MediaQuery.of(this).size.width >= 600 &&
      MediaQuery.of(this).size.width < 900;

  bool get isLargeScreen => MediaQuery.of(this).size.width >= 900;

  double get screenWidth => MediaQuery.of(this).size.width;

  double get screenHeight => MediaQuery.of(this).size.height;

  // Safe padding untuk notch/cutout
  EdgeInsets get safePadding => MediaQuery.of(this).padding;

  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  // Orientation
  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;

  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  // Theme
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;

  // Navigation
  void pop<T>([T? result]) => Navigator.pop(this, result);

  Future<T?> push<T>(Route<T> route) => Navigator.push(this, route);

  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) =>
      Navigator.pushNamed(this, routeName, arguments: arguments);

  Future<T?> pushReplacementNamed<T, TO>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) => Navigator.pushReplacementNamed(
    this,
    routeName,
    result: result,
    arguments: arguments,
  );

  // Snackbar
  void showSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
      ),
    );
  }

  // Toast-like messages
  void showSuccessSnackBar(String message) {
    showSnackBar(message: message, backgroundColor: Colors.green);
  }

  void showErrorSnackBar(String message) {
    showSnackBar(message: message, backgroundColor: Colors.red);
  }

  void showInfoSnackBar(String message) {
    showSnackBar(message: message, backgroundColor: Colors.blue);
  }
}

/// String extensions
extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  bool isValidEmail() {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(this);
  }

  bool isValidPhone() {
    return RegExp(r'^[0-9]{10,}$').hasMatch(replaceAll(RegExp(r'[^\d]'), ''));
  }

  String formatAsCurrency({String symbol = 'Rp', int decimals = 0}) {
    try {
      final number = double.parse(this);
      if (decimals == 0) {
        return '$symbol ${number.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
      }
      return '$symbol ${number.toStringAsFixed(decimals)}';
    } catch (e) {
      return this;
    }
  }

  /// Remove white spaces
  String removeWhiteSpace() => replaceAll(' ', '');
}

/// Number extensions
extension NumExtension on num {
  /// Format as currency
  String toCurrency({String symbol = 'Rp', int decimals = 0}) {
    if (decimals == 0) {
      return '$symbol ${toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
    }
    return '$symbol ${toStringAsFixed(decimals).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
  }

  /// Format as percentage
  String toPercentage({int decimals = 1}) {
    return '${toStringAsFixed(decimals)}%';
  }
}

/// DateTime extensions
extension DateTimeExtension on DateTime {
  /// Format tanggal ke format yang readable
  String formatDate({String pattern = 'd MMM yyyy'}) {
    // Simple implementation - bisa diperluas dengan intl package
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '$day ${months[month - 1]} $year';
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Get readable time
  String get readableTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return formatDate();
    }
  }
}

/// List extensions
extension ListExtension<T> on List<T> {
  /// Safely get item by index
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Check if list is empty or null
  bool get isEmptyOrNull => isEmpty;

  /// Check if list has items
  bool get isNotEmptyAndNotNull => isNotEmpty;
}
