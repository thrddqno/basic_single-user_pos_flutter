import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  Database? _database;

  final String dbName;
  final bool inMemory;

  DatabaseService({
    this.dbName = 'basic_single_user_pos.db',
    this.inMemory = false,
  });

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = inMemory ? ':memory:' : join(dbPath, dbName);

    return await openDatabase(
      path,
      onCreate: _onCreate,
      version: 5,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<void> deleteDb() async {
    if (!inMemory) {
      final path = join(await getDatabasesPath(), dbName);
      await deleteDatabase(path);
    }
    _database = null;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE categories(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
  ''');

    await db.execute('INSERT INTO categories (name) VALUES (\'No Category\')');

    await db.execute('''
    CREATE TABLE modifiers(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE modifier_options(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      modifier_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      price REAL NOT NULL,
      FOREIGN KEY(modifier_id) REFERENCES modifiers(id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
    CREATE TABLE products(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      category_id INTEGER NOT NULL DEFAULT 1,
      price REAL NOT NULL,
      cost REAL,
      color TEXT,
      FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE SET DEFAULT
    )
  ''');

    await db.execute('''
    CREATE TABLE product_modifiers (
      product_id INTEGER NOT NULL,
      modifier_id INTEGER NOT NULL,
      PRIMARY KEY (product_id, modifier_id),
      FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
      FOREIGN KEY (modifier_id) REFERENCES modifiers(id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
    CREATE TABLE receipts(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      payment_method TEXT NOT NULL,
      cash_received REAL
    )
  ''');

    await db.execute('''
    CREATE TABLE receipt_items(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      receipt_id INTEGER NOT NULL,
      product_id INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      product_name TEXT,
      product_price REAL,
      FOREIGN KEY(receipt_id) REFERENCES receipts(id)
    )
  ''');

    await db.execute('''
    CREATE TABLE receipt_item_options(
      receipt_item_id INTEGER NOT NULL,
      modifier_option_id INTEGER NOT NULL,
      option_name TEXT,
      option_price REAL,
      PRIMARY KEY(receipt_item_id, modifier_option_id),
      FOREIGN KEY(receipt_item_id) REFERENCES receipt_items(id),
      FOREIGN KEY(modifier_option_id) REFERENCES modifier_options(id)
    )
  ''');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE receipt_items ADD COLUMN product_name TEXT',
      );
      await db.execute(
        'ALTER TABLE receipt_items ADD COLUMN product_price REAL',
      );
      await db.execute(
        'ALTER TABLE receipt_item_options ADD COLUMN option_name TEXT',
      );
      await db.execute(
        'ALTER TABLE receipt_item_options ADD COLUMN option_price REAL',
      );
    }
    if (oldVersion < 3) {
      final optionsInfo = await db.rawQuery(
        'PRAGMA table_info(receipt_item_options)',
      );
      final hasOptionName = optionsInfo.any((r) => r['name'] == 'option_name');
      if (!hasOptionName) {
        await db.execute(
          'ALTER TABLE receipt_item_options ADD COLUMN option_name TEXT',
        );
        await db.execute(
          'ALTER TABLE receipt_item_options ADD COLUMN option_price REAL',
        );
      }
      final itemsInfo = await db.rawQuery('PRAGMA table_info(receipt_items)');
      final hasProductName = itemsInfo.any((r) => r['name'] == 'product_name');
      if (!hasProductName) {
        await db.execute(
          'ALTER TABLE receipt_items ADD COLUMN product_name TEXT',
        );
        await db.execute(
          'ALTER TABLE receipt_items ADD COLUMN product_price REAL',
        );
      }

      await db.execute('''
        CREATE TABLE receipt_item_options_temp(
          receipt_item_id INTEGER NOT NULL,
          modifier_option_id INTEGER NOT NULL,
          option_name TEXT,
          option_price REAL,
          PRIMARY KEY(receipt_item_id, modifier_option_id)
        )
      ''');
      await db.execute(
        'INSERT INTO receipt_item_options_temp SELECT receipt_item_id, modifier_option_id, option_name, option_price FROM receipt_item_options',
      );
      await db.execute('DROP TABLE receipt_item_options');

      await db.execute('''
        CREATE TABLE receipt_items_new(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          receipt_id INTEGER NOT NULL,
          product_id INTEGER NOT NULL,
          quantity INTEGER NOT NULL,
          product_name TEXT,
          product_price REAL,
          FOREIGN KEY(receipt_id) REFERENCES receipts(id)
        )
      ''');
      await db.execute(
        'INSERT INTO receipt_items_new SELECT id, receipt_id, product_id, quantity, product_name, product_price FROM receipt_items',
      );
      await db.execute('DROP TABLE receipt_items');
      await db.execute('ALTER TABLE receipt_items_new RENAME TO receipt_items');

      await db.execute('''
        CREATE TABLE receipt_item_options(
          receipt_item_id INTEGER NOT NULL,
          modifier_option_id INTEGER NOT NULL,
          option_name TEXT,
          option_price REAL,
          PRIMARY KEY(receipt_item_id, modifier_option_id),
          FOREIGN KEY(receipt_item_id) REFERENCES receipt_items(id),
          FOREIGN KEY(modifier_option_id) REFERENCES modifier_options(id)
        )
      ''');
      await db.execute(
        'INSERT INTO receipt_item_options SELECT receipt_item_id, modifier_option_id, option_name, option_price FROM receipt_item_options_temp',
      );
      await db.execute('DROP TABLE receipt_item_options_temp');
    }
    if (oldVersion < 4) {
      await db.execute(
        'ALTER TABLE receipt_items ADD COLUMN product_cost REAL',
      );
    }

    if (oldVersion < 5) {
      await db.execute(
        'ALTER TABLE receipt_items ADD COLUMN category_name TEXT',
      );
    }
  }
}
