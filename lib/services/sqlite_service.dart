import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SqliteService {
  static final SqliteService _instance = SqliteService._internal();
  factory SqliteService() => _instance;
  SqliteService._internal();

  Database? _db;

  Future<Database?> get db async {
    if (kIsWeb) return null; // No disponible en Web
    if (_db != null) return _db;
    _db = await _initDB();
    return _db;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'cashaclin_local.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE local_orders(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sale_id TEXT,
            customer_name TEXT,
            total REAL,
            date TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveOrderLocal(String saleId, String name, double total) async {
    if (kIsWeb) return;
    final database = await db;
    if (database == null) return;

    await database.insert('local_orders', {
      'sale_id': saleId,
      'customer_name': name,
      'total': total,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getLocalOrders() async {
    if (kIsWeb) return [];
    final database = await db;
    if (database == null) return [];
    return await database.query('local_orders', orderBy: 'id DESC');
  }
}
