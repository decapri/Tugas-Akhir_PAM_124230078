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
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        foto TEXT
      )
    ''');

    
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

  // (enkripsi MD5)
  String encryptPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = md5.convert(bytes);
    return digest.toString();
  }

  
  Future<int> registerUser(User user) async {
    final db = await database;
    
    try {
      
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

 
  Future<bool> isUsernameExists(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  Future<bool> isEmailExists(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }


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


  Future<int> updateUser(User user) async {
    final db = await database;
    
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }


  Future<int> deleteUser(int id) async {
    final db = await database;
    
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final result = await db.query('users');
    
    return result.map((map) => User.fromMap(map)).toList();
  }


  Future<int> updateUserPhoto(int userId, String photoPath) async {
    final db = await database;
    
    return await db.update(
      'users',
      {'foto': photoPath},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }


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


  Future<int> addMenstrualRecord(MenstrualRecord record) async {
    final db = await database;
    return await db.insert('menstrual_records', record.toMap());
  }


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

  
  Future<int> updateMenstrualRecord(MenstrualRecord record) async {
    final db = await database;
    return await db.update(
      'menstrual_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

 
  Future<int> deleteMenstrualRecord(int id) async {
    final db = await database;
    return await db.delete(
      'menstrual_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  Future<int> addDonationRecord(DonationRecord record) async {
    final db = await database;
    return await db.insert('donation_records', record.toMap());
  }

  
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


  Future<int> updateDonationRecord(DonationRecord record) async {
    final db = await database;
    return await db.update(
      'donation_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }


  Future<int> deleteDonationRecord(int id) async {
    final db = await database;
    return await db.delete(
      'donation_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}