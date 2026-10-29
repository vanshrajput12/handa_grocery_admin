import 'package:flutter/material.dart';
import 'package:handa_grocery_admin/features/dashboard/pages/product_page.dart';
import '../../orders/pages/orders_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 12,
                spacing: 16,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, Admin 👋',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Welcome to your Handa Grocery dashboard.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: colors.primaryContainer,
                    child: Icon(
                      Icons.storefront,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Welcome banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFEF8B25),
                      Color(0xFFE96B16),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.shopping_basket_outlined,
                      color: Colors.white,
                      size: 38,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Manage your grocery business',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Manage products, review orders, and keep your '
                          'store up to date from one place.',
                      style: TextStyle(
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Overview',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),

              // Summary cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 850
                      ? 4
                      : constraints.maxWidth >= 500
                      ? 2
                      : 1;

                  final cardWidth =
                      (constraints.maxWidth - (columns - 1) * 14) /
                          columns;

                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: const _OverviewCard(
                          title: 'Products',
                          value: 'Manage',
                          icon: Icons.inventory_2_outlined,
                          color: Color(0xFF2878D0),
                          subtitle: 'Add, edit and remove items',
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: const _OverviewCard(
                          title: 'Orders',
                          value: 'Review',
                          icon: Icons.receipt_long_outlined,
                          color: Color(0xFF169B62),
                          subtitle: 'View customer orders',
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: const _OverviewCard(
                          title: 'Categories',
                          value: 'Browse',
                          icon: Icons.category_outlined,
                          color: Color(0xFF8757CB),
                          subtitle: 'Organize grocery products',
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: const _OverviewCard(
                          title: 'Store',
                          value: 'Active',
                          icon: Icons.store_outlined,
                          color: Color(0xFFDE8522),
                          subtitle: 'Handa Grocery admin',
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),

              Text(
                'Quick Actions',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),

              // Quick actions
              _ActionCard(
                icon: Icons.inventory_2_outlined,
                title: 'Manage Products',
                description:
                'Add new grocery products, update prices, or delete items.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductsPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              _ActionCard(
                icon: Icons.receipt_long_outlined,
                title: 'Manage Orders',
                description:
                'Review orders placed by customers and check their status.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OrdersPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Information panel
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFFE98220),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Live business statistics',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Order totals, revenue, and product counts '
                                'are not connected to live queries yet. '
                                'Connect them to Firestore before displaying '
                                'real business figures.',
                            style: TextStyle(
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0DF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFE98220)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(description),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
