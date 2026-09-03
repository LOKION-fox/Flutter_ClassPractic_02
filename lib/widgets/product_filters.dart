import 'dart:async';

import 'package:flutter/material.dart';

import '../models/product_query.dart';

class ProductFilters extends StatefulWidget {
  final ProductQuery query;

  final List<String> categories;
  final List<String> manufacturers;

  final ValueChanged<ProductQuery> onChanged;

  const ProductFilters({
    super.key,
    required this.query,
    required this.categories,
    required this.manufacturers,
    required this.onChanged,
  });

  @override
  State<ProductFilters> createState() {
    return _ProductFiltersState();
  }
}

class _ProductFiltersState extends State<ProductFilters> {
  late final TextEditingController _searchController;
  late final TextEditingController _priceFromController;
  late final TextEditingController _priceToController;

  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController(
      text: widget.query.search,
    );

    _priceFromController = TextEditingController(
      text: widget.query.priceFrom?.toString() ?? '',
    );

    _priceToController = TextEditingController(
      text: widget.query.priceTo?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(ProductFilters oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_searchController.text != widget.query.search) {
      _searchController.text = widget.query.search;
    }

    final priceFrom =
        widget.query.priceFrom?.toString() ?? '';

    final priceTo =
        widget.query.priceTo?.toString() ?? '';

    if (_priceFromController.text != priceFrom) {
      _priceFromController.text = priceFrom;
    }

    if (_priceToController.text != priceTo) {
      _priceToController.text = priceTo;
    }
  }

  @override
  void dispose() {
    _searchTimer?.cancel();

    _searchController.dispose();
    _priceFromController.dispose();
    _priceToController.dispose();

    super.dispose();
  }

  void _searchChanged(String value) {
    _searchTimer?.cancel();

    _searchTimer = Timer(
      const Duration(milliseconds: 350),
      () {
        if (value != widget.query.search) {
          widget.onChanged(
            widget.query.copyWith(
              search: value,
            ),
          );
        }
      },
    );
  }

  double? _parsePrice(String value) {
    return double.tryParse(
      value.trim().replaceAll(',', '.'),
    );
  }

  void _applyPrices() {
    widget.onChanged(
      widget.query.copyWith(
        priceFrom: _parsePrice(
          _priceFromController.text,
        ),
        priceTo: _parsePrice(
          _priceToController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            TextField(
              controller: _searchController,

              decoration: const InputDecoration(
                labelText: 'Поиск по названию или артикулу',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),

              onChanged: _searchChanged,
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,

              children: [
                SizedBox(
                  width: 220,

                  child: DropdownButtonFormField<String>(
                    key: ValueKey(
                      'category-${widget.query.category}',
                    ),

                    initialValue: widget.query.category,

                    // Чтобы длинный текст не вылезал
                    // за границы списка.
                    isExpanded: true,

                    decoration: const InputDecoration(
                      labelText: 'Категория',
                      border: OutlineInputBorder(),
                    ),

                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text(
                          'Все категории',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      ...widget.categories.map(
                        (category) {
                          return DropdownMenuItem<String>(
                            value: category,

                            child: Text(
                              category,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ],

                    onChanged: (value) {
                      widget.onChanged(
                        widget.query.copyWith(
                          category: value,
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(
                  width: 240,

                  child: DropdownButtonFormField<String>(
                    key: ValueKey(
                      'manufacturer-${widget.query.manufacturer}',
                    ),

                    initialValue: widget.query.manufacturer,

                    // Главное исправление overflow.
                    isExpanded: true,

                    decoration: const InputDecoration(
                      labelText: 'Производитель',
                      border: OutlineInputBorder(),
                    ),

                    items: [
                      const DropdownMenuItem<String>(
                        value: null,

                        child: Text(
                          'Все производители',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      ...widget.manufacturers.map(
                        (manufacturer) {
                          return DropdownMenuItem<String>(
                            value: manufacturer,

                            child: Text(
                              manufacturer,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ],

                    onChanged: (value) {
                      widget.onChanged(
                        widget.query.copyWith(
                          manufacturer: value,
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(
                  width: 170,

                  child: TextField(
                    controller: _priceFromController,
                    keyboardType: TextInputType.number,

                    decoration: const InputDecoration(
                      labelText: 'Цена от, ₽',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                SizedBox(
                  width: 170,

                  child: TextField(
                    controller: _priceToController,
                    keyboardType: TextInputType.number,

                    decoration: const InputDecoration(
                      labelText: 'Цена до, ₽',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                SizedBox(
                  height: 56,

                  child: FilledButton(
                    onPressed: _applyPrices,

                    child: const Text(
                      'Применить',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,

              children: [
                Switch(
                  value: widget.query.includeDeleted,

                  onChanged: (value) {
                    widget.onChanged(
                      widget.query.copyWith(
                        includeDeleted: value,
                      ),
                    );
                  },
                ),

                const Text(
                  'Показывать удалённые',
                ),

                TextButton.icon(
                  onPressed: () {
                    widget.onChanged(
                      ProductQuery(
                        size: widget.query.size,
                      ),
                    );
                  },

                  icon: const Icon(
                    Icons.clear,
                  ),

                  label: const Text(
                    'Сбросить фильтры',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}