<<<<<<< HEAD

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
=======
import 'package:flutter/material.dart';

import '../../../core/widgets/section_placeholder.dart';
>>>>>>> origin/main

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final email = context.select((AuthCubit c) => c.state.email);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Handa Grocery Admin'),
        actions: [
          if (email != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(email),
              ),
            ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) => const Center(
          child: Text('Admin access verified. Dashboard coming next.'),
        ),
      ),
    );
  }
}
=======
    return const SectionPlaceholder(
      title: 'Dashboard',
      icon: Icons.dashboard_outlined,
      description:
      'Admin access verified. Live order and sales statistics will appear here once orders are connected.',
    );
  }
}
>>>>>>> origin/main
