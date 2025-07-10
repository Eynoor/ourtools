import 'dart:async';
import 'dart:typed_data';
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
        version: 9, // Upgrade ke versi 9 agar migrasi dijalankan
        onCreate: _createDB,
        onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS rooms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        creatorUsername TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS barang (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_barang TEXT NOT NULL,
        image BLOB,
        stock INTEGER NOT NULL DEFAULT 0,
        room_id INTEGER NOT NULL,
        FOREIGN KEY(room_id) REFERENCES rooms(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS room_members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        room_id INTEGER NOT NULL,
        username TEXT NOT NULL,
        FOREIGN KEY(room_id) REFERENCES rooms(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS peminjaman (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barang_id INTEGER NOT NULL,
        username TEXT NOT NULL,
        jumlah INTEGER NOT NULL,
        tanggal_pinjam TEXT NOT NULL,
        tanggal_kembali TEXT,
        status TEXT NOT NULL DEFAULT 'dipinjam',
        FOREIGN KEY(barang_id) REFERENCES barang(id) ON DELETE CASCADE
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
    if (oldVersion < 8) {
      // Tambahkan kolom image ke tabel users jika belum ada
      await db.execute("ALTER TABLE users ADD COLUMN image BLOB");
    }
    if (oldVersion < 9) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS peminjaman (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          barang_id INTEGER NOT NULL,
          username TEXT NOT NULL,
          jumlah INTEGER NOT NULL,
          tanggal_pinjam TEXT NOT NULL,
          tanggal_kembali TEXT,
          status TEXT NOT NULL DEFAULT 'dipinjam',
          FOREIGN KEY(barang_id) REFERENCES barang(id) ON DELETE CASCADE
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

  // Fungsi untuk mengambil barang berdasarkan ID
  Future<Map<String, dynamic>?> getBarangById(int id) async {
    final db = await database;
    final result = await db.query(
      'barang',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
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

  // Fungsi untuk mengeluarkan member dari room (kick)
  Future<int> removeMemberFromRoom(int roomId, String username) async {
    final db = await database;
    return await db.delete(
      'room_members',
      where: 'room_id = ? AND username = ?',
      whereArgs: [roomId, username],
    );
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

  // Update foto user (image BLOB) berdasarkan username
  Future<int> updateUserImage(String username, Uint8List imageBytes) async {
    final db = await database;
    return await db.update(
      'users',
      {'image': imageBytes},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  // Ambil foto user (image BLOB) berdasarkan username
  Future<Uint8List?> getUserImage(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['image'],
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (result.isNotEmpty && result.first['image'] != null) {
      return result.first['image'] as Uint8List;
    }
    return null;
  }

  // Hapus user dan seluruh data terkait (barang, room, membership)
  Future<void> deleteUser(String username) async {
    final db = await database;
    // Hapus membership user
    await db
        .delete('room_members', where: 'username = ?', whereArgs: [username]);
    // Hapus room yang dibuat user (barang akan ikut terhapus karena ON DELETE CASCADE)
    await db
        .delete('rooms', where: 'creatorUsername = ?', whereArgs: [username]);
    // Hapus user
    await db.delete('users', where: 'username = ?', whereArgs: [username]);
  }

  // Update stok barang berdasarkan id
  Future<void> updateBarangStock(int id, int newStock) async {
    final db = await database;
    await db.update(
      'barang',
      {'stock': newStock},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Tambah riwayat peminjaman
  Future<void> insertPeminjaman({
    required int barangId,
    required String username,
    required int jumlah,
    required String tanggalPinjam,
  }) async {
    final db = await database;
    await db.insert('peminjaman', {
      'barang_id': barangId,
      'username': username,
      'jumlah': jumlah,
      'tanggal_pinjam': tanggalPinjam,
      'status': 'dipinjam',
    });
  }

  // Update status peminjaman (misal: dikembalikan)
  Future<void> updatePeminjamanKembali(int id, String tanggalKembali) async {
    final db = await database;
    await db.update(
      'peminjaman',
      {'status': 'dikembalikan', 'tanggal_kembali': tanggalKembali},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Ambil riwayat peminjaman untuk user/room
  Future<List<Map<String, dynamic>>> getPeminjamanByUser(
      String username) async {
    final db = await database;
    // Join ke tabel barang dan rooms untuk ambil nama_barang, room_id, dan room title
    return await db.rawQuery('''
      SELECT p.*, b.nama_barang, b.room_id, r.title as room_title, r.subtitle as room_subtitle
      FROM peminjaman p 
      LEFT JOIN barang b ON p.barang_id = b.id 
      LEFT JOIN rooms r ON b.room_id = r.id
      WHERE p.username = ? 
      ORDER BY p.id DESC
    ''', [username]);
  }

  Future<List<Map<String, dynamic>>> getPeminjamanByBarang(int barangId) async {
    final db = await database;
    return await db.query('peminjaman',
        where: 'barang_id = ?', whereArgs: [barangId], orderBy: 'id DESC');
  }
}
