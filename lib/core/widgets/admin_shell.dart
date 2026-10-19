import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/cubit/auth_cubit.dart';
import '../routing/nav_items.dart';

const double _wideBreakpoint = 900;
const double _sidebarWidth = 260;

Future<void> _confirmLogout(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Log out?'),
      content: const Text('You will need to sign in again to manage the store.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Log out'),
        ),
      ],
    ),
  );
  if (ok == true && context.mounted) {
    context.read<AuthCubit>().signOut();
  }
}

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final i = adminNavItems.indexWhere(
          (n) => loc == n.path || loc.startsWith('${n.path}/'),
    );
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedIndex(context);
    final title = adminNavItems[selected].label;
    final email = context.select((AuthCubit c) => c.state.email);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _wideBreakpoint;

        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                Container(
                  width: _sidebarWidth,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: _SidebarContent(selectedIndex: selected),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _TopBar(title: title, email: email),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
          ),
          drawer: Drawer(
            child: Builder(
              builder: (drawerContext) => _SidebarContent(
                selectedIndex: selected,
                onNavigate: () => Navigator.of(drawerContext).pop(),
              ),
            ),
          ),
          body: child,
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.email});

  final String title;
  final String? email;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          if (email != null) ...[
            const Icon(Icons.account_circle_outlined, size: 20),
            const SizedBox(width: 8),
            Text(email!),
          ],
        ],
      ),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  const _SidebarContent({required this.selectedIndex, this.onNavigate});

  final int selectedIndex;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(Icons.storefront_rounded, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Handa Grocery',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: adminNavItems.length,
              itemBuilder: (context, i) {
                final item = adminNavItems[i];
                final isSelected = i == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: ListTile(
                    leading: Icon(item.icon),
                    title: Text(item.label),
                    selected: isSelected,
                    selectedColor: scheme.primary,
                    selectedTileColor: scheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onTap: () {
                      onNavigate?.call();
                      context.go(item.path);
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ListTile(
              leading: Icon(Icons.logout, color: scheme.error),
              title: Text('Logout', style: TextStyle(color: scheme.error)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () {
                onNavigate?.call();
                _confirmLogout(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}