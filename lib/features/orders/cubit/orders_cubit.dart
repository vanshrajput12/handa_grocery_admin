import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/order_model.dart';
import '../../../services/order_service.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._service) : super(const OrdersState()) {
    start();
  }

  final OrderService _service;
  StreamSubscription<List<OrderModel>>? _sub;

  /// Starts (or restarts) the live stream. Also used by the Retry button.
  void start() {
    _sub?.cancel();
    emit(state.copyWith(
      loadStatus: OrdersLoadStatus.loading,
      clearError: true,
    ));
    _sub = _service.watchAllOrders().listen(
      (orders) => emit(state.copyWith(
        loadStatus: OrdersLoadStatus.loaded,
        orders: orders,
        clearError: true,
      )),
      onError: (Object e) => emit(state.copyWith(
        loadStatus: OrdersLoadStatus.error,
        errorMessage: _messageFor(e),
      )),
    );
  }

  void setQuery(String query) => emit(state.copyWith(query: query));

  void setStatusFilter(String? status) {
    emit(status == null
        ? state.copyWith(clearStatusFilter: true)
        : state.copyWith(statusFilter: status));
  }

  String _messageFor(Object e) {
    if (e is FirebaseException) {
      if (e.code == 'permission-denied') {
        return 'Permission denied. Publish the admin rule for orders in '
            'Firestore Rules, then sign out and sign in again.';
      }
      if (e.code == 'unavailable') {
        return 'Cannot reach Firestore. Check your internet connection.';
      }
    }
    return 'Could not load orders. Please try again.';
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
