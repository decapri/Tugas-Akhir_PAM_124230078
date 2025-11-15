import 'package:flutter/material.dart';
import 'package:proyek_akhir_app/screens/splash_page.dart';
import 'package:proyek_akhir_app/services/notifikasi_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BloodON',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: const SplashPage(), 
    );
  }
}