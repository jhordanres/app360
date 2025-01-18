import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    _database = await openDatabase(
      join(await getDatabasesPath(), 'products.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE products(id INTEGER PRIMARY KEY, name TEXT, price REAL)',
        );
      },
      version: 1,
    );

    return _database!;
  }

  static Future<void> insertProduct(Map<String, dynamic> product) async {
    final db = await getDatabase();
    await db.insert('products', product, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await getDatabase();
    return await db.query('products');
  }

  static Future<void> deleteProduct(int id) async {
    final db = await getDatabase();
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
