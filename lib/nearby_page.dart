import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class NearbyPage extends StatefulWidget {
  const NearbyPage({super.key});

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> with TickerProviderStateMixin {
  LatLng? _currentLocation;
  List<Map<String, dynamic>> _nearbyBloodBanks = [];
  bool _isLoading = true;
  DateTime? _selectedDate;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  static bool _hasAnimatedOnce = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Initialize with today's date
    _initializeAnimations();
    _initializePage();
  }

  void _initializeAnimations() {
    if (!_hasAnimatedOnce) {
      _fadeController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      );
      _fadeAnimation = CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      );
      _fadeController.forward();
      _hasAnimatedOnce = true;
    } else {
      _fadeController = AnimationController(vsync: this, value: 1.0);
      _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _initializePage() async {
    try {
      // First, get the user's location to center the map
      Position position = await _determinePosition();
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      }
      // Then, fetch camps for the initially selected date (today)
      await _fetchCampsForSelectedDate();
    } catch (e) {
      print("Error initializing page: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar("Error: Could not retrieve location or camp data.");
      }
    }
  }

  Future<void> _fetchCampsForSelectedDate() async {
    if (_selectedDate == null) return;
    if (mounted) setState(() => _isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance.collection('bloodbanks').get();

      // Format the selected date to match Firestore's 'YYYY-MM-DD' format
      final dateFormatted = DateFormat('yyyy-MM-dd').format(_selectedDate!);

      final List<Map<String, dynamic>> banks = snapshot.docs
          .map((doc) => doc.data())
          .where((bank) {
        final campDate = bank['start_date'] ?? bank['date'];
        return campDate == dateFormatted;
      })
          .toList();

      if (mounted) {
        setState(() {
          _nearbyBloodBanks = banks;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching camps: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar("Failed to load camp data.");
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6B6B),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2E2E2E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      // After picking a new date, fetch the camps for that date
      await _fetchCampsForSelectedDate();
    }
  }

  void _showBloodBankDetails(Map<String, dynamic> bank) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(bank['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [const Icon(Icons.location_on, color: Colors.red), const SizedBox(width: 5), Expanded(child: Text(bank['address'] ?? ''))]),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.bloodtype, color: Colors.deepOrange), const SizedBox(width: 5), Expanded(child: Text((bank['blood_required'] as List<dynamic>?)?.join(", ") ?? "N/A"))]),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.phone, color: Colors.green), const SizedBox(width: 5), Text(bank['phone'] ?? '')]),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.calendar_today, color: Colors.purple), const SizedBox(width: 5), Text(bank['start_date'] ?? bank['date'] ?? '')]),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.call, color: Colors.green),
            label: const Text("Call"),
            onPressed: () {
              Navigator.pop(context);
              _launchDialer(bank['phone']);
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.directions, color: Colors.blue),
            label: const Text("Get Directions"),
            onPressed: () {
              Navigator.pop(context);
              _openGoogleMaps(bank['latitude'], bank['longitude']);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _launchDialer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showSnackBar("Could not launch dialer");
    }
  }

  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar("Could not launch Google Maps.");
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent,
    ));
  }

  Widget _buildMapView() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: _currentLocation ?? const LatLng(22.3039, 70.8022), // Rajkot default
        initialZoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.blood_camp_finder_project',
        ),
        MarkerLayer(
          markers: _nearbyBloodBanks.map((bank) {
            final lat = bank['latitude'];
            final lng = bank['longitude'];
            if (lat is double && lng is double) {
              return Marker(
                point: LatLng(lat, lng),
                width: 60,
                height: 60,
                child: GestureDetector(
                  onTap: () => _showBloodBankDetails(bank),
                  child: Image.asset('assets/icon/blood-bank-marker.png'),
                ),
              );
            }
            return null;
          }).whereType<Marker>().toList(),
        ),
        if (_currentLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _currentLocation!,
                width: 50,
                height: 50,
                child: const Icon(Icons.my_location, color: Colors.blue, size: 35),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildFilterCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFFF6B6B).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.calendar_today, color: Color(0xFFFF6B6B), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => _selectDate(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Showing camps for:', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    _selectedDate != null ? DateFormat('MMM dd, yyyy').format(_selectedDate!) : 'Choose a date',
                    style: TextStyle(
                      color: _selectedDate != null ? const Color(0xFF2E2E2E) : const Color(0xFF9E9E9E),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.grey),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFFF8A95), Color(0xFFFF6B6B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        title: const Text("Blood Camps Map", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFilterCard(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B))))
                      : _nearbyBloodBanks.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy_outlined, size: 50, color: Colors.orange[700]),
                        const SizedBox(height: 20),
                        Text(
                          "No blood camps found for",
                          style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedDate != null ? DateFormat('MMMM dd, yyyy').format(_selectedDate!) : "the selected date",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                      : FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildMapView(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}