import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'repositories/animal_repository.dart';
import 'repositories/in_memory_animal_repository.dart';
import 'repositories/in_memory_product_repository.dart';
import 'repositories/product_repository.dart';
import 'router.dart';
import 'state/animal_list_notifier.dart';
import 'state/product_list_notifier.dart';

void main() {
  usePathUrlStrategy();

  runApp(
    MultiProvider(
      providers: [
        Provider<ProductRepository>(
          create: (_) =>
              InMemoryProductRepository(),
        ),

        Provider<AnimalRepository>(
          create: (_) =>
              InMemoryAnimalRepository(),
        ),

        ChangeNotifierProvider<
            ProductListNotifier>(
          create: (context) =>
              ProductListNotifier(
            context.read<
                ProductRepository>(),
          ),
        ),

        ChangeNotifierProvider<
            AnimalListNotifier>(
          create: (context) =>
              AnimalListNotifier(
            context.read<
                AnimalRepository>(),
          ),
        ),
      ],

      child: const PetShopApp(),
    ),
  );
}

class PetShopApp
    extends StatelessWidget {
  const PetShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Зоомагазин',

      debugShowCheckedModeBanner:
          false,

      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),

        useMaterial3: true,
      ),

      routerConfig: appRouter,
    );
  }
}