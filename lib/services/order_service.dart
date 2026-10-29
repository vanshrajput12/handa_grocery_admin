<<<<<<< HEAD
=======

>>>>>>> origin/main
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> watchOrders() {
    return _db.collectionGroup('orders').snapshots().map((snapshot) {
      final orders = snapshot.docs.map((doc) {
        return {
          ...doc.data(),
          'orderId': doc.id,
          'userId': doc.reference.parent.parent?.id ?? '',
          '_reference': doc.reference,
        };
      }).toList();

      orders.sort((a, b) {
        final aDate = a['createdAt'];
        final bDate = b['createdAt'];

<<<<<<< HEAD
        final aTime = aDate is Timestamp ? aDate.millisecondsSinceEpoch : 0;
        final bTime = bDate is Timestamp ? bDate.millisecondsSinceEpoch : 0;
=======
        final aTime = aDate is Timestamp
            ? aDate.millisecondsSinceEpoch
            : 0;
        final bTime = bDate is Timestamp
            ? bDate.millisecondsSinceEpoch
            : 0;
>>>>>>> origin/main

        return bTime.compareTo(aTime);
      });

      return orders;
    });
  }

  Future<void> updateOrderStatus(
<<<<<<< HEAD
    Map<String, dynamic> order,
    String status,
  ) async {
=======
      Map<String, dynamic> order,
      String status,
      ) async {
>>>>>>> origin/main
    final reference = order['_reference'];

    if (reference is! DocumentReference<Map<String, dynamic>>) {
      throw Exception('Invalid order reference.');
    }

    await reference.update({
      'orderStatus': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
