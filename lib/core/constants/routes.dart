/// Route paths untuk navigasi aplikasi Begya Outdoor
class AppRoutes {
  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Customer Routes
  static const String home = '/home';
  static const String productDetail = '/product/:id';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order-confirmation';
  static const String orderHistory = '/order-history';
  static const String orderDetail = '/order-detail/:id';

  // Owner Routes
  static const String ownerDashboard = '/owner-dashboard';
  static const String productManagement = '/product-management';
  static const String addProduct = '/add-product';
  static const String editProduct = '/edit-product/:id';
  static const String orderManagement = '/order-management';
  static const String ownerOrderDetail = '/owner-order-detail/:id';

  // Common Routes
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notFound = '/not-found';
}

/// Named routes untuk GoRouter
class Routes {
  // Navigation names
  static const String splashName = 'splash';
  static const String loginName = 'login';
  static const String registerName = 'register';
  static const String homeName = 'home';
  static const String productDetailName = 'product_detail';
  static const String cartName = 'cart';
  static const String checkoutName = 'checkout';
  static const String orderHistoryName = 'order_history';
  static const String ownerDashboardName = 'owner_dashboard';
  static const String productManagementName = 'product_management';
  static const String addProductName = 'add_product';
  static const String editProductName = 'edit_product';
}
