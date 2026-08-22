import 'package:basic_single_user_pos_flutter/models/product.dart';
import 'package:basic_single_user_pos_flutter/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

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

    final result = await db.rawQuery(
      '''
      SELECT p.*, GROUP_CONCAT(pm.modifier_id ORDER BY pm.modifier_id) AS enabled_modifier_ids
      FROM products p
      LEFT JOIN product_modifiers pm ON p.id = pm.product_id
      WHERE p.id = ?
      GROUP BY p.id
      ''',
      [id],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    final modifierStr = row['enabled_modifier_ids'] as String?;
    final enabledModifierIds = modifierStr != null
        ? modifierStr.split(',').map(int.parse).toList()
        : <int>[];

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

  Future<List<Product>> getAll() async {
    final db = await _databaseService.database;

    final productRows = await db.rawQuery('''
      SELECT p.*, GROUP_CONCAT(pm.modifier_id ORDER BY pm.modifier_id) AS enabled_modifier_ids
      FROM products p
      LEFT JOIN product_modifiers pm ON p.id = pm.product_id
      GROUP BY p.id
    ''');

    return productRows.map((row) {
      final modifierStr = row['enabled_modifier_ids'] as String?;
      final enabledModifierIds = modifierStr != null
          ? modifierStr.split(',').map(int.parse).toList()
          : <int>[];

      return Product(
        id: row['id'] as int,
        name: row['name'] as String,
        categoryId: row['category_id'] as int,
        price: (row['price'] as num).toDouble(),
        cost: (row['cost'] as num?)?.toDouble(),
        color: row['color'] as String,
        enabledModifierIds: enabledModifierIds,
      );
    }).toList();
  }

  Future<void> update(Product product) async {
    final db = await _databaseService.database;

    await db.transaction((txn) async {
      await txn.update(
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

      await txn.delete(
        'product_modifiers',
        where: 'product_id = ?',
        whereArgs: [product.id],
      );

      for (final modifierId in product.enabledModifierIds) {
        await txn.insert('product_modifiers', {
          'product_id': product.id,
          'modifier_id': modifierId,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });
  }

  Future<void> delete(int id) async {
    final db = await _databaseService.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
