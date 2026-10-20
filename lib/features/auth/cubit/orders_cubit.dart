
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
  }

  @override
  Future<void> close() {
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
