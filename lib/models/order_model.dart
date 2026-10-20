import 'package:cloud_firestore/cloud_firestore.dart';

num _num(dynamic v) => v is num ? v : (num.tryParse('${v ?? ''}') ?? 0);

String _str(dynamic v) => v == null ? '' : v.toString();

DateTime? _date(dynamic v) => v is Timestamp ? v.toDate() : null;

class OrderItem {
  const OrderItem({
    required this.productName,
    required this.price,
    required this.quantity,
    required this.totalPrice,
    this.image,
  });

  final String productName;
  final num price;
  final int quantity;
  final num totalPrice;
  final String? image;

  factory OrderItem.fromMap(Map<String, dynamic> m) => OrderItem(
        productName: _str(m['productName']),
        price: _num(m['price']),
        quantity: _num(m['quantity']).toInt(),
        totalPrice: _num(m['totalPrice']),
        image: m['image']?.toString(),
      );
}

class DeliveryAddress {
  const DeliveryAddress({
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
  });

  final String name;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String pincode;

  factory DeliveryAddress.fromMap(Map<String, dynamic>? m) {
    final map = m ?? const <String, dynamic>{};
    return DeliveryAddress(
      name: _str(map['name']),
      phone: _str(map['phone']),
      address: _str(map['address']),
      city: _str(map['city']),
      state: _str(map['state']),
      pincode: _str(map['pincode']),
    );
  }

  String get fullAddress => [address, city, state, pincode]
      .where((p) => p.trim().isNotEmpty)
      .join(', ');
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.items,
    required this.totalItems,
    required this.totalAmount,
    required this.address,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String userEmail;
  final List<OrderItem> items;
  final int totalItems;
  final num totalAmount;
  final DeliveryAddress address;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Name shown in lists: the delivery name, falling back to the email.
  String get customerLabel =>
      address.name.trim().isNotEmpty ? address.name : userEmail;

  factory OrderModel.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final rawItems = d['items'];
    final items = <OrderItem>[];
    if (rawItems is List) {
      for (final e in rawItems) {
        if (e is Map) {
          items.add(OrderItem.fromMap(Map<String, dynamic>.from(e)));
        }
      }
    }
    final rawAddress = d['deliveryAddress'];

    return OrderModel(
      id: _str(d['orderId']).isNotEmpty ? _str(d['orderId']) : doc.id,
      // Path is users/{userId}/orders/{orderId}, so the parent's parent is the user.
      userId: _str(d['userId']).isNotEmpty
          ? _str(d['userId'])
          : (doc.reference.parent.parent?.id ?? ''),
      userEmail: _str(d['userEmail']),
      items: items,
      totalItems: _num(d['totalItems']).toInt(),
      totalAmount: _num(d['totalAmount']),
      address: DeliveryAddress.fromMap(
        rawAddress is Map ? Map<String, dynamic>.from(rawAddress) : null,
      ),
      paymentMethod: _str(d['paymentMethod']),
      paymentStatus: _str(d['paymentStatus']),
      orderStatus: _str(d['orderStatus']),
      createdAt: _date(d['createdAt']),
      updatedAt: _date(d['updatedAt']),
    );
  }
}
