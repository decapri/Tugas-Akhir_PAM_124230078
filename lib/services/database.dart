import 'package:proyek_akhir_app/models/donor_model.dart';
import 'package:proyek_akhir_app/models/haid_model.dart';
import 'package:proyek_akhir_app/models/users_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Tabel users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        foto TEXT
      )
    ''');

    // Tabel menstrual_records (riwayat haid)
    await db.execute('''
      CREATE TABLE menstrual_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        start_date TEXT NOT NULL,
        duration INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Tabel donation_records (riwayat donor)
    await db.execute('''
      CREATE TABLE donation_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        donation_date TEXT NOT NULL,
        timezone TEXT DEFAULT 'WIB',
        location TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  // Fungsi untuk enkripsi password dengan MD5
  String encryptPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = md5.convert(bytes);
    return digest.toString();
  }

  // Registrasi user baru (menggunakan User model)
  Future<int> registerUser(User user) async {
    final db = await database;
    
    try {
      // Enkripsi password sebelum disimpan
      final userWithEncryptedPassword = user.copyWith(
        password: encryptPassword(user.password),
      );
      
      final id = await db.insert('users', userWithEncryptedPassword.toMap());
      return id;
    } catch (e) {
      print('Error registrasi: $e');
      return -1;
    }
  }

  // Login user (return User object atau null)
  Future<User?> loginUser({
    required String username,
    required String password,
  }) async {
    final db = await database;
    
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, encryptPassword(password)],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // Cek apakah username sudah ada
  Future<bool> isUsernameExists(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  // Cek apakah email sudah ada
  Future<bool> isEmailExists(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  // Get user by ID (tambahan, berguna untuk fitur profile)
  Future<User?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // Get user by username (tambahan)
  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // Update user (untuk fitur edit profile nanti)
  Future<int> updateUser(User user) async {
    final db = await database;
    
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Delete user (jika diperlukan)
  Future<int> deleteUser(int id) async {
    final db = await database;
    
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get all users (untuk admin atau debugging)
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final result = await db.query('users');
    
    return result.map((map) => User.fromMap(map)).toList();
  }

  // Update foto user
  Future<int> updateUserPhoto(int userId, String photoPath) async {
    final db = await database;
    
    return await db.update(
      'users',
      {'foto': photoPath},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Get user dengan foto
  Future<User?> getUserWithPhoto(int userId) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future close() async {
    final db = await database;
    db.close();
  }

  // ==================== MENSTRUAL RECORDS ====================
  
  // Tambah riwayat haid
  Future<int> addMenstrualRecord(MenstrualRecord record) async {
    final db = await database;
    return await db.insert('menstrual_records', record.toMap());
  }

  // Get riwayat haid terbaru user
  Future<MenstrualRecord?> getLatestMenstrualRecord(int userId) async {
    final db = await database;
    final result = await db.query(
      'menstrual_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'start_date DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return MenstrualRecord.fromMap(result.first);
    }
    return null;
  }

  // Get semua riwayat haid user
  Future<List<MenstrualRecord>> getMenstrualRecords(int userId) async {
    final db = await database;
    final result = await db.query(
      'menstrual_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'start_date DESC',
    );

    return result.map((map) => MenstrualRecord.fromMap(map)).toList();
  }

  // Update riwayat haid
  Future<int> updateMenstrualRecord(MenstrualRecord record) async {
    final db = await database;
    return await db.update(
      'menstrual_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // Delete riwayat haid
  Future<int> deleteMenstrualRecord(int id) async {
    final db = await database;
    return await db.delete(
      'menstrual_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== DONATION RECORDS ====================
  
  // Tambah riwayat donor
  Future<int> addDonationRecord(DonationRecord record) async {
    final db = await database;
    return await db.insert('donation_records', record.toMap());
  }

  // Get riwayat donor terbaru user
  Future<DonationRecord?> getLatestDonationRecord(int userId) async {
    final db = await database;
    final result = await db.query(
      'donation_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'donation_date DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return DonationRecord.fromMap(result.first);
    }
    return null;
  }

  // Get semua riwayat donor user
  Future<List<DonationRecord>> getDonationRecords(int userId) async {
    final db = await database;
    final result = await db.query(
      'donation_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'donation_date DESC',
    );

    return result.map((map) => DonationRecord.fromMap(map)).toList();
  }

  // Update riwayat donor
  Future<int> updateDonationRecord(DonationRecord record) async {
    final db = await database;
    return await db.update(
      'donation_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // Delete riwayat donor
  Future<int> deleteDonationRecord(int id) async {
    final db = await database;
    return await db.delete(
      'donation_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}