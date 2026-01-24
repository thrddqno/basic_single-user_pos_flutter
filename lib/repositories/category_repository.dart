import 'package:basic_single_user_pos_flutter/services/database_service.dart';
import 'package:basic_single_user_pos_flutter/models/category.dart';
import 'package:sqflite/sqflite.dart';

class CategoryRepository {
  final DatabaseService _databaseService;

  CategoryRepository(this._databaseService);

  final String _tableName = 'categories';

  Future<int> insert(Category category) async {
    final db = await _databaseService.database;
    final categoryId = await db.insert(
      _tableName,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return categoryId;
  }

  Future<List<Category>> getAll() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (index) => Category.fromMap(maps[index]));
  }

  //aint sure if i'm going to use this but it's great to have
  Future<Category?> getCategory(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return (result.isEmpty) ? null : Category.fromMap(result.first);
  }

  Future<void> update(Category category) async {
    final db = await _databaseService.database;

    await db.update(
      _tableName,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _databaseService.database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
