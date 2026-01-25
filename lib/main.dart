import 'package:basic_single_user_pos_flutter/providers/product_provider.dart';
import 'package:basic_single_user_pos_flutter/screens/add_products_page.dart';
import 'package:basic_single_user_pos_flutter/screens/items_page.dart';
import 'package:basic_single_user_pos_flutter/repositories/product_repository.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ProductProvider(productRepository),
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
          '/addProduct': (context) => AddProductsPage(),
          '/sale': (context) => SalePage(),
          '/items': (context) => ItemsPage(),
        },
      ),
    );
  }
}
