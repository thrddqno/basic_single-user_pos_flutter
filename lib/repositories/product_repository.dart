import 'package:basic_single_user_pos_flutter/models/product.dart';
import 'package:basic_single_user_pos_flutter/services/database_service.dart';
import 'package:sqflite/sql.dart';

class ProductRepository {
  final DatabaseService _databaseService;

  ProductRepository(this._databaseService);

  Future<int> insert(Product product) async {
    final db = await _databaseService.database;

    final productId = await db.insert('products', {
      'name': product.name,
      'category_id': product.categoryId,
      'price': product.price,
      'cost': product.cost,
      'color': product.color,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    for (final modifierId in product.enabledModifierIds) {
      await db.insert('product_modifiers', {
        'product_id': productId,
        'modifier_id': modifierId,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    return productId;
  }

  Future<Product?> getById(int id) async {
    final db = await _databaseService.database;

    final result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    final modifierResult = await db.query(
      'product_modifiers',
      where: 'product_id = ?',
      whereArgs: [id],
    );

    final enabledModifierIds = modifierResult
        .map((r) => r['modifier_id'] as int)
        .toList();

    final row = result.first;

    return Product(
      id: row['id'] as int,
      name: row['name'] as String,
      categoryId: row['category_id'] as int,
      price: (row['price'] as num).toDouble(),
      cost: (row['cost'] as num?)?.toDouble(),
      color: row['color'] as String,
      enabledModifierIds: enabledModifierIds,
    );
  }

  Future<void> updateProductModifiers(
    int productId,
    List<int> modifierIds,
  ) async {
    final db = await _databaseService.database;

    // Remove old links
    await db.delete(
      'product_modifiers',
      where: 'product_id = ?',
      whereArgs: [productId],
    );

    // Insert new links
    for (final modifierId in modifierIds) {
      await db.insert('product_modifiers', {
        'product_id': productId,
        'modifier_id': modifierId,
      });
    }
  }

  Future<List<Product>> getAll() async {
    final db = await _databaseService.database;

    final productRows = await db.query('products');

    List<Product> products = [];

    for (final row in productRows) {
      final productId = row['id'] as int;

      final modifierRows = await db.query(
        'product_modifiers',
        where: 'product_id = ?',
        whereArgs: [productId],
      );

      final enabledModifierIds = modifierRows
          .map((r) => r['modifier_id'] as int)
          .toList();

      products.add(
        Product(
          id: productId,
          name: row['name'] as String,
          categoryId: row['category_id'] as int,
          price: (row['price'] as num).toDouble(),
          cost: (row['cost'] as num?)?.toDouble(),
          color: row['color'] as String,
          enabledModifierIds: enabledModifierIds,
        ),
      );
    }

    return products;
  }

  Future<void> update(Product product) async {
    final db = await _databaseService.database;

    await db.update(
      'products',
      {
        'name': product.name,
        'category_id': product.categoryId,
        'price': product.price,
        'cost': product.cost,
        'color': product.color,
      },
      where: 'id = ?',
      whereArgs: [product.id],
    );

    await db.delete(
      'product_modifiers',
      where: 'product_id =?',
      whereArgs: [product.id],
    );

    for (final modifierId in product.enabledModifierIds) {
      await db.insert('product_modifiers', {
        'product_id': product.id,
        'modifier_id': modifierId,
      });
    }
  }

  Future<void> delete(int id) async {
    final db = await _databaseService.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
