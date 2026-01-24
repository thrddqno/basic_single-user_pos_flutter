import 'dart:convert';

import 'package:basic_single_user_pos_flutter/models/product.dart';
import 'package:basic_single_user_pos_flutter/services/database_service.dart';
import 'package:sqflite/sql.dart';

class ProductRepository {
  final DatabaseService _databaseService;

  ProductRepository(this._databaseService);

  // insert

  Future<int> insert(Product product) async {
    final db = await _databaseService.database;

    final productId = await db.insert('products', {
      'name': product.name,
      'category_id': product.categoryId,
      'price': product.price,
      'cost': product.cost,
      'enabled_modifier_ids': jsonEncode(product.enabledModifierIds),
    }, conflictAlgorithm: ConflictAlgorithm.replace);

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

    final row = result.first;

    return Product(
      id: row['id'] as int,
      name: row['name'] as String,
      categoryId: row['category_id'] as int,
      price: (row['price'] as num).toDouble(),
      cost: (row['cost'] as num?)?.toDouble(),
      enabledModifierIds: (row['enabled_modifier_ids'] != null)
          ? List<int>.from(jsonDecode(row['enabled_modifier_ids'] as String))
          : [],
    );
  }

  Future<List<Product>> getAll() async {
    final db = await _databaseService.database;

    final results = await db.query('products');

    return results.map((row) {
      return Product(
        id: row['id'] as int,
        name: row['name'] as String,
        categoryId: row['category_id'] as int,
        price: (row['price'] as num).toDouble(),
        cost: (row['cost'] as num?)?.toDouble(),
        enabledModifierIds: (row['enabled_modifier_ids'] != null)
            ? List<int>.from(jsonDecode(row['enabled_modifier_ids'] as String))
            : [],
      );
    }).toList();
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
        'enabled_modifier_ids': jsonEncode(product.enabledModifierIds),
      },
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _databaseService.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
