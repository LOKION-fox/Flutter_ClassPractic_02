import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models/animal_query.dart';
import 'models/product_query.dart';
import 'screens/animal_details_screen.dart';
import 'screens/animal_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/product_list_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',

  routes: [
    GoRoute(
      path: '/',

      builder: (context, state) {
        return const HomeScreen();
      },
    ),

    GoRoute(
      path: '/products',

      builder: (context, state) {
        return ProductListScreen(
          initialQuery:
              ProductQuery.fromUri(
            state.uri,
          ),
        );
      },
    ),

    GoRoute(
      path: '/products/:id',

      builder: (context, state) {
        final id = int.tryParse(
              state.pathParameters[
                      'id'] ??
                  '',
            ) ??
            -1;

        return ProductDetailsScreen(
          id: id,
        );
      },
    ),

    GoRoute(
      path: '/animals',

      builder: (context, state) {
        return AnimalListScreen(
          initialQuery:
              AnimalQuery.fromUri(
            state.uri,
          ),
        );
      },
    ),

    GoRoute(
      path: '/animals/:id',

      builder: (context, state) {
        final id = int.tryParse(
              state.pathParameters[
                      'id'] ??
                  '',
            ) ??
            -1;

        return AnimalDetailsScreen(
          id: id,
        );
      },
    ),
  ],

  errorBuilder: (context, state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ошибка 404',
        ),
      ),

      body: Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            const Text(
              '404',
              style: TextStyle(
                fontSize: 60,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            const Text(
              'Страница не найдена',
            ),

            const SizedBox(
              height: 20,
            ),

            FilledButton(
              onPressed: () {
                context.go('/');
              },

              child: const Text(
                'На главную',
              ),
            ),
          ],
        ),
      ),
    );
  },
);