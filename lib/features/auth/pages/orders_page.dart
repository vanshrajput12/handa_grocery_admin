
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/orders_cubit.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  static const statuses = [
    'Pending',
    'Confirmed',
    'Preparing',
    'Out for Delivery',
    'Delivered',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrdersError) {
            return Center(
              child: Text(
                'Unable to load orders:\n${state.message}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (state is! OrdersLoaded) {
            return const SizedBox.shrink();
          }

          if (state.orders.isEmpty) {
            return const Center(
              child: Text('No orders found yet.'),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Orders',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('${state.orders.length} total orders'),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: state.orders.length,
                  separatorBuilder: (_, _) =>
                  const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = state.orders[index];
                    final orderId = order['orderId'] ?? '';
                    final customer = order['customerName'] ??
                        order['name'] ??
                        order['userId'] ??
                        'Customer';
                    final total = order['totalAmount'] ??
                        order['total'] ??
                        order['grandTotal'] ??
                        0;
                    final currentStatus =
                        order['status']?.toString() ?? 'Pending';

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #$orderId',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text('Customer: $customer'),
                            Text('Total: ₹$total'),
                            Text(
                              'Address: ${order['deliveryAddress'] ?? order['address'] ?? 'Not available'}',
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text('Status: '),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: statuses.contains(currentStatus)
                                        ? currentStatus
                                        : null,
                                    hint: Text(currentStatus),
                                    items: statuses.map((status) {
                                      return DropdownMenuItem(
                                        value: status,
                                        child: Text(status),
                                      );
                                    }).toList(),
                                    onChanged: (status) {
                                      if (status != null) {
                                        context
                                            .read<OrdersCubit>()
                                            .updateStatus(order, status);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
