import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/product_model.dart';
import '../../../services/product_service.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._service) : super(const ProductsState()) {
    start();
  }

  final ProductService _service;
  final Map<String, List<ProductModel>> _byCategory = {};
  final List<StreamSubscription<List<ProductModel>>> _subs = [];

  /// Starts (or restarts) the live streams. Also used by the Retry button.
  void start() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    _byCategory.clear();
    emit(const ProductsState());

    for (final category in kProductCategories) {
      _subs.add(
        _service.watchCategory(category).listen(
          (list) {
            _byCategory[category] = list;
            if (_byCategory.length < kProductCategories.length) return;
            final merged = <ProductModel>[
              for (final c in kProductCategories) ...?_byCategory[c],
            ]..sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
              );
            emit(state.copyWith(
              loadStatus: ProductsLoadStatus.loaded,
              products: merged,
              clearError: true,
            ));
          },
          onError: (Object e) => emit(state.copyWith(
            loadStatus: ProductsLoadStatus.error,
            errorMessage: _loadMessage(e),
          )),
        ),
      );
    }
  }

  void setQuery(String query) => emit(state.copyWith(query: query));

  void setCategory(String? category) {
    emit(category == null
        ? state.copyWith(clearCategory: true)
        : state.copyWith(category: category));
  }

  /// Adds a product, or updates [existing] with the fields in [data].
  /// Returns true when it worked.
  Future<bool> save({
    ProductModel? existing,
    required String category,
    required Map<String, dynamic> data,
  }) async {
    try {
      if (existing == null) {
        await _service.addProduct(category: category, data: data);
        _notice('Product added. It is now live in the customer app.');
      } else {
        await _service.updateProduct(product: existing, changes: data);
        _notice('Product updated.');
      }
      return true;
    } catch (e) {
      _notice(_actionMessage(e), isError: true);
      return false;
    }
  }

  Future<void> delete(ProductModel product) async {
    try {
      await _service.deleteProduct(product);
      _notice('"${product.name}" was deleted.');
    } catch (e) {
      _notice(_actionMessage(e), isError: true);
    }
  }

  void _notice(String message, {bool isError = false}) {
    emit(state.copyWith(
      notice: message,
      noticeIsError: isError,
      noticeSeq: state.noticeSeq + 1,
    ));
  }

  String _loadMessage(Object e) {
    if (e is FirebaseException) {
      if (e.code == 'permission-denied') {
        return 'Permission denied. Sign out and sign in again, and check the '
            'Firestore rules for the Rice and Snacks collections.';
      }
      if (e.code == 'unavailable') {
        return 'Cannot reach Firestore. Check your internet connection.';
      }
    }
    return 'Could not load products. Please try again.';
  }

  String _actionMessage(Object e) {
    if (e is FirebaseException && e.code == 'permission-denied') {
      return 'You are not allowed to change products. Sign out and sign in '
          'again, then retry.';
    }
    return 'Could not save the change. Please try again.';
  }

  @override
  Future<void> close() {
    for (final s in _subs) {
      s.cancel();
    }
    return super.close();
  }
}
