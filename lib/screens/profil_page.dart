import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:proyek_akhir_app/auth/login_page.dart';
import 'package:proyek_akhir_app/models/users_model.dart';
import 'package:proyek_akhir_app/screens/Kesan_page.dart';
import 'package:proyek_akhir_app/screens/histori_donor.dart';
import 'package:proyek_akhir_app/services/database.dart';
import 'package:proyek_akhir_app/services/login_saved.dart';
import 'map_page.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _loadProfileImage();
  }

  // Load foto dari path tersimpan di database atau SharedPrefs
  void _loadProfileImage() async {
    // ⬅️ DITAMBAH: fallback ke SharedPrefs kalau data di DB kosong
    if (_currentUser.foto == null || _currentUser.foto!.isEmpty) {
      final savedPath = await SharedPrefsService().getPhotoPath();
      if (savedPath != null && savedPath.isNotEmpty) {
        _currentUser = _currentUser.copyWith(foto: savedPath);
      }
    }

    if (_currentUser.foto != null && _currentUser.foto!.isNotEmpty) {
      final file = File(_currentUser.foto!);
      if (file.existsSync()) {
        setState(() {
          _profileImage = file;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Save foto ke permanent directory
        final savedPath = await _saveImagePermanently(pickedFile.path);
        
        // Update database
        await DatabaseHelper.instance.updateUserPhoto(
          _currentUser.id!,
          savedPath,
        );

        // Update SharedPreferences
        await SharedPrefsService().savePhotoPath(savedPath);

        // ⬅️ DITAMBAH: update semua data user ke SharedPrefs
        await SharedPrefsService().saveLoginData(
          userId: _currentUser.id!,
          username: _currentUser.username,
          email: _currentUser.email ?? '',
          photoPath: savedPath,
        );

        // Update state
        setState(() {
          _profileImage = File(savedPath);
          _currentUser = _currentUser.copyWith(foto: savedPath);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diupdate!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Save foto ke direktori aplikasi (permanen)
  Future<String> _saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'profile_${_currentUser.id}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imagePath)}';
    final savedPath = path.join(directory.path, fileName);

    final imageFile = File(imagePath);
    await imageFile.copy(savedPath);

    return savedPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFCDD2),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                height: 35,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // FOTO PROFIL
              Stack(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCDD2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _profileImage != null
                        ? ClipOval(
                            child: Image.file(
                              _profileImage!,
                              fit: BoxFit.cover,
                              width: 150,
                              height: 150,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.black54,
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 28,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                _currentUser.username,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // Riwayat Donor
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DonationHistoryPage(user: _currentUser),
                    ),
                  );
                },
                child: _menuButton('Riwayat Donor Darah'),
              ),

              const SizedBox(height: 30),

              // Saran & Kesan
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SaranKesanPage(),
                    ),
                  );
                },
                child: _menuButton('Saran & Kesan PAM'),
              ),

              const SizedBox(height: 30),

              // Logout
              SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: _showLogoutDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 250, 103, 117),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _menuButton(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFCDD2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
            ),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await SharedPrefsService().logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFFFCDD2),
              foregroundColor: Colors.black,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFCDD2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 0),
              _buildNavItem(Icons.person, 1),
              _buildNavItem(Icons.map, 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = index == 1;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(user: _currentUser)),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MapPage()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red[100] : Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 28, color: Colors.black),
      ),
    );
  }
}
