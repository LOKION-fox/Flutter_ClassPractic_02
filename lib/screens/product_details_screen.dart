import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../state/product_list_notifier.dart';

class ProductDetailsScreen extends StatelessWidget {
  final int id;

  const ProductDetailsScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final notifier =
        context.read<ProductListNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Карточка товара',
        ),
      ),

      body: FutureBuilder<Product?>(
        future: notifier.findById(id),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Ошибка: ${snapshot.error}',
              ),
            );
          }

          final product = snapshot.data;

          if (product == null) {
            return const Center(
              child: Text(
                'Товар не найден',
              ),
            );
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ),

                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          product.name,

                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium,
                        ),

                        const SizedBox(height: 20),

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

                        const SizedBox(height: 16),

                        Text(
                          product.description,
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'Статус: ${product.isDeleted ? 'Удалён' : 'Активен'}',
                        ),

                        const SizedBox(height: 24),

                        FilledButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(
                                '/products',
                              );
                            }
                          },

                          child: const Text(
                            'Вернуться к списку',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}