import 'package:basic_single_user_pos_flutter/models/modifier.dart';
import 'package:basic_single_user_pos_flutter/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class ModifierRepository {
  final DatabaseService _databaseService;
  final String _tableName = 'modifiers';

  ModifierRepository(this._databaseService);

  Future<int> insert(Modifier modifier) async {
    final db = await _databaseService.database;
    return await db.insert(
      _tableName,
      modifier.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Modifier?> getById(int id) async {
    final db = await _databaseService.database;
    final result = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isEmpty ? null : Modifier.fromMap(result.first);
  }

  Future<List<Modifier>> getAll() async {
    final db = await _databaseService.database;
    final maps = await db.query(_tableName);
    return List.generate(maps.length, (i) => Modifier.fromMap(maps[i]));
  }

  Future<void> update(Modifier modifier) async {
    final db = await _databaseService.database;
    await db.update(
      _tableName,
      modifier.toMap(),
      where: 'id = ?',
      whereArgs: [modifier.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _databaseService.database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
