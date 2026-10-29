import 'package:equatable/equatable.dart';

import '../../../models/product_model.dart';

enum ProductsLoadStatus { loading, loaded, error }

class ProductsState extends Equatable {
  const ProductsState({
    this.loadStatus = ProductsLoadStatus.loading,
    this.products = const [],
    this.query = '',
    this.category,
    this.errorMessage,
    this.notice,
    this.noticeIsError = false,
    this.noticeSeq = 0,
  });

  final ProductsLoadStatus loadStatus;
  final List<ProductModel> products;
  final String query;

  /// null means all categories.
  final String? category;
  final String? errorMessage;

  /// One-off message shown as a snackbar. [noticeSeq] changes every time so
  /// the same message can be shown twice.
  final String? notice;
  final bool noticeIsError;
  final int noticeSeq;

  List<ProductModel> get filtered {
    final q = query.trim().toLowerCase();
    return products.where((p) {
      if (category != null && p.category != category) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();
  }

  ProductsState copyWith({
    ProductsLoadStatus? loadStatus,
    List<ProductModel>? products,
    String? query,
    String? category,
    bool clearCategory = false,
    String? errorMessage,
    bool clearError = false,
    String? notice,
    bool? noticeIsError,
    int? noticeSeq,
  }) {
    return ProductsState(
      loadStatus: loadStatus ?? this.loadStatus,
      products: products ?? this.products,
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      notice: notice ?? this.notice,
      noticeIsError: noticeIsError ?? this.noticeIsError,
      noticeSeq: noticeSeq ?? this.noticeSeq,
    );
  }

  @override
  List<Object?> get props => [
        loadStatus,
        products,
        query,
        category,
        errorMessage,
        notice,
        noticeIsError,
        noticeSeq,
      ];
}
