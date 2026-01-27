import 'dart:async';
import 'package:basic_single_user_pos_flutter/models/modifier_option.dart';
import 'package:basic_single_user_pos_flutter/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class ModifierOptionRepository {
  final DatabaseService _databaseService;

  ModifierOptionRepository(this._databaseService);

  final String _tableName = 'modifier_options';

  Future<int> insert(ModifierOption modifierOption) async {
    final db = await _databaseService.database;

    return await db.insert(
      _tableName,
      modifierOption.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //get
  Future<List<ModifierOption>> getAll() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(
      maps.length,
      (index) => ModifierOption.fromMap(maps[index]),
    );
  }

  Future<ModifierOption?> getByIdAndModifier(int id, int modifierId) async {
    final db = await _databaseService.database;
    final result = await db.query(
      _tableName,
      where: 'id = ? AND modifier_id = ?',
      whereArgs: [id, modifierId],
      limit: 1,
    );
    return result.isEmpty ? null : ModifierOption.fromMap(result.first);
  }

  Future<List<ModifierOption>> getByModifier(int modifierId) async {
    final db = await _databaseService.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'modifier_id = ?',
      whereArgs: [modifierId],
    );

    return List.generate(
      maps.length,
      (index) => ModifierOption.fromMap(maps[index]),
    );
  }

  Future<ModifierOption?> getModifierOption(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return (result.isEmpty) ? null : ModifierOption.fromMap(result.first);
  }

  Future<void> update(ModifierOption modifierOption) async {
    final db = await _databaseService.database;

    await db.update(
      _tableName,
      modifierOption.toMap(),
      where: 'id = ?',
      whereArgs: [modifierOption.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _databaseService.database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteByModifierId(int modifierId) async {
    final db = await _databaseService.database;
    await db.delete(
      'modifier_options',
      where: 'modifier_id = ?',
      whereArgs: [modifierId],
    );
  }
}
