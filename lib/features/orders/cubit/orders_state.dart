import 'package:equatable/equatable.dart';

import '../../../models/order_model.dart';

enum OrdersLoadStatus { loading, loaded, error }

class OrdersState extends Equatable {
  const OrdersState({
    this.loadStatus = OrdersLoadStatus.loading,
    this.orders = const [],
    this.query = '',
    this.statusFilter,
    this.errorMessage,
  });

  final OrdersLoadStatus loadStatus;
  final List<OrderModel> orders;
  final String query;

  /// null means "all statuses".
  final String? statusFilter;
  final String? errorMessage;

  /// Distinct statuses present in the data, for the filter dropdown.
  List<String> get availableStatuses {
    final set = orders.map((o) => o.orderStatus).where((s) => s.isNotEmpty);
    return set.toSet().toList()..sort();
  }

  List<OrderModel> get filtered {
    final q = query.trim().toLowerCase();
    return orders.where((o) {
      if (statusFilter != null && o.orderStatus != statusFilter) return false;
      if (q.isEmpty) return true;
      return o.id.toLowerCase().contains(q) ||
          o.address.name.toLowerCase().contains(q) ||
          o.address.phone.toLowerCase().contains(q) ||
          o.address.city.toLowerCase().contains(q) ||
          o.userEmail.toLowerCase().contains(q);
    }).toList();
  }

  OrdersState copyWith({
    OrdersLoadStatus? loadStatus,
    List<OrderModel>? orders,
    String? query,
    String? statusFilter,
    bool clearStatusFilter = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OrdersState(
      loadStatus: loadStatus ?? this.loadStatus,
      orders: orders ?? this.orders,
      query: query ?? this.query,
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [loadStatus, orders, query, statusFilter, errorMessage];
}
