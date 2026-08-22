import 'package:basic_single_user_pos_flutter/models/product.dart';
import 'package:basic_single_user_pos_flutter/models/receipt.dart';
import 'package:basic_single_user_pos_flutter/models/receipt_item.dart';
import 'package:basic_single_user_pos_flutter/models/modifier_option.dart';
import 'package:basic_single_user_pos_flutter/repositories/product_repository.dart';
import 'package:basic_single_user_pos_flutter/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class ReceiptRepository {
  final DatabaseService _databaseService;
  ProductRepository productRepository;

  ReceiptRepository(this._databaseService, this.productRepository);

  Future<int> insertReceipt(Receipt receipt) async {
    final db = await _databaseService.database;
    return await db.transaction((txn) async {
      final receiptId = await txn.insert('receipts', {
        'date': receipt.date.toIso8601String(),
        'payment_method': receipt.paymentMethod,
        'cash_received': receipt.cashReceived,
      });

      for (var item in receipt.items) {
        final receiptItemId = await txn.insert('receipt_items', {
          'receipt_id': receiptId,
          'product_id': item.product.id,
          'quantity': item.quantity,
          'product_name': item.product.name,
          'product_price': item.product.price,
          'product_cost': item.productCost,
          'category_id': item.productCategoryId,
        });

        for (var option in item.options) {
          await txn.insert('receipt_item_options', {
            'receipt_item_id': receiptItemId,
            'modifier_option_id': option.id,
            'option_name': option.name,
            'option_price': option.price,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
      return receiptId;
    });
  }

  Future<List<Receipt>> getAll() async {
    final db = await _databaseService.database;

    final receiptRows = await db.query(
      'receipts',
      orderBy: 'date DESC',
    );

    if (receiptRows.isEmpty) return [];

    return _loadReceiptsBulk(db, receiptRows);
  }

  Future<List<Receipt>> getReceiptByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _databaseService.database;
    final receiptRows = await db.query(
      'receipts',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date ASC',
    );

    if (receiptRows.isEmpty) return [];

    return _loadReceiptsBulk(db, receiptRows);
  }

  Future<List<Receipt>> _loadReceiptsBulk(
    Database db,
    List<Map<String, dynamic>> receiptRows,
  ) async {
    final receiptIds = receiptRows.map((r) => r['id'] as int).toList();
    final placeholders = List.filled(receiptIds.length, '?').join(',');

    final allItemRows = await db.rawQuery(
      'SELECT * FROM receipt_items WHERE receipt_id IN ($placeholders)',
      receiptIds,
    );

    final itemIds = allItemRows.map((r) => r['id'] as int).toList();
    final allOptionRows = itemIds.isNotEmpty
        ? await db.rawQuery(
            '''
            SELECT receipt_item_id, modifier_option_id, option_name, option_price
            FROM receipt_item_options
            WHERE receipt_item_id IN (${List.filled(itemIds.length, '?').join(',')})
            ''',
            itemIds,
          )
        : <Map<String, dynamic>>[];

    final optionsByItemId = <int, List<Map<String, dynamic>>>{};
    for (var optRow in allOptionRows) {
      final itemId = optRow['receipt_item_id'] as int;
      optionsByItemId.putIfAbsent(itemId, () => []).add(optRow);
    }

    final itemsByReceiptId = <int, List<ReceiptItem>>{};
    for (var row in allItemRows) {
      final receiptId = row['receipt_id'] as int;
      final productId = row['product_id'] as int;

      final product = Product(
        id: productId,
        name: row['product_name'] as String,
        categoryId: (row['category_id'] as num?)?.toInt() ?? 1,
        price: (row['product_price'] as num).toDouble(),
        cost: (row['product_cost'] as num?)?.toDouble(),
        enabledModifierIds: const [],
        color: '#9E9E9E',
      );

      final optionRowsForItem = optionsByItemId[row['id'] as int] ?? [];
      final options = optionRowsForItem.map((optRow) {
        return ModifierOption(
          id: optRow['modifier_option_id'] as int?,
          modifierId: null,
          name: optRow['option_name'] as String,
          price: (optRow['option_price'] as num).toDouble(),
        );
      }).toList();

      itemsByReceiptId
          .putIfAbsent(receiptId, () => [])
          .add(
            ReceiptItem(
              id: row['id'] as int,
              product: product,
              options: options,
              quantity: row['quantity'] as int,
              productCost: (row['product_cost'] as num?)?.toDouble(),
              productCategoryId: (row['category_id'] as num?)?.toInt(),
            ),
          );
    }

    final receipts = <Receipt>[];
    for (final r in receiptRows) {
      final id = r['id'] as int;
      receipts.add(
        Receipt(
          id: id,
          date: DateTime.parse(r['date'] as String),
          items: itemsByReceiptId[id] ?? [],
          paymentMethod: r['payment_method'] as String,
          cashReceived: r['cash_received'] as double?,
        ),
      );
    }
    return receipts;
  }

  Future<Receipt?> getReceiptById(int id) async {
    final db = await _databaseService.database;

    final receiptRow = await db.query(
      'receipts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (receiptRow.isEmpty) return null;

    final receipts = await _loadReceiptsBulk(db, receiptRow);
    return receipts.isNotEmpty ? receipts.first : null;
  }

  Future<void> deleteReceipt(int id) async {
    final db = await _databaseService.database;
    await db.transaction((txn) async {
      final itemRows = await txn.query(
        'receipt_items',
        where: 'receipt_id = ?',
        whereArgs: [id],
      );
      for (var row in itemRows) {
        await txn.delete(
          'receipt_item_options',
          where: 'receipt_item_id = ?',
          whereArgs: [row['id']],
        );
      }

      await txn.delete('receipt_items', where: 'receipt_id = ?', whereArgs: [id]);
      await txn.delete('receipts', where: 'id = ?', whereArgs: [id]);
    });
  }
}
