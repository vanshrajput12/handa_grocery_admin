<<<<<<< HEAD
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
=======

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/order_service.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._service) : super(OrdersLoading()) {
    _subscription = _service.watchOrders().listen(
          (orders) => emit(OrdersLoaded(orders)),
      onError: (error) => emit(OrdersError(error.toString())),
    );
  }

  final OrderService _service;
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  Future<void> updateStatus(
      Map<String, dynamic> order,
      String status,
      ) async {
    try {
      await _service.updateOrderStatus(order, status);
    } catch (error) {
      emit(OrdersError(error.toString()));
    }
>>>>>>> origin/main
  }

  @override
  Future<void> close() {
<<<<<<< HEAD
    _sub?.cancel();
    return super.close();
  }
}
=======
    _subscription?.cancel();
    return super.close();
  }
}

abstract class OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  OrdersLoaded(this.orders);

  final List<Map<String, dynamic>> orders;
}

class OrdersError extends OrdersState {
  OrdersError(this.message);

  final String message;
}
>>>>>>> origin/main
