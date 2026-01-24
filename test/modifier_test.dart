import 'package:basic_single_user_pos_flutter/models/modifier.dart';
import 'package:basic_single_user_pos_flutter/repositories/modifier_option_repository.dart';
import 'package:basic_single_user_pos_flutter/repositories/modifier_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:basic_single_user_pos_flutter/services/database_service.dart';
import 'package:basic_single_user_pos_flutter/models/modifier_option.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  late DatabaseService dbService;
  late ModifierOptionRepository modifierOptionRepo;
  late ModifierRepository modifierRepo;

  setUp(() async {
    dbService = DatabaseService(inMemory: true);
    modifierOptionRepo = ModifierOptionRepository(dbService);
    modifierRepo = ModifierRepository(dbService);
  });

  tearDown(() async {
    final db = await dbService.database;
    await db.close(); // reset singleton
  });

  test('Insert and retrieve modifier option', () async {
    final modifier = Modifier(name: 'Add Ons');
    final modifierId = await modifierRepo.insert(modifier);

    await modifierOptionRepo.insert(
      ModifierOption(modifierId: modifierId, name: 'Sprinkles', price: 5),
    );
    await modifierOptionRepo.insert(
      ModifierOption(modifierId: modifierId, name: 'Crushed Oreos', price: 5),
    );

    final allOptions = await modifierOptionRepo.getAll();

    print('Modifier Options in DB: $allOptions');

    expect(allOptions.length, 2);
    expect(allOptions.first.name, 'Sprinkles');
  });

  test('Get modifier option by ID and modifier', () async {
    final modifierId = await modifierRepo.insert(Modifier(name: 'Drizzle'));

    final optionId = await modifierOptionRepo.insert(
      ModifierOption(modifierId: modifierId, name: 'Chocolate', price: 5),
    );

    await modifierOptionRepo.insert(
      ModifierOption(modifierId: modifierId, name: 'Strawberry', price: 5),
    );

    final allOptions = await modifierOptionRepo.getAll();

    print('Modifier Options in DB: $allOptions');

    final fetched = await modifierOptionRepo.getByIdAndModifier(
      modifierId,
      optionId,
    );
    print('Fetched Option: $fetched');

    expect(fetched?.name, 'Chocolate');
  });

  test('Get all options for a modifier', () async {
    final modifierId = await modifierRepo.insert(Modifier(name: 'Extras'));

    await modifierOptionRepo.insert(
      ModifierOption(modifierId: modifierId, name: 'Extra Cheese', price: 50.0),
    );
    await modifierOptionRepo.insert(
      ModifierOption(modifierId: modifierId, name: 'Bacon', price: 70.0),
    );

    final options = await modifierOptionRepo.getByModifier(1);
    print('Options for Modifier 1: $options');

    expect(options.length, 2);
    expect(options.any((o) => o.name == 'Bacon'), true);
  });

  test('Update modifier option', () async {
    final modifierId = await modifierRepo.insert(Modifier(name: 'Extras'));
    final optionId = await modifierOptionRepo.insert(
      ModifierOption(modifierId: modifierId, name: 'Extra Cheese', price: 50.0),
    );
    await modifierOptionRepo.update(
      ModifierOption(
        id: optionId,
        modifierId: modifierId,
        name: 'Double Cheese',
        price: 60.0,
      ),
    );

    final updated = await modifierOptionRepo.getModifierOption(1);
    print('Updated Option: $updated');

    expect(updated?.name, 'Double Cheese');
    expect(updated?.price, 60.0);
  });

  test('Delete modifier option', () async {
    final modifierId = await modifierRepo.insert(Modifier(name: 'Extras'));
    await modifierOptionRepo.insert(
      ModifierOption(modifierId: modifierId, name: 'Extra Cheese', price: 50.0),
    );
    await modifierOptionRepo.delete(1);

    final allOptions = await modifierOptionRepo.getAll();
    print('Modifier Options after delete: $allOptions');

    expect(allOptions.isEmpty, true);
  });
}
