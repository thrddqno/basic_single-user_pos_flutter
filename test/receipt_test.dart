import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:basic_single_user_pos_flutter/services/database_service.dart';
import 'package:basic_single_user_pos_flutter/models/category.dart';
import 'package:basic_single_user_pos_flutter/models/product.dart';
import 'package:basic_single_user_pos_flutter/models/modifier.dart';
import 'package:basic_single_user_pos_flutter/models/modifier_option.dart';
import 'package:basic_single_user_pos_flutter/models/receipt.dart';
import 'package:basic_single_user_pos_flutter/models/receipt_item.dart';
import 'package:basic_single_user_pos_flutter/repositories/product_repository.dart';
import 'package:basic_single_user_pos_flutter/repositories/modifier_repository.dart';
import 'package:basic_single_user_pos_flutter/repositories/modifier_option_repository.dart';
import 'package:basic_single_user_pos_flutter/repositories/receipt_repository.dart';
import 'package:basic_single_user_pos_flutter/repositories/category_repository.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late DatabaseService databaseService;
  late CategoryRepository categoryRepo;
  late ProductRepository productRepo;
  late ModifierRepository modifierRepo;
  late ModifierOptionRepository modifierOptionRepo;
  late ReceiptRepository receiptRepo;

  setUp(() async {
    databaseService = DatabaseService(inMemory: true);
    categoryRepo = CategoryRepository(databaseService);
    productRepo = ProductRepository(databaseService);
    modifierRepo = ModifierRepository(databaseService);
    modifierOptionRepo = ModifierOptionRepository(databaseService);
    receiptRepo = ReceiptRepository(databaseService, productRepo);
  });

  tearDown(() async {
    final db = await databaseService.database;
    await db.close();
  });

  test('Insert and retrieve receipt', () async {
    // --- Setup category ---
    final catId = await categoryRepo.insert(Category(name: 'Snacks'));

    // --- Setup product ---
    final productId1 = await productRepo.insert(
      Product(name: 'Cheese Stick', categoryId: catId, price: 40),
    );
    final product1 = await productRepo.getById(productId1);

    final productId2 = await productRepo.insert(
      Product(name: 'Frenchies', categoryId: catId, price: 50),
    );
    final product2 = await productRepo.getById(productId2);
    // --- Setup modifier and options ---
    final modifierId = await modifierRepo.insert(Modifier(name: 'Extras'));
    final optionId1 = await modifierOptionRepo.insert(
      ModifierOption(modifierId: modifierId, name: 'Cheese', price: 5),
    );
    final optionId2 = await modifierOptionRepo.insert(
      ModifierOption(modifierId: modifierId, name: 'Bacon', price: 7),
    );

    final option1 = await modifierOptionRepo.getModifierOption(optionId1);
    final option2 = await modifierOptionRepo.getModifierOption(optionId2);

    // --- Create receipt item ---
    final item1 = ReceiptItem(
      product: product1!,
      options: [option1!, option2!],
      quantity: 2,
    );
    final item2 = ReceiptItem(
      product: product2!,
      options: [option2],
      quantity: 4,
    );

    // --- Insert receipt ---
    final receipt = Receipt(
      date: DateTime.now(),
      items: [item1, item2],
      paymentMethod: 'Cash',
      cashReceived: 500,
    );

    final receiptId = await receiptRepo.insertReceipt(receipt);

    // --- Retrieve and assert ---
    final fetched = await receiptRepo.getReceiptById(receiptId);
    expect(fetched, isNotNull);

    print('Fetched Receipt: $fetched');
  });
}
