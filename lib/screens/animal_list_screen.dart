import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/seed_data.dart';
import '../models/animal.dart';
import '../models/animal_query.dart';
import '../state/animal_list_notifier.dart';
import '../widgets/animal_filters.dart';
import '../widgets/entity_table.dart';
import '../widgets/pagination.dart';

class AnimalListScreen extends StatefulWidget {
  final AnimalQuery initialQuery;

  const AnimalListScreen({
    super.key,
    required this.initialQuery,
  });

  @override
  State<AnimalListScreen> createState() {
    return _AnimalListScreenState();
  }
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncQuery();
    });
  }

  @override
  void didUpdateWidget(AnimalListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialQuery != widget.initialQuery) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncQuery();
      });
    }
  }

  void _syncQuery() {
    if (!mounted) {
      return;
    }

    final notifier =
        context.read<AnimalListNotifier>();

    if (notifier.query != widget.initialQuery) {
      notifier.applyQuery(
        widget.initialQuery,
      );
    } else if (notifier.status == AnimalLoadStatus.idle) {
      notifier.load();
    }
  }

  void _changeQuery(AnimalQuery query) {
    if (query == widget.initialQuery) {
      return;
    }

    context.go(
      query.toLocation('/animals'),
    );
  }

  Future<bool> _confirm(
    String title,
    String text,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              content: Text(text),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      false,
                    );
                  },
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      true,
                    );
                  },
                  child: const Text('Да'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _softDelete(
    Animal animal,
  ) async {
    final result = await _confirm(
      'Удаление',
      'Логически удалить "${animal.name}"?',
    );

    if (!result || !mounted) {
      return;
    }

    await context
        .read<AnimalListNotifier>()
        .softDelete(animal.id);
  }

  Future<void> _hardDelete(
    Animal animal,
  ) async {
    final result = await _confirm(
      'Физическое удаление',
      'Удалить "${animal.name}" навсегда?',
    );

    if (!result || !mounted) {
      return;
    }

    await context
        .read<AnimalListNotifier>()
        .hardDelete(animal.id);
  }

  Future<void> _deleteSelected() async {
    final notifier =
        context.read<AnimalListNotifier>();

    final result = await _confirm(
      'Удаление выбранных',
      'Удалить выбранные записи: ${notifier.selected.length}?',
    );

    if (!result || !mounted) {
      return;
    }

    await notifier.deleteSelected();
  }

  @override
  Widget build(BuildContext context) {
    final notifier =
        context.watch<AnimalListNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Животные'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            context.go('/');
          },
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AnimalFilters(
              query: widget.initialQuery,
              species: animalSpecies,
              sexes: animalSexes,
              onChanged: _changeQuery,
            ),

            const SizedBox(height: 16),

            if (notifier.hasSelection)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    crossAxisAlignment:
                        WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Выбрано: ${notifier.selected.length}',
                      ),
                      FilledButton.icon(
                        onPressed: _deleteSelected,
                        icon: const Icon(
                          Icons.delete,
                        ),
                        label: const Text(
                          'Удалить выбранные',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 8),

            _buildContent(notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    AnimalListNotifier notifier,
  ) {
    if (notifier.status == AnimalLoadStatus.idle ||
        notifier.status == AnimalLoadStatus.loading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(),
      );
    }

    if (notifier.status == AnimalLoadStatus.error) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                notifier.error ?? 'Неизвестная ошибка',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: notifier.load,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    if (notifier.result.items.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 60,
              ),
              SizedBox(height: 16),
              Text(
                'Животные не найдены',
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return _buildCards(
                notifier,
              );
            }

            return _buildTable(
              notifier,
            );
          },
        ),

        const SizedBox(height: 20),

        Pagination(
          page: notifier.result.page,
          totalPages: notifier.result.totalPages,
          total: notifier.result.total,
          size: notifier.result.size,
          onPageChanged: (page) {
            _changeQuery(
              notifier.query.copyWith(
                page: page,
              ),
            );
          },
          onSizeChanged: (size) {
            _changeQuery(
              notifier.query.copyWith(
                size: size,
                page: 1,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTable(
    AnimalListNotifier notifier,
  ) {
    return EntityTable<Animal>(
      items: notifier.result.items,
      idOf: (animal) => animal.id,
      selected: notifier.selected,
      onToggleSelect: notifier.toggleSelection,
      sortField: notifier.query.sortField,
      sortAscending: notifier.query.sortAscending,

      onSort: (field) {
        final ascending =
            field == notifier.query.sortField
                ? !notifier.query.sortAscending
                : true;

        _changeQuery(
          notifier.query.copyWith(
            sortField: field,
            sortAscending: ascending,
          ),
        );
      },

      columns: [
        TableColumnSpec<Animal>(
          label: 'Имя',
          sortField: 'name',
          build: (animal) => Text(
            animal.name,
          ),
        ),
        TableColumnSpec<Animal>(
          label: 'Вид',
          build: (animal) => Text(
            animal.species,
          ),
        ),
        TableColumnSpec<Animal>(
          label: 'Порода',
          build: (animal) => Text(
            animal.breed,
          ),
        ),
        TableColumnSpec<Animal>(
          label: 'Возраст',
          sortField: 'age',
          numeric: true,
          build: (animal) => Text(
            '${animal.ageMonths} мес.',
          ),
        ),
        TableColumnSpec<Animal>(
          label: 'Цена',
          sortField: 'price',
          numeric: true,
          build: (animal) => Text(
            '${animal.price.toStringAsFixed(0)} ₽',
          ),
        ),
        TableColumnSpec<Animal>(
          label: 'Статус',
          build: (animal) => Text(
            animal.isDeleted
                ? 'Удалён'
                : 'Активен',
          ),
        ),
      ],

      actions: (animal) {
        return [
          IconButton(
            tooltip: 'Открыть',
            onPressed: () {
              context.push(
                '/animals/${animal.id}',
              );
            },
            icon: const Icon(
              Icons.visibility,
            ),
          ),

          if (!animal.isDeleted)
            IconButton(
              tooltip: 'Удалить',
              onPressed: () {
                _softDelete(animal);
              },
              icon: const Icon(
                Icons.delete_outline,
              ),
            ),

          if (animal.isDeleted)
            IconButton(
              tooltip: 'Восстановить',
              onPressed: () {
                notifier.restore(
                  animal.id,
                );
              },
              icon: const Icon(
                Icons.restore,
              ),
            ),

          IconButton(
            tooltip: 'Удалить навсегда',
            onPressed: () {
              _hardDelete(animal);
            },
            icon: const Icon(
              Icons.delete_forever,
            ),
          ),
        ];
      },
    );
  }

  Widget _buildCards(
    AnimalListNotifier notifier,
  ) {
    return Column(
      children: notifier.result.items.map(
        (animal) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment:
                        WrapCrossAlignment.center,
                    children: [
                      Checkbox(
                        value: notifier.selected.contains(
                          animal.id,
                        ),
                        onChanged: (value) {
                          notifier.toggleSelection(
                            animal.id,
                          );
                        },
                      ),

                      Text(
                        animal.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Вид: ${animal.species}',
                  ),
                  Text(
                    'Порода: ${animal.breed}',
                  ),
                  Text(
                    'Возраст: ${animal.ageMonths} мес.',
                  ),
                  Text(
                    'Пол: ${animal.sex}',
                  ),
                  Text(
                    'Цена: ${animal.price.toStringAsFixed(0)} ₽',
                  ),

                  if (animal.isDeleted)
                    const Text(
                      'Статус: удалён',
                    ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          context.push(
                            '/animals/${animal.id}',
                          );
                        },
                        child: const Text(
                          'Открыть',
                        ),
                      ),

                      if (!animal.isDeleted)
                        OutlinedButton(
                          onPressed: () {
                            _softDelete(
                              animal,
                            );
                          },
                          child: const Text(
                            'Удалить',
                          ),
                        ),

                      if (animal.isDeleted)
                        OutlinedButton(
                          onPressed: () {
                            notifier.restore(
                              animal.id,
                            );
                          },
                          child: const Text(
                            'Восстановить',
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}