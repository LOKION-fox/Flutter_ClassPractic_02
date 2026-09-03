import 'dart:async';

import 'package:flutter/material.dart';

import '../models/animal_query.dart';

class AnimalFilters extends StatefulWidget {
  final AnimalQuery query;

  final List<String> species;
  final List<String> sexes;

  final ValueChanged<AnimalQuery> onChanged;

  const AnimalFilters({
    super.key,
    required this.query,
    required this.species,
    required this.sexes,
    required this.onChanged,
  });

  @override
  State<AnimalFilters> createState() {
    return _AnimalFiltersState();
  }
}

class _AnimalFiltersState extends State<AnimalFilters> {
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
  void didUpdateWidget(AnimalFilters oldWidget) {
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
                labelText: 'Поиск по имени, породе или стране',
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
                      'species-${widget.query.species}',
                    ),

                    initialValue: widget.query.species,

                    isExpanded: true,

                    decoration: const InputDecoration(
                      labelText: 'Вид животного',
                      border: OutlineInputBorder(),
                    ),

                    items: [
                      const DropdownMenuItem<String>(
                        value: null,

                        child: Text(
                          'Все виды',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      ...widget.species.map(
                        (species) {
                          return DropdownMenuItem<String>(
                            value: species,

                            child: Text(
                              species,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ],

                    onChanged: (value) {
                      widget.onChanged(
                        widget.query.copyWith(
                          species: value,
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(
                  width: 170,

                  child: DropdownButtonFormField<String>(
                    key: ValueKey(
                      'sex-${widget.query.sex}',
                    ),

                    initialValue: widget.query.sex,

                    isExpanded: true,

                    decoration: const InputDecoration(
                      labelText: 'Пол',
                      border: OutlineInputBorder(),
                    ),

                    items: [
                      const DropdownMenuItem<String>(
                        value: null,

                        child: Text(
                          'Любой',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      ...widget.sexes.map(
                        (sex) {
                          return DropdownMenuItem<String>(
                            value: sex,

                            child: Text(
                              sex,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ],

                    onChanged: (value) {
                      widget.onChanged(
                        widget.query.copyWith(
                          sex: value,
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
                  'Показывать удалённых',
                ),

                TextButton.icon(
                  onPressed: () {
                    widget.onChanged(
                      AnimalQuery(
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