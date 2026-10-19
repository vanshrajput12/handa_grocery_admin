import 'package:flutter/material.dart';

class NavItem {
  const NavItem(this.label, this.icon, this.path);

  final String label;
  final IconData icon;
  final String path;
}

/// Sidebar sections, in display order. Logout is handled separately.
const List<NavItem> adminNavItems = [
  NavItem('Dashboard', Icons.dashboard_outlined, '/dashboard'),
  NavItem('Orders', Icons.receipt_long_outlined, '/orders'),
  NavItem('Products', Icons.shopping_basket_outlined, '/products'),
  NavItem('Categories', Icons.category_outlined, '/categories'),
  NavItem('Inventory', Icons.inventory_outlined, '/inventory'),
  NavItem('Customers', Icons.people_outline, '/customers'),
  NavItem('Delivery Partners', Icons.delivery_dining_outlined, '/delivery'),
  NavItem('Reports', Icons.bar_chart_outlined, '/reports'),
  NavItem('Settings', Icons.settings_outlined, '/settings'),
];