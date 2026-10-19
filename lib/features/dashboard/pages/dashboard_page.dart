import 'package:flutter/material.dart';

import '../../../core/widgets/section_placeholder.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionPlaceholder(
      title: 'Dashboard',
      icon: Icons.dashboard_outlined,
      description:
      'Admin access verified. Live order and sales statistics will appear here once orders are connected.',
    );
  }
}