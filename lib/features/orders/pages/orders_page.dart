import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/orders_cubit.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  static const statuses = [
    'Order Placed',
    'Confirmed',
    'Preparing',
    'Ready for Pickup',
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
            return const Center(child: Text('No orders found yet.'));
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
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = state.orders[index];

                    final rawAddress = order['deliveryAddress'];
                    final addr = rawAddress is Map
                        ? Map<String, dynamic>.from(rawAddress)
                        : <String, dynamic>{};

                    final customer =
                        (addr['name'] ?? order['userEmail'] ?? 'Customer')
                            .toString();
                    final phone = (addr['phone'] ?? '').toString();
                    final fullAddress = [
                      addr['address'],
                      addr['city'],
                      addr['state'],
                      addr['pincode'],
                    ]
                        .where((p) => p != null && p.toString().trim().isNotEmpty)
                        .join(', ');

                    final rawItems = order['items'];
                    final itemsText = rawItems is List
                        ? rawItems
                            .whereType<Map>()
                            .map((i) => '${i['productName']} × ${i['quantity']}')
                            .join(', ')
                        : '';

                    final orderId = (order['orderId'] ?? '').toString();
                    final total = order['totalAmount'] ?? 0;
                    final payment =
                        '${order['paymentMethod'] ?? ''} (${order['paymentStatus'] ?? ''})';
                    final currentStatus =
                        (order['orderStatus'] ?? 'Order Placed').toString();

                    final options = statuses.contains(currentStatus)
                        ? statuses
                        : [currentStatus, ...statuses];

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
                            Text('Customer: $customer  •  $phone'),
                            if (itemsText.isNotEmpty) Text('Items: $itemsText'),
                            Text('Total: ₹$total  •  $payment'),
                            Text(
                              'Address: ${fullAddress.isEmpty ? 'Not available' : fullAddress}',
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text('Status: '),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: currentStatus,
                                    items: options.map((status) {
                                      return DropdownMenuItem(
                                        value: status,
                                        child: Text(status),
                                      );
                                    }).toList(),
                                    onChanged: (status) {
                                      if (status != null &&
                                          status != currentStatus) {
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
