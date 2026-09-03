import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/animal.dart';
import '../state/animal_list_notifier.dart';

class AnimalDetailsScreen extends StatelessWidget {
  final int id;

  const AnimalDetailsScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final notifier =
        context.read<AnimalListNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Карточка животного',
        ),
      ),

      body: FutureBuilder<Animal?>(
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

          final animal = snapshot.data;

          if (animal == null) {
            return const Center(
              child: Text(
                'Животное не найдено',
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
                          animal.name,

                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium,
                        ),

                        const SizedBox(height: 20),

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
                          'Страна: ${animal.country}',
                        ),

                        Text(
                          'Цена: ${animal.price.toStringAsFixed(0)} ₽',
                        ),

                        const SizedBox(height: 16),

                        Text(
                          animal.description,
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'Статус: ${animal.isDeleted ? 'Удалён' : 'Активен'}',
                        ),

                        const SizedBox(height: 24),

                        FilledButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(
                                '/animals',
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