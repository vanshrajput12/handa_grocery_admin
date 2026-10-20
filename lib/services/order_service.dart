import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart';

class OrderService {
  OrderService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Live stream of every customer's orders (users/{uid}/orders/{id}),
  /// newest first. Sorted on the client so no Firestore index is needed yet.
  Stream<List<OrderModel>> watchAllOrders() {
    return _firestore.collectionGroup('orders').snapshots().map((snap) {
      final orders = snap.docs.map(OrderModel.fromDoc).toList();
      final epoch = DateTime.fromMillisecondsSinceEpoch(0);
      orders.sort(
        (a, b) => (b.createdAt ?? epoch).compareTo(a.createdAt ?? epoch),
      );
      return orders;
    });
  }
}
