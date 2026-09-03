import 'package:flutter/material.dart';

import '../models/animal.dart';
import '../models/animal_query.dart';
import '../models/page_result.dart';
import '../repositories/animal_repository.dart';

enum AnimalLoadStatus {
  idle,
  loading,
  success,
  error,
}

class AnimalListNotifier
    extends ChangeNotifier {
  final AnimalRepository _repository;

  AnimalListNotifier(this._repository);

  AnimalQuery _query =
      const AnimalQuery();

  PageResult<Animal> _result =
      PageResult<Animal>.empty();

  AnimalLoadStatus _status =
      AnimalLoadStatus.idle;

  String? _error;

  final Set<int> _selected = {};

  AnimalQuery get query => _query;

  PageResult<Animal> get result =>
      _result;

  AnimalLoadStatus get status =>
      _status;

  String? get error => _error;

  Set<int> get selected =>
      Set.unmodifiable(_selected);

  bool get hasSelection =>
      _selected.isNotEmpty;

  Future<void> load() async {
    _status =
        AnimalLoadStatus.loading;

    _error = null;

    notifyListeners();

    try {
      _result =
          await _repository.find(_query);

      _status =
          AnimalLoadStatus.success;
    } catch (e) {
      _error =
          'Не удалось загрузить животных: $e';

      _status =
          AnimalLoadStatus.error;
    }

    notifyListeners();
  }

  Future<void> applyQuery(
    AnimalQuery query,
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

  Future<Animal?> findById(
    int id,
  ) {
    return _repository.findById(id);
  }
}