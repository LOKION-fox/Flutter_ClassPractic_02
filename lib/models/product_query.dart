class ProductQuery {
  final String search;

  final String? category;
  final String? manufacturer;

  final double? priceFrom;
  final double? priceTo;

  final String sortField;
  final bool sortAscending;

  final int page;
  final int size;

  final bool includeDeleted;

  const ProductQuery({
    this.search = '',
    this.category,
    this.manufacturer,
    this.priceFrom,
    this.priceTo,
    this.sortField = 'name',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  ProductQuery copyWith({
    String? search,
    Object? category = _unset,
    Object? manufacturer = _unset,
    Object? priceFrom = _unset,
    Object? priceTo = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return ProductQuery(
      search: search ?? this.search,

      category: category == _unset
          ? this.category
          : category as String?,

      manufacturer: manufacturer == _unset
          ? this.manufacturer
          : manufacturer as String?,

      priceFrom: priceFrom == _unset
          ? this.priceFrom
          : priceFrom as double?,

      priceTo: priceTo == _unset
          ? this.priceTo
          : priceTo as double?,

      sortField: sortField ?? this.sortField,

      sortAscending:
          sortAscending ?? this.sortAscending,

      // При изменении фильтров возвращаемся
      // на первую страницу.
      page: page ?? 1,

      size: size ?? this.size,

      includeDeleted:
          includeDeleted ?? this.includeDeleted,
    );
  }

  Map<String, String> toQueryParameters() {
    final params = <String, String>{};

    if (search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }

    if (category != null) {
      params['category'] = category!;
    }

    if (manufacturer != null) {
      params['manufacturer'] = manufacturer!;
    }

    if (priceFrom != null) {
      params['priceFrom'] =
          priceFrom!.toString();
    }

    if (priceTo != null) {
      params['priceTo'] =
          priceTo!.toString();
    }

    params['sort'] =
        '$sortField,${sortAscending ? 'asc' : 'desc'}';

    params['page'] = page.toString();
    params['size'] = size.toString();

    if (includeDeleted) {
      params['deleted'] = '1';
    }

    return params;
  }

  String toLocation(String path) {
    return Uri(
      path: path,
      queryParameters: toQueryParameters(),
    ).toString();
  }

  factory ProductQuery.fromUri(Uri uri) {
    final q = uri.queryParameters;

    final sortParts =
        (q['sort'] ?? 'name,asc').split(',');

    String sortField = sortParts.first;

    const allowedSortFields = {
      'name',
      'price',
      'stock',
    };

    if (!allowedSortFields.contains(sortField)) {
      sortField = 'name';
    }

    final sortAscending =
        sortParts.length < 2 ||
        sortParts[1] != 'desc';

    final page =
        int.tryParse(q['page'] ?? '') ?? 1;

    final rawSize =
        int.tryParse(q['size'] ?? '') ?? 10;

    final size = [10, 25, 50].contains(rawSize)
        ? rawSize
        : 10;

    return ProductQuery(
      search: q['search'] ?? '',
      category: q['category'],
      manufacturer: q['manufacturer'],

      priceFrom:
          double.tryParse(q['priceFrom'] ?? ''),

      priceTo:
          double.tryParse(q['priceTo'] ?? ''),

      sortField: sortField,
      sortAscending: sortAscending,

      page: page < 1 ? 1 : page,
      size: size,

      includeDeleted:
          q['deleted'] == '1',
    );
  }

  static const _unset = Object();

  @override
  bool operator ==(Object other) {
    return other is ProductQuery &&
        other.search == search &&
        other.category == category &&
        other.manufacturer == manufacturer &&
        other.priceFrom == priceFrom &&
        other.priceTo == priceTo &&
        other.sortField == sortField &&
        other.sortAscending == sortAscending &&
        other.page == page &&
        other.size == size &&
        other.includeDeleted == includeDeleted;
  }

  @override
  int get hashCode => Object.hash(
        search,
        category,
        manufacturer,
        priceFrom,
        priceTo,
        sortField,
        sortAscending,
        page,
        size,
        includeDeleted,
      );
}