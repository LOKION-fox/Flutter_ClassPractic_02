import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/seed_data.dart';
import '../models/product.dart';
import '../models/product_query.dart';
import '../state/product_list_notifier.dart';
import '../widgets/entity_table.dart';
import '../widgets/pagination.dart';
import '../widgets/product_filters.dart';

class ProductListScreen extends StatefulWidget {
  final ProductQuery initialQuery;

  const ProductListScreen({
    super.key,
    required this.initialQuery,
  });

  @override
  State<ProductListScreen> createState() {
    return _ProductListScreenState();
  }
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncQuery();
    });
  }

  @override
  void didUpdateWidget(ProductListScreen oldWidget) {
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
        context.read<ProductListNotifier>();

    if (notifier.query != widget.initialQuery) {
      notifier.applyQuery(
        widget.initialQuery,
      );
    } else if (notifier.status == ProductLoadStatus.idle) {
      notifier.load();
    }
  }

  void _changeQuery(ProductQuery query) {
    if (query == widget.initialQuery) {
      return;
    }

    // Изменяем состояние текущего списка через URL.
    // Благодаря этому Back/Forward браузера
    // восстанавливают предыдущие параметры.
    context.go(
      query.toLocation('/products'),
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

  Future<void> _softDelete(Product product) async {
    final result = await _confirm(
      'Удаление товара',
      'Логически удалить "${product.name}"?',
    );

    if (!result || !mounted) {
      return;
    }

    await context
        .read<ProductListNotifier>()
        .softDelete(product.id);
  }

  Future<void> _hardDelete(Product product) async {
    final result = await _confirm(
      'Физическое удаление',
      'Удалить "${product.name}" навсегда?',
    );

    if (!result || !mounted) {
      return;
    }

    await context
        .read<ProductListNotifier>()
        .hardDelete(product.id);
  }

  Future<void> _deleteSelected() async {
    final notifier =
        context.read<ProductListNotifier>();

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
        context.watch<ProductListNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Товары'),
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
            ProductFilters(
              query: widget.initialQuery,
              categories: productCategories,
              manufacturers: productManufacturers,
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
    ProductListNotifier notifier,
  ) {
    if (notifier.status == ProductLoadStatus.idle ||
        notifier.status == ProductLoadStatus.loading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(),
      );
    }

    if (notifier.status == ProductLoadStatus.error) {
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
                'По заданным условиям ничего не найдено',
                textAlign: TextAlign.center,
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
    ProductListNotifier notifier,
  ) {
    return EntityTable<Product>(
      items: notifier.result.items,
      idOf: (product) => product.id,
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
        TableColumnSpec<Product>(
          label: 'Название',
          sortField: 'name',
          build: (product) => Text(
            product.name,
          ),
        ),
        TableColumnSpec<Product>(
          label: 'Артикул',
          build: (product) => Text(
            product.article,
          ),
        ),
        TableColumnSpec<Product>(
          label: 'Категория',
          build: (product) => Text(
            product.category,
          ),
        ),
        TableColumnSpec<Product>(
          label: 'Цена',
          sortField: 'price',
          numeric: true,
          build: (product) => Text(
            '${product.price.toStringAsFixed(0)} ₽',
          ),
        ),
        TableColumnSpec<Product>(
          label: 'Остаток',
          sortField: 'stock',
          numeric: true,
          build: (product) => Text(
            '${product.stock}',
          ),
        ),
        TableColumnSpec<Product>(
          label: 'Статус',
          build: (product) => Text(
            product.isDeleted
                ? 'Удалён'
                : 'Активен',
          ),
        ),
      ],

      actions: (product) {
        return [
          IconButton(
            tooltip: 'Открыть',
            onPressed: () {
              context.push(
                '/products/${product.id}',
              );
            },
            icon: const Icon(
              Icons.visibility,
            ),
          ),

          if (!product.isDeleted)
            IconButton(
              tooltip: 'Логическое удаление',
              onPressed: () {
                _softDelete(product);
              },
              icon: const Icon(
                Icons.delete_outline,
              ),
            ),

          if (product.isDeleted)
            IconButton(
              tooltip: 'Восстановить',
              onPressed: () {
                notifier.restore(
                  product.id,
                );
              },
              icon: const Icon(
                Icons.restore,
              ),
            ),

          IconButton(
            tooltip: 'Удалить навсегда',
            onPressed: () {
              _hardDelete(product);
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
    ProductListNotifier notifier,
  ) {
    return Column(
      children: notifier.result.items.map(
        (product) {
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
                          product.id,
                        ),
                        onChanged: (value) {
                          notifier.toggleSelection(
                            product.id,
                          );
                        },
                      ),
                      Text(
                        product.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Артикул: ${product.article}',
                  ),
                  Text(
                    'Категория: ${product.category}',
                  ),
                  Text(
                    'Производитель: ${product.manufacturer}',
                  ),
                  Text(
                    'Цена: ${product.price.toStringAsFixed(0)} ₽',
                  ),
                  Text(
                    'На складе: ${product.stock}',
                  ),

                  if (product.isDeleted)
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
                            '/products/${product.id}',
                          );
                        },
                        child: const Text(
                          'Открыть',
                        ),
                      ),

                      if (!product.isDeleted)
                        OutlinedButton(
                          onPressed: () {
                            _softDelete(
                              product,
                            );
                          },
                          child: const Text(
                            'Удалить',
                          ),
                        ),

                      if (product.isDeleted)
                        OutlinedButton(
                          onPressed: () {
                            notifier.restore(
                              product.id,
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