import 'package:flutter/material.dart';

import '../models/page_result.dart';
import '../models/product.dart';
import '../models/product_query.dart';
import '../repositories/product_repository.dart';

enum ProductLoadStatus {
  idle,
  loading,
  success,
  error,
}

class ProductListNotifier
    extends ChangeNotifier {
  final ProductRepository _repository;

  ProductListNotifier(this._repository);

  ProductQuery _query =
      const ProductQuery();

  PageResult<Product> _result =
      PageResult<Product>.empty();

  ProductLoadStatus _status =
      ProductLoadStatus.idle;

  String? _error;

  final Set<int> _selected = {};

  ProductQuery get query => _query;

  PageResult<Product> get result =>
      _result;

  ProductLoadStatus get status =>
      _status;

  String? get error => _error;

  Set<int> get selected =>
      Set.unmodifiable(_selected);

  bool get hasSelection =>
      _selected.isNotEmpty;

  Future<void> load() async {
    _status =
        ProductLoadStatus.loading;

    _error = null;

    notifyListeners();

    try {
      _result =
          await _repository.find(_query);

      _status =
          ProductLoadStatus.success;
    } catch (e) {
      _error =
          'Не удалось загрузить товары: $e';

      _status =
          ProductLoadStatus.error;
    }

    notifyListeners();
  }

  Future<void> applyQuery(
    ProductQuery query,
  ) async {
    _query = query;

    _selected.clear();

    await load();
  }

  void toggleSelection(int id) {
    if (_selected.contains(id)) {
      _selected.remove(id);
    } else {
      _selected.add(id);
    }

    notifyListeners();
  }

  Future<void> deleteSelected() async {
    await _repository.deleteMany(
      _selected.toList(),
    );

    _selected.clear();

    await load();
  }

  Future<void> softDelete(int id) async {
    await _repository.softDelete(id);

    _selected.remove(id);

    await load();
  }

  Future<void> hardDelete(int id) async {
    await _repository.hardDelete(id);

    _selected.remove(id);

    await load();
  }

  Future<void> restore(int id) async {
    await _repository.restore(id);

    await load();
  }

  Future<Product?> findById(
    int id,
  ) {
    return _repository.findById(id);
  }
}