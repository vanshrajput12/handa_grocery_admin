import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class ProductService {
  ProductService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Live stream of one category (one Firestore collection).
  Stream<List<ProductModel>> watchCategory(String category) {
    return _db.collection(category).snapshots().map(
          (snap) => snap.docs
              .map((d) => ProductModel.fromDoc(category, d))
              .toList(),
        );
  }

  Future<void> addProduct({
    required String category,
    required Map<String, dynamic> data,
  }) {
    return _db.collection(category).add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Writes only the fields that changed, so any other field on the product
  /// (which the customer app may use) is left untouched.
  Future<void> updateProduct({
    required ProductModel product,
    required Map<String, dynamic> changes,
  }) {
    return _db.collection(product.category).doc(product.id).update({
      ...changes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteProduct(ProductModel product) {
    return _db.collection(product.category).doc(product.id).delete();
  }
}
