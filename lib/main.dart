import 'package:basic_single_user_pos_flutter/providers/analytics_provider.dart';
import 'package:basic_single_user_pos_flutter/providers/cart_provider.dart';
import 'package:basic_single_user_pos_flutter/providers/modifier_provider.dart';
import 'package:basic_single_user_pos_flutter/providers/product_provider.dart';
import 'package:basic_single_user_pos_flutter/providers/category_provider.dart';
import 'package:basic_single_user_pos_flutter/providers/receipt_provider.dart';
import 'package:basic_single_user_pos_flutter/repositories/modifier_option_repository.dart';
import 'package:basic_single_user_pos_flutter/repositories/modifier_repository.dart';
import 'package:basic_single_user_pos_flutter/repositories/receipt_repository.dart';
import 'package:basic_single_user_pos_flutter/screens/analytics_page.dart';
import 'package:basic_single_user_pos_flutter/screens/checkout_cart.dart';
import 'package:basic_single_user_pos_flutter/screens/forms/category_form.dart';
import 'package:basic_single_user_pos_flutter/screens/forms/modifer_form.dart';
import 'package:basic_single_user_pos_flutter/screens/forms/products_form.dart';
import 'package:basic_single_user_pos_flutter/screens/items_page.dart';
import 'package:basic_single_user_pos_flutter/repositories/product_repository.dart';
import 'package:basic_single_user_pos_flutter/repositories/category_repository.dart';
import 'package:basic_single_user_pos_flutter/screens/post_checkout_page.dart';
import 'package:basic_single_user_pos_flutter/screens/receipts_page.dart';
import 'package:basic_single_user_pos_flutter/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:basic_single_user_pos_flutter/screens/sale_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final DatabaseService databaseService = DatabaseService();
  late final ProductRepository productRepository = ProductRepository(
    databaseService,
  );
  late final CategoryRepository categoryRepository = CategoryRepository(
    databaseService,
  );
  late final ModifierRepository modifierRepository = ModifierRepository(
    databaseService,
  );
  late final ModifierOptionRepository modifierOptionRepository =
      ModifierOptionRepository(databaseService);
  late final ReceiptRepository receiptRepository = ReceiptRepository(
    databaseService,
    productRepository,
  );

  @override
  Widget build(BuildContext context) {
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
        ChangeNotifierProvider(
          create: (context) => ReceiptProvider(receiptRepository),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              AnalyticsProvider(receiptRepository, categoryRepository),
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
          '/receiptsPage': (context) => ReceiptsPage(),
          '/checkOutCart': (context) => CheckOutCart(),
          '/postCheckOut': (context) => PostCheckoutPage(),
          '/analyticsPage': (context) => AnalyticsPage(),
        },
      ),
    );
  }
}
