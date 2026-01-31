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
        'product_name': item.product.name,
        'product_price': item.product.price,
        'product_cost': item.product.cost,
        'category_id': item.productCategoryId,
      });

      for (var option in item.options) {
        await db.insert('receipt_item_options', {
          'receipt_item_id': receiptItemId,
          'modifier_option_id': option.id,
          'option_name': option.name,
          'option_price': option.price,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }
    return receiptId;
  }

  Future<List<Receipt>> getAll() async {
    final db = await _databaseService.database;

    final receiptRow = await db.query(
      'receipts',
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

    final receiptRow = await db.query(
      'receipts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (receiptRow.isEmpty) return null;

    final r = receiptRow.first;

    final itemRows = await db.query(
      'receipt_items',
      where: 'receipt_id = ?',
      whereArgs: [id],
    );

    final allOptionRows = await db.rawQuery(
      '''
      SELECT rio.receipt_item_id, rio.modifier_option_id, rio.option_name, rio.option_price
      FROM receipt_item_options rio
      INNER JOIN receipt_items ri ON rio.receipt_item_id = ri.id
      WHERE ri.receipt_id = ?
      ''',
      [id],
    );

    final optionsByItemId = <int, List<Map<String, dynamic>>>{};
    final optionIdsNeedingFallback = <int>{};
    for (var optRow in allOptionRows) {
      final itemId = optRow['receipt_item_id'] as int;
      optionsByItemId.putIfAbsent(itemId, () => []).add(optRow);
      final snapshotName = optRow['option_name'] as String?;
      final snapshotPrice = optRow['option_price'];
      final optId = optRow['modifier_option_id'] as int?;
      if (optId != null && (snapshotName == null || snapshotPrice == null)) {
        optionIdsNeedingFallback.add(optId);
      }
    }

    final optionFallbackMap = <int, ModifierOption>{};
    if (optionIdsNeedingFallback.isNotEmpty) {
      final placeholders = List.filled(
        optionIdsNeedingFallback.length,
        '?',
      ).join(',');
      final moRows = await db.rawQuery(
        'SELECT id, modifier_id, name, price FROM modifier_options WHERE id IN ($placeholders)',
        optionIdsNeedingFallback.toList(),
      );
      for (var mo in moRows) {
        optionFallbackMap[mo['id'] as int] = ModifierOption.fromMap(mo);
      }
    }

    final items = <ReceiptItem>[];
    for (var row in itemRows) {
      final productId = row['product_id'] as int;
      Product product =
          await productRepository.getById(productId) ??
          _productFromSnapshot(
            productId,
            row['product_name'] as String?,
            row['product_price'],
          );

      final optionRowsForItem = optionsByItemId[row['id'] as int] ?? [];
      final options = <ModifierOption>[];
      for (var optRow in optionRowsForItem) {
        final optId = optRow['modifier_option_id'] as int?;
        final snapshotName = optRow['option_name'] as String?;
        final snapshotPrice = optRow['option_price'];

        if (snapshotName != null && snapshotPrice != null) {
          options.add(
            ModifierOption(
              id: optId,
              modifierId: null,
              name: snapshotName,
              price: (snapshotPrice as num).toDouble(),
            ),
          );
        } else if (optId != null) {
          options.add(
            optionFallbackMap[optId] ??
                ModifierOption(
                  id: optId,
                  modifierId: null,
                  name: 'Unknown option',
                  price: 0,
                ),
          );
        }
      }

      items.add(
        ReceiptItem(
          id: row['id'] as int,
          product: product,
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

  Product _productFromSnapshot(int id, String? name, dynamic price) {
    return Product(
      id: id,
      name: name ?? 'Unknown product',
      categoryId: 1,
      price: (price is num) ? price.toDouble() : 0,
      enabledModifierIds: const [],
      cost: null,
      color: '#9E9E9E',
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
