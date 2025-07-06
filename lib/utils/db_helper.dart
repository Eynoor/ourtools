import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('rooms.db');
    return _database!;
  }
  
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 5, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE rooms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        creatorUsername TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE barang (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_barang TEXT NOT NULL,
        image BLOB,
        stock INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE rooms ADD COLUMN creatorUsername TEXT NOT NULL DEFAULT 'unknown'
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE barang (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama_barang TEXT NOT NULL,
          image BLOB,
          stock INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }
    if (oldVersion < 5) {
      await db.execute('''
        ALTER TABLE barang ADD COLUMN stock INTEGER NOT NULL DEFAULT 0
      ''');
    }
  }

  Future<int> insertRoom(Map<String, String> room) async {
    final db = await database;
    return await db.insert('rooms', room);
  }

  Future<List<Map<String, dynamic>>> getRooms(String creatorUsername) async {
    final db = await database;
    return await db.query(
      'rooms',
      where: 'creatorUsername = ?',
      whereArgs: [creatorUsername],
    );
  }

  Future<int> insertUser(Map<String, String> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getUserByCredentials(String username, String password) async {
    final db = await database;
    return await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
  }

  // Fungsi untuk menambahkan barang baru ke database
  Future<int> insertBarang(Map<String, dynamic> barang) async {
    final db = await database;
    return await db.insert('barang', barang);
  }

  // Fungsi untuk mengambil semua barang dari database
  Future<List<Map<String, dynamic>>> getAllBarang() async {
    final db = await database;
    return await db.query('barang', orderBy: 'id DESC');
  }

  // Fungsi untuk menghapus barang berdasarkan ID
  Future<int> deleteBarang(int id) async {
    final db = await database;
    return await db.delete(
      'barang',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
