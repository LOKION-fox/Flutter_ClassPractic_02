import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Зоомагазин'),
      ),

      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(24),

          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 700,
            ),

            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                const Icon(
                  Icons.pets,
                  size: 80,
                ),

                const SizedBox(height: 16),

                Text(
                  'Каталог зоомагазина',

                  style:
                      Theme.of(context)
                          .textTheme
                          .headlineMedium,
                ),

                const SizedBox(height: 32),

                Wrap(
                  spacing: 16,
                  runSpacing: 16,

                  children: [
                    SizedBox(
                      width: 250,

                      child:
                          FilledButton.icon(
                        onPressed: () {
                          context.go(
                            '/products',
                          );
                        },

                        icon: const Icon(
                          Icons.shopping_bag,
                        ),

                        label:
                            const Text(
                          'Товары',
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 250,

                      child:
                          FilledButton.icon(
                        onPressed: () {
                          context.go(
                            '/animals',
                          );
                        },

                        icon: const Icon(
                          Icons.pets,
                        ),

                        label:
                            const Text(
                          'Животные',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}