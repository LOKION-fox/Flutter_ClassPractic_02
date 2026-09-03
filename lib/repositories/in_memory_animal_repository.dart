import '../data/seed_data.dart';
import '../models/animal.dart';
import '../models/animal_query.dart';
import '../models/page_result.dart';
import 'animal_repository.dart';

class InMemoryAnimalRepository
    implements AnimalRepository {
  final List<Animal> _animals = [
    ...seedAnimals,
  ];

  @override
  Future<PageResult<Animal>> find(
    AnimalQuery query,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 250),
    );

    if (query.priceFrom != null &&
        query.priceTo != null &&
        query.priceFrom! > query.priceTo!) {
      throw ArgumentError(
        'Минимальная цена не может быть больше максимальной',
      );
    }

    var rows = _animals.where((animal) {
      return query.includeDeleted ||
          !animal.isDeleted;
    }).toList();

    if (query.search.trim().isNotEmpty) {
      final search =
          query.search.trim().toLowerCase();

      rows = rows.where((animal) {
        return animal.name
                .toLowerCase()
                .contains(search) ||
            animal.breed
                .toLowerCase()
                .contains(search) ||
            animal.country
                .toLowerCase()
                .contains(search);
      }).toList();
    }

    if (query.species != null) {
      rows = rows.where((animal) {
        return animal.species ==
            query.species;
      }).toList();
    }

    if (query.sex != null) {
      rows = rows.where((animal) {
        return animal.sex == query.sex;
      }).toList();
    }

    if (query.priceFrom != null) {
      rows = rows.where((animal) {
        return animal.price >=
            query.priceFrom!;
      }).toList();
    }

    if (query.priceTo != null) {
      rows = rows.where((animal) {
        return animal.price <=
            query.priceTo!;
      }).toList();
    }

    rows.sort((a, b) {
      int result;

      switch (query.sortField) {
        case 'price':
          result =
              a.price.compareTo(b.price);
          break;

        case 'age':
          result = a.ageMonths.compareTo(
            b.ageMonths,
          );
          break;

        default:
          result = a.name
              .toLowerCase()
              .compareTo(
                b.name.toLowerCase(),
              );
      }

      return query.sortAscending
          ? result
          : -result;
    });

    final total = rows.length;

    final from =
        (query.page - 1) * query.size;

    final to = from + query.size > total
        ? total
        : from + query.size;

    final items = from >= total
        ? <Animal>[]
        : rows.sublist(from, to);

    return PageResult<Animal>(
      items: items,
      page: query.page,
      size: query.size,
      total: total,
    );
  }

  @override
  Future<Animal?> findById(int id) async {
    await Future.delayed(
      const Duration(milliseconds: 150),
    );

    for (final animal in _animals) {
      if (animal.id == id) {
        return animal;
      }
    }

    return null;
  }

  @override
  Future<void> softDelete(int id) async {
    final index = _animals.indexWhere(
      (animal) => animal.id == id,
    );

    if (index == -1) {
      throw StateError(
        'Животное $id не найдено',
      );
    }

    _animals[index] =
        _animals[index].copyWith(
      deletedAt: DateTime.now(),
    );
  }

  @override
  Future<void> hardDelete(int id) async {
    _animals.removeWhere(
      (animal) => animal.id == id,
    );
  }

  @override
  Future<void> restore(int id) async {
    final index = _animals.indexWhere(
      (animal) => animal.id == id,
    );

    if (index == -1) {
      throw StateError(
        'Животное $id не найдено',
      );
    }

    _animals[index] =
        _animals[index].copyWith(
      clearDeletedAt: true,
    );
  }

  @override
  Future<int> deleteMany(
    List<int> ids,
  ) async {
    var count = 0;

    for (final id in ids) {
      final index = _animals.indexWhere(
        (animal) =>
            animal.id == id &&
            !animal.isDeleted,
      );

      if (index != -1) {
        _animals[index] =
            _animals[index].copyWith(
          deletedAt: DateTime.now(),
        );

        count++;
      }
    }

    return count;
  }
}