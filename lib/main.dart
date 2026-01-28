import 'package:basic_single_user_pos_flutter/providers/cart_provider.dart';
import 'package:basic_single_user_pos_flutter/providers/modifier_provider.dart';
import 'package:basic_single_user_pos_flutter/providers/product_provider.dart';
import 'package:basic_single_user_pos_flutter/providers/category_provider.dart';
import 'package:basic_single_user_pos_flutter/repositories/modifier_option_repository.dart';
import 'package:basic_single_user_pos_flutter/repositories/modifier_repository.dart';
import 'package:basic_single_user_pos_flutter/screens/forms/category_form.dart';
import 'package:basic_single_user_pos_flutter/screens/forms/modifer_form.dart';
import 'package:basic_single_user_pos_flutter/screens/forms/products_form.dart';
import 'package:basic_single_user_pos_flutter/screens/items_page.dart';
import 'package:basic_single_user_pos_flutter/repositories/product_repository.dart';
import 'package:basic_single_user_pos_flutter/repositories/category_repository.dart';
import 'package:basic_single_user_pos_flutter/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:basic_single_user_pos_flutter/screens/sale_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final DatabaseService databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final productRepository = ProductRepository(databaseService);
    final categoryRepository = CategoryRepository(databaseService);
    final modifierRepository = ModifierRepository(databaseService);
    final modifierOptionRepository = ModifierOptionRepository(databaseService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) =>
              ProductProvider(productRepository)..loadProducts(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              CategoryProvider(categoryRepository)..loadCategories(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ModifierProvider(modifierRepository, modifierOptionRepository)
                ..loadAll(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              CartProvider(modifierProvider: context.read<ModifierProvider>()),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.tealAccent),
          useMaterial3: true,
        ),
        initialRoute: '/sale',
        routes: {
          '/addCategory': (context) => CategoryFormPage(),
          '/addProduct': (context) => ProductsFormPage(),
          '/addModifier': (context) => ModifierFormPage(),
          '/sale': (context) => SalePage(),
          '/items': (context) => ItemsPage(),
        },
      ),
    );
  }
}
