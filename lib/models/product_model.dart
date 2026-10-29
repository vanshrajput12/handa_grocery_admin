import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore collections that hold products. Each collection is one category
/// in the customer app. Adding a new category needs a change in the customer
/// app too, so it can load that collection.
const kProductCategories = ['Rice', 'Snacks'];

const _coreKeys = {'text', 'price', 'image'};
const _metaKeys = {'createdAt', 'updatedAt'};

class ProductModel {
  const ProductModel({
    required this.id,
    required this.category,
    required this.data,
  });

  final String id;
  final String category;

  /// The complete Firestore document.
  final Map<String, dynamic> data;

  String get name => (data['text'] ?? '').toString();
  dynamic get price => data['price'];
  String get priceText => price == null ? '' : price.toString();
  String get image => (data['image'] ?? '').toString();

  /// Other simple fields (text or numbers) that the form can edit.
  Map<String, dynamic> get extraFields => {
        for (final e in data.entries)
          if (!_coreKeys.contains(e.key) &&
              !_metaKeys.contains(e.key) &&
              (e.value is String || e.value is num))
            e.key: e.value,
      };

  factory ProductModel.fromDoc(
    String category,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return ProductModel(id: doc.id, category: category, data: doc.data());
  }
}
