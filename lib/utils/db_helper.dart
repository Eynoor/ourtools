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

    return await openDatabase(path,
        version: 7, // Upgrade ke versi 7 agar migrasi dijalankan
        onCreate: _createDB,
        onUpgrade: _upgradeDB);
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
        stock INTEGER NOT NULL DEFAULT 0,
        room_id INTEGER NOT NULL,
        FOREIGN KEY(room_id) REFERENCES rooms(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE room_members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        room_id INTEGER NOT NULL,
        username TEXT NOT NULL,
        FOREIGN KEY(room_id) REFERENCES rooms(id) ON DELETE CASCADE
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
          stock INTEGER NOT NULL DEFAULT 0,
          room_id INTEGER NOT NULL,
          FOREIGN KEY(room_id) REFERENCES rooms(id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 5) {
      await db.execute('''
        ALTER TABLE barang ADD COLUMN stock INTEGER NOT NULL DEFAULT 0
      ''');
    }
    if (oldVersion < 6) {
      // Tambahkan kolom room_id jika belum ada
      await db.execute("ALTER TABLE barang ADD COLUMN room_id INTEGER;");
    }
    if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE room_members (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          room_id INTEGER NOT NULL,
          username TEXT NOT NULL,
          FOREIGN KEY(room_id) REFERENCES rooms(id) ON DELETE CASCADE
        )
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

  Future<List<Map<String, dynamic>>> getUserByCredentials(
      String username, String password) async {
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

  Future<List<Map<String, dynamic>>> getBarangByRoom(int roomId) async {
    final db = await database;
    return await db.query(
      'barang',
      where: 'room_id = ?',
      whereArgs: [roomId],
      orderBy: 'id DESC',
    );
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

  Future<List<Map<String, dynamic>>> getRoomsByTitle(String title) async {
    final db = await database;
    return await db.query(
      'rooms',
      where: 'title = ?',
      whereArgs: [title],
    );
  }

  Future<int> deleteRoom(int id) async {
    final db = await database;
    // Hapus room berdasarkan id, barang terkait akan terhapus otomatis karena ON DELETE CASCADE
    return await db.delete(
      'rooms',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String?> getRoomAdminByTitle(String title) async {
    final db = await database;
    final result = await db.query(
      'rooms',
      columns: ['creatorUsername'],
      where: 'title = ?',
      whereArgs: [title],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['creatorUsername'] as String?;
    }
    return null;
  }

  Future<int> addMemberToRoom(int roomId, String username) async {
    final db = await database;
    return await db.insert('room_members', {
      'room_id': roomId,
      'username': username,
    });
  }

  Future<List<String>> getMembersByRoomId(int roomId) async {
    final db = await database;
    final result = await db.query(
      'room_members',
      columns: ['username'],
      where: 'room_id = ?',
      whereArgs: [roomId],
    );
    return result.map((e) => e['username'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> getRoomByTitle(String title) async {
    final db = await database;
    return await db.query(
      'rooms',
      where: 'title = ?',
      whereArgs: [title],
    );
  }

  Future<List<Map<String, dynamic>>> getAllRoomsForUser(String username) async {
    final db = await database;
    // Room yang dibuat user
    final createdRooms = await db.query(
      'rooms',
      where: 'creatorUsername = ?',
      whereArgs: [username],
    );
    // Room yang di-join user
    final joinedRooms = await db.rawQuery('''
      SELECT rooms.* FROM rooms
      INNER JOIN room_members ON rooms.id = room_members.room_id
      WHERE room_members.username = ?
    ''', [username]);
    // Gabungkan dan hilangkan duplikat berdasarkan id
    final allRooms = {...createdRooms, ...joinedRooms}.toList();
    return allRooms;
  }

  Future<bool> isUserMemberOfRoom(int roomId, String username) async {
    final db = await database;
    final result = await db.query(
      'room_members',
      where: 'room_id = ? AND username = ?',
      whereArgs: [roomId, username],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
