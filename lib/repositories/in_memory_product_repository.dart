import '../data/seed_data.dart';
import '../models/page_result.dart';
import '../models/product.dart';
import '../models/product_query.dart';
import 'product_repository.dart';

class InMemoryProductRepository
    implements ProductRepository {
  final List<Product> _products = [
    ...seedProducts,
  ];

  @override
  Future<PageResult<Product>> find(
    ProductQuery query,
  ) async {
    // Имитируем небольшую загрузку данных.
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

    var rows = _products.where((product) {
      return query.includeDeleted ||
          !product.isDeleted;
    }).toList();

    // Поиск по названию и артикулу.
    if (query.search.trim().isNotEmpty) {
      final search =
          query.search.trim().toLowerCase();

      rows = rows.where((product) {
        return product.name
                .toLowerCase()
                .contains(search) ||
            product.article
                .toLowerCase()
                .contains(search);
      }).toList();
    }

    if (query.category != null) {
      rows = rows.where((product) {
        return product.category ==
            query.category;
      }).toList();
    }

    if (query.manufacturer != null) {
      rows = rows.where((product) {
        return product.manufacturer ==
            query.manufacturer;
      }).toList();
    }

    if (query.priceFrom != null) {
      rows = rows.where((product) {
        return product.price >=
            query.priceFrom!;
      }).toList();
    }

    if (query.priceTo != null) {
      rows = rows.where((product) {
        return product.price <=
            query.priceTo!;
      }).toList();
    }

    // Сортировка.
    rows.sort((a, b) {
      int result;

      switch (query.sortField) {
        case 'price':
          result = a.price.compareTo(b.price);
          break;

        case 'stock':
          result = a.stock.compareTo(b.stock);
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
        ? <Product>[]
        : rows.sublist(from, to);

    return PageResult<Product>(
      items: items,
      page: query.page,
      size: query.size,
      total: total,
    );
  }

  @override
  Future<Product?> findById(int id) async {
    await Future.delayed(
      const Duration(milliseconds: 150),
    );

    for (final product in _products) {
      if (product.id == id) {
        return product;
      }
    }

    return null;
  }

  @override
  Future<void> softDelete(int id) async {
    final index = _products.indexWhere(
      (product) => product.id == id,
    );

    if (index == -1) {
      throw StateError(
        'Товар $id не найден',
      );
    }

    _products[index] =
        _products[index].copyWith(
      deletedAt: DateTime.now(),
    );
  }

  @override
  Future<void> hardDelete(int id) async {
    _products.removeWhere(
      (product) => product.id == id,
    );
  }

  @override
  Future<void> restore(int id) async {
    final index = _products.indexWhere(
      (product) => product.id == id,
    );

    if (index == -1) {
      throw StateError(
        'Товар $id не найден',
      );
    }

    _products[index] =
        _products[index].copyWith(
      clearDeletedAt: true,
    );
  }

  @override
  Future<int> deleteMany(
    List<int> ids,
  ) async {
    var count = 0;

    for (final id in ids) {
      final index = _products.indexWhere(
        (product) =>
            product.id == id &&
            !product.isDeleted,
      );

      if (index != -1) {
        _products[index] =
            _products[index].copyWith(
          deletedAt: DateTime.now(),
        );

        count++;
      }
    }

    return count;
  }
}