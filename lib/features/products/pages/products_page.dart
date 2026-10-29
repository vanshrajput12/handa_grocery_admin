import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/product_model.dart';
import '../../../services/product_service.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/product_thumb.dart';

const _line = Color(0xFFEDE8DA);
final _money = NumberFormat.decimalPattern('en_IN');

String _priceLabel(dynamic price) {
  if (price is num) return '₹${_money.format(price)}';
  final s = (price ?? '').toString().trim();
  if (s.isEmpty) return '—';
  return s.contains('₹') ? s : '₹$s';
}

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductsCubit(ProductService()),
      child: const _ProductsView(),
    );
  }
}

class _ProductsView extends StatefulWidget {
  const _ProductsView();

  @override
  State<_ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<_ProductsView> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openForm(BuildContext context, ProductModel? product) {
    final cubit = context.read<ProductsCubit>();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProductFormDialog(cubit: cubit, existing: product),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ProductModel p) async {
    final cubit = context.read<ProductsCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text(
          '"${p.name}" will be removed from ${p.category} and will disappear '
          'from the customer app. Past orders are not affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(foregroundColor: AppColors.ink),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(0, 40),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) await cubit.delete(p);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductsCubit, ProductsState>(
      listenWhen: (p, c) => p.noticeSeq != c.noticeSeq && c.notice != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(state.notice!),
              backgroundColor:
                  state.noticeIsError ? AppColors.error : AppColors.ink,
            ),
          );
      },
      child: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final pad = constraints.maxWidth >= 700 ? 24.0 : 16.0;
              final width = math.min(constraints.maxWidth - pad * 2, 1280.0);
              return SingleChildScrollView(
                padding: EdgeInsets.all(pad),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Toolbar(
                          controller: _searchCtrl,
                          state: state,
                          onAdd: () => _openForm(context, null),
                        ),
                        const SizedBox(height: 14),
                        if (state.loadStatus == ProductsLoadStatus.loaded)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Showing ${state.filtered.length} of ${state.products.length} products  •  live',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        _Body(
                          state: state,
                          width: width,
                          onEdit: (p) => _openForm(context, p),
                          onDelete: (p) => _confirmDelete(context, p),
                          onAdd: () => _openForm(context, null),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.controller,
    required this.state,
    required this.onAdd,
  });

  final TextEditingController controller;
  final ProductsState state;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductsCubit>();

    final search = TextField(
      controller: controller,
      onChanged: cubit.setQuery,
      decoration: InputDecoration(
        hintText: 'Search products',
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        suffixIcon: state.query.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.close),
                onPressed: () {
                  controller.clear();
                  cubit.setQuery('');
                },
              ),
      ),
    );

    final dropdown = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: state.category,
          hint: const Text('All categories'),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('All categories'),
            ),
            for (final c in kProductCategories)
              DropdownMenuItem<String?>(value: c, child: Text(c)),
          ],
          onChanged: cubit.setCategory,
        ),
      ),
    );

    final add = FilledButton.icon(
      onPressed: onAdd,
      icon: const Icon(Icons.add_rounded, size: 20),
      label: const Text('Add product'),
    );

    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 640) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              search,
              const SizedBox(height: 10),
              dropdown,
              const SizedBox(height: 10),
              add,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: search),
            const SizedBox(width: 12),
            dropdown,
            const SizedBox(width: 12),
            add,
          ],
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.state,
    required this.width,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
  });

  final ProductsState state;
  final double width;
  final void Function(ProductModel) onEdit;
  final void Function(ProductModel) onDelete;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    switch (state.loadStatus) {
      case ProductsLoadStatus.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 80),
          child: Center(child: CircularProgressIndicator()),
        );
      case ProductsLoadStatus.error:
        return _Message(
          icon: Icons.error_outline,
          title: 'Could not load products',
          message: state.errorMessage ?? 'Something went wrong.',
          actionLabel: 'Retry',
          onAction: () => context.read<ProductsCubit>().start(),
        );
      case ProductsLoadStatus.loaded:
        if (state.products.isEmpty) {
          return _Message(
            icon: Icons.shopping_basket_outlined,
            title: 'No products yet',
            message: 'Add your first product and it will appear in the customer app.',
            actionLabel: 'Add product',
            onAction: onAdd,
          );
        }
        final items = state.filtered;
        if (items.isEmpty) {
          return const _Message(
            icon: Icons.search_off,
            title: 'No matching products',
            message: 'Try a different search or category.',
          );
        }
        final cols = width >= 1100 ? 4 : (width >= 800 ? 3 : (width >= 520 ? 2 : 1));
        const gap = 16.0;
        final w = ((width - gap * (cols - 1)) / cols).floorToDouble();
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final p in items)
              SizedBox(
                width: w,
                child: _ProductCard(
                  product: p,
                  onEdit: () => onEdit(p),
                  onDelete: () => onDelete(p),
                ),
              ),
          ],
        );
    }
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ProductThumb(image: product.image),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name.isEmpty ? 'Unnamed product' : product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.amberLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.category,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _priceLabel(product.price),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.ink,
                          side: const BorderSide(color: _line),
                          minimumSize: const Size(0, 42),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      color: AppColors.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: AppColors.inkSoft),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.inkSoft),
              ),
              if (actionLabel != null) ...[
                const SizedBox(height: 16),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
