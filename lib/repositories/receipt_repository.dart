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

    final receiptId = await db.insert('receipts', {
      'date': receipt.date.toIso8601String(),
      'payment_method': receipt.paymentMethod,
      'cash_received': receipt.cashReceived,
    });

    for (var item in receipt.items) {
      final receiptItemId = await db.insert('receipt_items', {
        'receipt_id': receiptId,
        'product_id': item.product.id,
        'quantity': item.quantity,
      });

      for (var option in item.options) {
        await db.insert('receipt_item_options', {
          'receipt_item_id': receiptItemId,
          'modifier_option_id': option.id,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }
    return receiptId;
  }

  Future<List<Receipt>> getAll() async {
    final db = await _databaseService.database;

    final receiptRow = await db.query(
      'receipt',
      columns: ['id'],
      orderBy: 'date DESC',
    );

    final receipts = <Receipt>[];

    for (final row in receiptRow) {
      final receiptId = row['id'] as int;
      final receipt = await getReceiptById(receiptId);
      if (receipt != null) {
        receipts.add(receipt);
      }
    }
    return receipts;
  }

  //parse date
  /*
  String _parseDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }*/

  Future<List<Receipt>> getReceiptByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _databaseService.database;
    final rows = await db.query(
      'receipts',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date ASC',
    );

    final receipts = <Receipt>[];

    for (final row in rows) {
      final receiptId = row['id'] as int;
      final receipt = await getReceiptById(receiptId);
      if (receipt != null) {
        receipts.add(receipt);
      }
    }
    return receipts;
  }

  Future<Receipt?> getReceiptById(int id) async {
    final db = await _databaseService.database;

    // 1️⃣ Get the receipt
    final receiptRow = await db.query(
      'receipts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (receiptRow.isEmpty) return null;

    final r = receiptRow.first;

    // 2️⃣ Get all items
    final itemRows = await db.query(
      'receipt_items',
      where: 'receipt_id = ?',
      whereArgs: [id],
    );
    final items = <ReceiptItem>[];

    for (var row in itemRows) {
      final productId = row['product_id'] as int;
      final product = await ProductRepository(
        _databaseService,
      ).getById(productId);

      // 3️⃣ Get modifier options
      final optionRows = await db.rawQuery(
        '''
        SELECT mo.id, mo.modifier_id, mo.name, mo.price
        FROM receipt_item_options rio
        JOIN modifier_options mo ON rio.modifier_option_id = mo.id
        WHERE rio.receipt_item_id = ?
      ''',
        [row['id']],
      );

      final options = optionRows.map((o) => ModifierOption.fromMap(o)).toList();

      items.add(
        ReceiptItem(
          id: row['id'] as int,
          product: product!,
          options: options,
          quantity: row['quantity'] as int,
        ),
      );
    }

    return Receipt(
      id: r['id'] as int,
      date: DateTime.parse(r['date'] as String),
      items: items,
      paymentMethod: r['payment_method'] as String,
      cashReceived: r['cash_received'] as double?,
    );
  }

  Future<void> deleteReceipt(int id) async {
    final db = await _databaseService.database;

    final itemRows = await db.query(
      'receipt_items',
      where: 'receipt_id = ?',
      whereArgs: [id],
    );
    for (var row in itemRows) {
      await db.delete(
        'receipt_item_options',
        where: 'receipt_item_id = ?',
        whereArgs: [row['id']],
      );
    }

    await db.delete('receipt_items', where: 'receipt_id = ?', whereArgs: [id]);

    await db.delete('receipts', where: 'id = ?', whereArgs: [id]);
  }
}
