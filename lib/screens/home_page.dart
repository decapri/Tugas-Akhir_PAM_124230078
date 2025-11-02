import 'package:flutter/material.dart';
import 'package:proyek_akhir_app/models/donor_model.dart';
import 'package:proyek_akhir_app/models/haid_model.dart';
import 'package:proyek_akhir_app/models/users_model.dart';
import 'package:proyek_akhir_app/screens/add_haid.dart';
import 'package:proyek_akhir_app/screens/histori_donor.dart';
import 'package:proyek_akhir_app/screens/profil_page.dart';
import 'package:proyek_akhir_app/services/database.dart';
import 'map_page.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedMonth = DateTime.now();
  MenstrualRecord? _latestMenstrual;
  DonationRecord? _latestDonation;
  bool _isLoading = true;
  int _selectedBottomNav = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    _latestMenstrual = await DatabaseHelper.instance.getLatestMenstrualRecord(widget.user.id!);
    _latestDonation = await DatabaseHelper.instance.getLatestDonationRecord(widget.user.id!);
    
    setState(() => _isLoading = false);
  }

  // Cek apakah tanggal adalah masa haid
  bool _isInPeriod(DateTime date) {
    if (_latestMenstrual == null) return false;
    
    // Cek periode saat ini
    if (_latestMenstrual!.isInPeriod(date)) return true;
    
    // Cek prediksi periode berikutnya (28 hari)
    final nextPeriodStart = _latestMenstrual!.nextPeriodDate;
    final nextPeriodEnd = nextPeriodStart.add(Duration(days: _latestMenstrual!.duration - 1));
    
    final dateOnly = DateTime(date.year, date.month, date.day);
    final nextStartOnly = DateTime(nextPeriodStart.year, nextPeriodStart.month, nextPeriodStart.day);
    final nextEndOnly = DateTime(nextPeriodEnd.year, nextPeriodEnd.month, nextPeriodEnd.day);
    
    return dateOnly.isAtSameMomentAs(nextStartOnly) ||
           dateOnly.isAtSameMomentAs(nextEndOnly) ||
           (dateOnly.isAfter(nextStartOnly) && dateOnly.isBefore(nextEndOnly));
  }

  // Cek apakah tanggal bisa untuk donor
  bool _canDonateOnDate(DateTime date) {
    if (_latestMenstrual == null) return false;
    
    // Tidak bisa donor saat haid
    if (_isInPeriod(date)) return false;
    
    // Harus 10 hari setelah haid selesai
    final lastPeriodEnd = _latestMenstrual!.endDate;
    final canDonateAfterPeriod = lastPeriodEnd.add(const Duration(days: 10));
    
    // Jika ada riwayat donor, harus 60 hari setelah donor terakhir
    if (_latestDonation != null) {
      final canDonateAfterLastDonation = _latestDonation!.nextDonationDate;
      return date.isAfter(canDonateAfterPeriod) && 
             date.isAfter(canDonateAfterLastDonation);
    }
    
    return date.isAfter(canDonateAfterPeriod);
  }

  int _getDaysUntilNextPeriod() {
    if (_latestMenstrual == null) return 0;
    final nextPeriod = _latestMenstrual!.nextPeriodDate;
    final today = DateTime.now();
    return nextPeriod.difference(today).inDays;
  }

  int _getDaysUntilCanDonate() {
    if (_latestMenstrual == null) return 0;
    
    final today = DateTime.now();
    final lastPeriodEnd = _latestMenstrual!.endDate;
    final canDonateDate = lastPeriodEnd.add(const Duration(days: 10));
    
    // Jika ada riwayat donor
    if (_latestDonation != null) {
      final canDonateAfterDonation = _latestDonation!.nextDonationDate;
      final latestDate = canDonateDate.isAfter(canDonateAfterDonation) 
          ? canDonateDate 
          : canDonateAfterDonation;
      
      if (today.isAfter(latestDate)) return 0;
      return latestDate.difference(today).inDays;
    }
    
    if (today.isAfter(canDonateDate)) return 0;
    return canDonateDate.difference(today).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    
                    if (_latestMenstrual == null)
                      _buildAddMenstrualPrompt()
                    else
                      _buildDashboard(),
                    
                    const SizedBox(height: 16),
                    _buildCalendar(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selamat datang,',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                widget.user.username,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: [

                      Image.asset(
                        'assets/logo.png',
                        width: 50, // ubah sesuai kebutuhan, misalnya 120
                        height: 50,  
                        fit: BoxFit.contain,
                      ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddMenstrualPrompt() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMenstrualPage(userId: widget.user.id!),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFCDD2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Text(
                'Masukkan tanggal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'menstruasi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Icon(
                  Icons.add,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    final daysUntilPeriod = _getDaysUntilNextPeriod();
    final daysUntilDonate = _getDaysUntilCanDonate();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          
          InkWell(
            onLongPress: () async {
             
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMenstrualPage(
                    userId: widget.user.id!,
                    initialDate: _latestMenstrual?.startDate,
                  ),
                ),
              );
              if (result == true) {
                _loadData();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFCDD2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      Image.asset(
                        'assets/darah.png',
                        width: 30, // ubah sesuai kebutuhan, misalnya 120
                        height: 30, // pastikan path sesuai dengan di pubspec.yaml
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    'HAID →',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    daysUntilPeriod > 0 
                        ? '$daysUntilPeriod hari lagi'
                        : 'Hari ini',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Card DONOR - clickable
                   InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DonationHistoryPage(user: widget.user),
                ),
              );
              if (mounted) {
                _loadData();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFCDD2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 10,
                          top: 10,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD32F2F),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          top: 15,
                          child: Container(
                            width: 16,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD32F2F),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          top: 20,
                          child: Icon(
                            Icons.favorite,
                            color: Colors.red[300],
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    'Donor →',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    daysUntilDonate > 0 
                        ? '$daysUntilDonate hari lagi'
                        : 'Bisa donor',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildCalendarHeader(),
            const SizedBox(height: 16),
            _buildCalendarGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    final monthYear = DateFormat('MMM yyyy').format(_selectedMonth);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          monthYear,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month - 1,
                  );
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month + 1,
                  );
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday;

    return Column(
      children: [
        // Header hari
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
              .map((day) => SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        
        // Grid tanggal
        ...List.generate((daysInMonth + startingWeekday - 1) ~/ 7 + 1, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - startingWeekday + 2;
                
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox(width: 40, height: 40);
                }
                
                final date = DateTime(_selectedMonth.year, _selectedMonth.month, dayNumber);
                final isToday = DateTime.now().day == dayNumber &&
                    DateTime.now().month == _selectedMonth.month &&
                    DateTime.now().year == _selectedMonth.year;
                final isPeriod = _isInPeriod(date);
                final canDonate = _canDonateOnDate(date);

                return GestureDetector(
                  onTap: () async {
                    // Tampilkan dialog untuk set sebagai hari pertama haid
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Set Hari Pertama Haid'),
                        content: Text('Set ${DateFormat('dd MMM yyyy').format(date)} sebagai hari pertama haid?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Ya'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddMenstrualPage(
                            userId: widget.user.id!,
                            initialDate: date,
                          ),
                        ),
                      );
                      _loadData();
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isPeriod
                          ? const Color(0xFFFFCDD2)
                          : canDonate
                              ? Colors.blue[100]
                              : isToday
                                  ? Colors.blue[700]
                                  : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNumber',
                            style: TextStyle(
                              color: isToday ? Colors.white : Colors.black,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                          if (isPeriod)
                            Text(
                              'Haid',
                              style: TextStyle(
                                fontSize: 6,
                                color: Colors.red[900],
                              ),
                            ),
                          if (canDonate)
                            const Text(
                              'Donor',
                              style: TextStyle(
                                fontSize: 6,
                                color: Colors.blue,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFCDD2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
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
    final isSelected = _selectedBottomNav == index;
    
    return GestureDetector(
      onTap: () {
        if (index == 1) {
          // Profile
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(user: widget.user),
            ),
          );
        } else if (index == 2) {
          // Map
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MapPage(),
            ),
          );
        } else {
          setState(() => _selectedBottomNav = index);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red[100] : Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 28,
          color: Colors.black,
        ),
      ),
    );
  }
}