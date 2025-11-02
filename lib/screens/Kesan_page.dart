import 'package:flutter/material.dart';

class SaranKesanPage extends StatelessWidget {
  const SaranKesanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
appBar: AppBar(
        backgroundColor: const Color(0xFFFFCDD2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: const Text(
          'Kesan & Saran',
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
              
              // Main Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 139, 151),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama
                    const Text(
                      'Destiana Bunga Amelia',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    
                    // NIM
                    const Text(
                      '124230078',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    
                    // Kelas
                    const Text(
                      'SI-A',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Divider(
                      color: Colors.white, // Warna garis
                      thickness: 1,       // Ketebalan garis
                    ),
                    const SizedBox(height: 40),
                    
                    // Saran Section
                    const Center(
                      child: Text(
                        'SARAN:',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    
                    const Text(
                      'Materinya terlalu teori untuk tugas yang terlalu ngoding.',
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.6,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    const Text(
                      'Kasih tugas sesuai materi yang diajarin ajaa pak.',
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.6,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    const Text(
                      'Kasih jeda buat napas bentar, Pak...',
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.6,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Kesan Section
                    const Center(
                      child: Text(
                        'KESAN:',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    
                    const Text(
                      'Berkesan sekali, hingga membuat FOBIA.',
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.6,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}