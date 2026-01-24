import 'package:basic_single_user_pos_flutter/models/product.dart';
import 'package:basic_single_user_pos_flutter/repositories/product_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:basic_single_user_pos_flutter/services/database_service.dart';
import 'package:basic_single_user_pos_flutter/models/category.dart';
import 'package:basic_single_user_pos_flutter/repositories/category_repository.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  late DatabaseService dbService;
  late CategoryRepository categoryRepo;
  late ProductRepository productRepo;

  setUp(() async {
    dbService = DatabaseService(inMemory: true);
    categoryRepo = CategoryRepository(dbService);
    productRepo = ProductRepository(dbService);
  });

  tearDown(() async {
    final db = await dbService.database;
    await db.close(); // reset singleton
  });

  test('Insert and retrieve category', () async {
    final category = Category(name: 'Beverages');
    final categoryId = await categoryRepo.insert(category);

    await productRepo.insert(
      Product(name: 'Cheese Stick', price: 40, color: 'Blue'),
    );
    final productId = await productRepo.insert(
      Product(
        name: 'Iced Tea',
        categoryId: categoryId,
        price: 49,
        color: 'Yellow',
      ),
    );

    final products = await productRepo.getAll();
    print('Products in DB: $products');
    final product = await productRepo.getById(productId);
    print(product);

    final category_of_product = await categoryRepo.getCategory(
      product!.categoryId,
    );

    print('Category of Product: ${category_of_product?.name}');

    final categories = await categoryRepo.getAll();
    print('Categories in DB: $categories');

    expect(categories.length, 2); // includes "No Category"

    expect(categories.any((c) => c.name == 'Beverages'), true);
  });

  test('Update category', () async {
    final category = Category(id: 1, name: 'Updated Category');
    await categoryRepo.update(category);

    final updated = await categoryRepo.getCategory(1);
    expect(updated?.name, 'Updated Category');
  });
  test('Retrieve category by ID', () async {
    await categoryRepo.insert(Category(name: 'Beverages'));

    final categories = await categoryRepo.getAll();
    print('Categories in DB: $categories');

    final category = await categoryRepo.getCategory(2);
    print('Category: $category');

    expect(category?.name == 'Beverages', true);
  });

  test('Delete category', () async {
    await categoryRepo.delete(1); // delete "No Category"
    final all = await categoryRepo.getAll();
    expect(all.any((c) => c.id == 1), false);
    final categories = await categoryRepo.getAll();
    expect(categories.length, 0);
    print('Categories in DB: $categories');
  });
}
