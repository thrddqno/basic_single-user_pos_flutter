import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  Database? _database;

  final String dbName;
  final bool inMemory;
  //make databases testable by making service configurable
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
      version: 1,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
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

  // ---------------- SCHEMA ----------------
  Future<void> _onCreate(Database db, int version) async {
    // --- independent tables ---
    // category table
    await db.execute('''
    CREATE TABLE categories(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
  ''');
    // insert default as no category
    await db.execute('INSERT INTO categories (name) VALUES (\'No Category\')');

    // modifier table
    await db.execute('''
    CREATE TABLE modifiers(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
  ''');

    // modifier options table
    await db.execute('''
    CREATE TABLE modifier_options(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      modifier_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      price REAL NOT NULL,
      FOREIGN KEY(modifier_id) REFERENCES modifiers(id)
    )
  ''');

    // --- dependent tables ---
    // products table
    await db.execute('''
    CREATE TABLE products(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      category_id INTEGER NOT NULL DEFAULT 1,
      price REAL NOT NULL,
      cost REAL,
      FOREIGN KEY(category_id) REFERENCES categories(id)
    )
  ''');

    // product modifiers, which are enabled modifiers in the thingy
    await db.execute('''
    CREATE TABLE product_modifiers(
      product_id INTEGER NOT NULL,
      modifier_id INTEGER NOT NULL,
      PRIMARY KEY(product_id, modifier_id),
      FOREIGN KEY(product_id) REFERENCES products(id),
      FOREIGN KEY(modifier_id) REFERENCES modifiers(id)
    )
  ''');

    // receipts table
    await db.execute('''
    CREATE TABLE receipts(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      payment_method TEXT NOT NULL,
      cash_received REAL
    )
  ''');

    // receipts item table
    await db.execute('''
    CREATE TABLE receipt_items(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      receipt_id INTEGER NOT NULL,
      product_id INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      FOREIGN KEY(receipt_id) REFERENCES receipts(id),
      FOREIGN KEY(product_id) REFERENCES products(id)
    )
  ''');

    // receipt item options which are options in the receipt items table
    await db.execute('''
    CREATE TABLE receipt_item_options(
      receipt_item_id INTEGER NOT NULL,
      modifier_option_id INTEGER NOT NULL,
      PRIMARY KEY(receipt_item_id, modifier_option_id),
      FOREIGN KEY(receipt_item_id) REFERENCES receipt_items(id),
      FOREIGN KEY(modifier_option_id) REFERENCES modifier_options(id)
    )
  ''');
  }
}
