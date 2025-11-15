import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' show cos, sqrt, asin;

import 'package:proyek_akhir_app/models/map_model.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Position? _currentPosition;
  bool _isLoading = true;
  String _errorMessage = '';
  List<DonationPlace> _nearbyPlaces = [];
  String _searchQuery = '';


  final String _apiKey = '746216caf23943e8bf53c841b0e3098a';
  final int _radiusMeters = 10000; // 10 km

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Izin lokasi ditolak';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Izin lokasi ditolak permanen. Aktifkan di pengaturan.';
          _isLoading = false;
        });
        return;
      }

    
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );


      await _fetchNearbyPlaces();
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mendapatkan lokasi: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchNearbyPlaces() async {
    if (_currentPosition == null) return;

    try {
      final lat = _currentPosition!.latitude;
      final lng = _currentPosition!.longitude;

  
      final categories = [
        'healthcare.hospital',
        'healthcare.clinic',
        'healthcare.blood_bank',
      ];

      List<DonationPlace> allPlaces = [];

   
      for (String category in categories) {
        final url = Uri.parse(
          'https://api.geoapify.com/v2/places?'
          'categories=$category&'
          'filter=circle:$lng,$lat,$_radiusMeters&'
          'limit=50&'
          'apiKey=$_apiKey',
        );

        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final features = data['features'] as List;

          for (var feature in features) {
            final properties = feature['properties'] as Map<String, dynamic>;
            final geometry = feature['geometry'] as Map<String, dynamic>;
            final coordinates = geometry['coordinates'] as List;

           
            final placeLng = coordinates[0] as double;
            final placeLat = coordinates[1] as double;

            
            String type = 'Rumah Sakit';
            if (category == 'healthcare.clinic') {
              type = 'Klinik';
            } else if (category == 'healthcare.blood_bank') {
              type = 'PMI';
            } else if (properties['name']?.toString().toLowerCase().contains('pmi') == true ||
                properties['name']?.toString().toLowerCase().contains('palang merah') == true) {
              type = 'PMI';
            }

           
            final distance = _calculateDistance(lat, lng, placeLat, placeLng);

         
            String address = _buildAddress(properties);

            allPlaces.add(DonationPlace(
              name: properties['name'] ?? properties['address_line1'] ?? 'Tanpa Nama',
              type: type,
              address: address,
              lat: placeLat,
              lng: placeLng,
              distance: distance,
            ));
          }
        }
      }

 
      final uniqueNames = <String>{};
      _nearbyPlaces = allPlaces.where((place) {
        if (place.name == 'Tanpa Nama' || uniqueNames.contains(place.name)) {
          return false;
        }
        uniqueNames.add(place.name);
        return true;
      }).toList();

    
      _nearbyPlaces.sort((a, b) => a.distance!.compareTo(b.distance!));

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mengambil data: $e';
        _isLoading = false;
      });
    }
  }

  String _buildAddress(Map<String, dynamic> properties) {
   
    if (properties['formatted'] != null) {
      return properties['formatted'];
    }

    List<String> parts = [];
    if (properties['street'] != null) parts.add(properties['street']);
    if (properties['housenumber'] != null) parts.add('No. ${properties['housenumber']}');
    if (properties['suburb'] != null) parts.add(properties['suburb']);
    if (properties['city'] != null) parts.add(properties['city']);
    if (properties['state'] != null) parts.add(properties['state']);

    if (parts.isEmpty && properties['address_line1'] != null) {
      return properties['address_line1'];
    }

    return parts.isNotEmpty ? parts.join(', ') : 'Alamat tidak tersedia';
  }

  
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; 
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); 
  }

  List<DonationPlace> get _filteredPlaces {
    if (_searchQuery.isEmpty) return _nearbyPlaces;

    return _nearbyPlaces.where((place) {
      final query = _searchQuery.toLowerCase();
      return place.name.toLowerCase().contains(query) ||
          place.address.toLowerCase().contains(query) ||
          place.type.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFFD32F2F),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Mencari lokasi donor terdekat...',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Expanded(child: _buildErrorState())
            else
              Expanded(child: _buildPlacesList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFFFCDD2),
      ),
    child: Row(
    children: [
      IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context, true),
      ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lokasi Donor Darah',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isLoading
                      ? 'Memuat data...'
                      : '${_nearbyPlaces.length} lokasi ditemukan',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
                      
                      Image.asset(
                        'assets/logo.png', 
                        height: 70,
                        width: 70,
                        fit: BoxFit.contain,
                      ),
              const SizedBox(height: 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Cari lokasi...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFD32F2F),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.my_location, color: Colors.white),
              onPressed: _getCurrentLocation,
              tooltip: 'Refresh lokasi',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacesList() {
    if (_filteredPlaces.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Tidak ada hasil pencarian'
                  : 'Tidak ada lokasi donor ditemukan\ndi sekitar Anda (radius 10km)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredPlaces.length,
      itemBuilder: (context, index) {
        final place = _filteredPlaces[index];
        return _buildPlaceCard(place, index + 1);
      },
    );
  }

  Widget _buildPlaceCard(DonationPlace place, int number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFFCDD2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD32F2F),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

           
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: place.type == 'PMI'
                    ? const Color(0xFFFFCDD2)
                    : place.type == 'Klinik'
                        ? Colors.green[50]
                        : Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                place.type == 'PMI'
                    ? Icons.bloodtype
                    : place.type == 'Klinik'
                        ? Icons.medical_services
                        : Icons.local_hospital,
                color: place.type == 'PMI'
                    ? const Color(0xFFD32F2F)
                    : place.type == 'Klinik'
                        ? Colors.green
                        : Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: place.type == 'PMI'
                          ? Colors.red[50]
                          : place.type == 'Klinik'
                              ? Colors.green[50]
                              : Colors.blue[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      place.type,
                      style: TextStyle(
                        fontSize: 11,
                        color: place.type == 'PMI'
                            ? const Color(0xFFD32F2F)
                            : place.type == 'Klinik'
                                ? Colors.green
                                : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

          
            if (place.distance != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      place.distance!.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'km',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
