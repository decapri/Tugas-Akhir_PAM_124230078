import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static final SharedPrefsService _instance = SharedPrefsService._internal();
  factory SharedPrefsService() => _instance;
  SharedPrefsService._internal();

 
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';
  static const String _keyEmail = 'email';
  static const String _keyPhotoPath = 'photo_path';


  Future<void> saveLoginData({
    required int userId,
    required String username,
    required String email,
    String? photoPath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyEmail, email);
    
   if (photoPath != null && photoPath.isNotEmpty) {
      await prefs.setString(_keyPhotoPath, photoPath);
    }
  }


  Future<void> savePhotoPath(String photoPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPhotoPath, photoPath);
  }


  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }


  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }


  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

 
  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }


  Future<String?> getPhotoPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhotoPath);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear(); 
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final isLogin = await isLoggedIn();
    
    if (!isLogin) return null;

    return {
      'userId': await getUserId(),
      'username': await getUsername(),
      'email': await getEmail(),
      'photoPath': await getPhotoPath(),
    };
  }


  Future<Map<String, dynamic>> getAllData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'isLoggedIn': prefs.getBool(_keyIsLoggedIn) ?? false,
      'userId': prefs.getInt(_keyUserId),
      'username': prefs.getString(_keyUsername),
      'email': prefs.getString(_keyEmail),
      'photoPath': prefs.getString(_keyPhotoPath),
    };
  }
}
