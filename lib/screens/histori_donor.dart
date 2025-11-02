import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyek_akhir_app/models/donor_model.dart';
import 'package:proyek_akhir_app/models/users_model.dart';
import 'package:proyek_akhir_app/screens/add_donor.dart';
import 'package:proyek_akhir_app/services/database.dart';
import 'package:proyek_akhir_app/services/uang_konversi.dart';
import 'package:proyek_akhir_app/services/waktu_konversi.dart';

class DonationHistoryPage extends StatefulWidget {
  final User user;

  const DonationHistoryPage({super.key, required this.user});

  @override
  State<DonationHistoryPage> createState() => _DonationHistoryPageState();
}

class _DonationHistoryPageState extends State<DonationHistoryPage> {
  List<DonationRecord> _donations = [];
  bool _isLoading = true;
  String _selectedCurrency = 'USD';
  String _selectedTimezone = 'WIB';
  double _totalReward = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    _donations = await DatabaseHelper.instance.getDonationRecords(widget.user.id!);
    _calculateTotalReward();
    
    setState(() => _isLoading = false);
  }

  void _calculateTotalReward() {
    _totalReward = _donations.length * CurrencyService.rewardPerDonation;
  }

  Future<void> _deleteDonation(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Yakin ingin menghapus data history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('IYA'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteDonationRecord(id);
      _loadData();
    }
  }

  List<DonationRecord> get _filteredDonations {
    if (_searchQuery.isEmpty) return _donations;
    
    return _donations.where((donation) {
      final date = DateFormat('dd/MM/yyyy').format(donation.donationDate);
      final location = donation.location.toLowerCase();
      final query = _searchQuery.toLowerCase();
      
      return date.contains(query) || location.contains(query);
    }).toList();
  }

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
          'Riwayat Donor Darah',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchBar(),
                _buildRewardCard(),
                _buildAddButton(),
                Expanded(child: _buildTable()),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search History',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildRewardCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFCDD2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                children: [
                  Positioned(
                    left: 15,
                    top: 10,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD32F2F),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 17,
                    top: 18,
                    child: Container(
                      width: 20,
                      height: 25,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD32F2F),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.red[300],
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Text donor count
            Expanded(
              child: Text(
                '${_donations.length}x Donor Darah',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // Currency section
            FutureBuilder<double>(
              future: CurrencyService.convertFromUSD(_totalReward, _selectedCurrency),
              builder: (context, snapshot) {
                final amount = snapshot.data ?? _totalReward;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        CurrencyService.formatCurrency(amount, _selectedCurrency),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButton<String>(
                      value: _selectedCurrency,
                      underline: Container(),
                      isDense: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 18),
                      selectedItemBuilder: (BuildContext context) {
                        return ['USD', 'GBP', 'KRW', 'IDR'].map((String value) {
                          return Text(
                            value,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          );
                        }).toList();
                      },
                      items: ['USD', 'GBP', 'KRW', 'IDR']
                          .map((currency) => DropdownMenuItem(
                                value: currency,
                                child: Text(
                                  '${CurrencyService.getCurrencyFlag(currency)} $currency',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCurrency = value);
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ElevatedButton.icon(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddDonationPage(userId: widget.user.id!),
              ),
            );
            if (result == true && mounted) {
              _loadData();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFCDD2),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.add),
          label: const Text(
            'Tambah',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildTableHeader(),
            const Divider(height: 1, thickness: 1),
            Expanded(child: _buildTableBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFFFCDD2),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 30,
            child: Text(
              'No',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          const SizedBox(
            width: 70,
            child: Text(
              'Tanggal',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: DropdownButton<String>(
              value: _selectedTimezone,
              isExpanded: true,
              underline: Container(),
              isDense: true,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              items: ['WIB', 'WITA', 'WIT', 'London']
                  .map((tz) => DropdownMenuItem(
                        value: tz,
                        child: Text(
                          'Waktu\n($tz)',
                          style: const TextStyle(fontSize: 8),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedTimezone = value);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Lokasi',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          const SizedBox(
            width: 35,
            child: Text(
              'Ket',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            width: 50,
            child: Text(
              'Aksi',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableBody() {
    if (_filteredDonations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada riwayat donor',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _filteredDonations.length,
      itemBuilder: (context, index) {
        final donation = _filteredDonations[index];
        final convertedTime = TimezoneService.convertTimezone(
          donation.donationDate,
          donation.timezone,
          _selectedTimezone,
        );

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 70,
                    child: Text(
                      DateFormat('dd/MM/yy').format(donation.donationDate),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 70,
                    child: Text(
                      TimezoneService.formatTimeWithZone(convertedTime),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      donation.location,
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 35,
                    child: Text(
                      donation.notes?.isEmpty ?? true ? '-' : donation.notes!,
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddDonationPage(
                                  userId: widget.user.id!,
                                  donation: donation,
                                ),
                              ),
                            );
                            if (result == true && mounted) {
                              _loadData();
                            }
                          },
                          child: Image.asset(
                            'assets/Edit.png',
                            width: 18,
                            height: 18,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _deleteDonation(donation.id!),
                          child: Image.asset(
                            'assets/delete.png',
                            width: 18,
                            height: 18,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (index < _filteredDonations.length - 1)
              const Divider(height: 1, thickness: 0.5),
          ],
        );
      },
    );
  }
}