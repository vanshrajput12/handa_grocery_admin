import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/status_chip.dart';
import '../../../models/order_model.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';

final _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

String _money(num v) {
  final digits = v % 1 == 0 ? 0 : 2;
  return NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: digits,
  ).format(v);
}

String _date(DateTime? d) => d == null ? '—' : _dateFormat.format(d);

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Filters(controller: _searchCtrl, state: state),
              const SizedBox(height: 12),
              if (state.loadStatus == OrdersLoadStatus.loaded)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Showing ${state.filtered.length} of ${state.orders.length} orders  •  live',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              Expanded(child: _Body(state: state)),
            ],
          ),
        );
      },
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.controller, required this.state});

  final TextEditingController controller;
  final OrdersState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OrdersCubit>();
    final statuses = state.availableStatuses;

    final search = TextField(
      controller: controller,
      onChanged: cubit.setQuery,
      decoration: InputDecoration(
        hintText: 'Search order ID, name, phone, city or email',
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
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: statuses.contains(state.statusFilter)
              ? state.statusFilter
              : null,
          hint: const Text('All statuses'),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('All statuses'),
            ),
            for (final s in statuses)
              DropdownMenuItem<String?>(value: s, child: Text(s)),
          ],
          onChanged: cubit.setStatusFilter,
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [search, const SizedBox(height: 8), dropdown],
          );
        }
        return Row(
          children: [
            Expanded(child: search),
            const SizedBox(width: 12),
            dropdown,
          ],
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final OrdersState state;

  @override
  Widget build(BuildContext context) {
    switch (state.loadStatus) {
      case OrdersLoadStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case OrdersLoadStatus.error:
        return _Message(
          icon: Icons.error_outline,
          title: 'Could not load orders',
          message: state.errorMessage ?? 'Something went wrong.',
          actionLabel: 'Retry',
          onAction: () => context.read<OrdersCubit>().start(),
        );
      case OrdersLoadStatus.loaded:
        if (state.orders.isEmpty) {
          return const _Message(
            icon: Icons.receipt_long_outlined,
            title: 'No orders yet',
            message: 'New customer orders will appear here automatically.',
          );
        }
        final rows = state.filtered;
        if (rows.isEmpty) {
          return const _Message(
            icon: Icons.search_off,
            title: 'No matching orders',
            message: 'Try a different search or status filter.',
          );
        }
        return LayoutBuilder(
          builder: (context, c) => c.maxWidth >= 800
              ? _OrdersTable(orders: rows, minWidth: c.maxWidth)
              : _OrdersCards(orders: rows),
        );
    }
  }
}

class _OrdersTable extends StatelessWidget {
  const _OrdersTable({required this.orders, required this.minWidth});

  final List<OrderModel> orders;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minWidth - 2),
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(Colors.grey.shade100),
              columns: const [
                DataColumn(label: Text('Order ID')),
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Phone')),
                DataColumn(label: Text('Items'), numeric: true),
                DataColumn(label: Text('Total'), numeric: true),
                DataColumn(label: Text('Payment')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Placed')),
              ],
              rows: [
                for (final o in orders)
                  DataRow(cells: [
                    DataCell(Text(
                      o.id.length > 8 ? '${o.id.substring(0, 8)}…' : o.id,
                      style: const TextStyle(fontFamily: 'monospace'),
                    )),
                    DataCell(Text(o.customerLabel)),
                    DataCell(Text(o.address.phone)),
                    DataCell(Text('${o.totalItems}')),
                    DataCell(Text(_money(o.totalAmount))),
                    DataCell(Text('${o.paymentMethod} (${o.paymentStatus})')),
                    DataCell(StatusChip(o.orderStatus)),
                    DataCell(Text(_date(o.createdAt))),
                  ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrdersCards extends StatelessWidget {
  const _OrdersCards({required this.orders});

  final List<OrderModel> orders;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final o = orders[i];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        o.customerLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      _money(o.totalAmount),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${o.address.phone}  •  ${o.address.city}'),
                const SizedBox(height: 4),
                Text(
                  '${o.totalItems} item(s)  •  ${o.paymentMethod} (${o.paymentStatus})',
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    StatusChip(o.orderStatus),
                    const Spacer(),
                    Text(
                      _date(o.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(120, 44)),
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
