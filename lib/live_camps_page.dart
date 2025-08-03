// lib/live_camps_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'animation_manager.dart';
import 'blood_camp_details_page.dart';

class LiveCampsPage extends StatefulWidget {
  const LiveCampsPage({super.key});

  @override
  State<LiveCampsPage> createState() => _LiveCampsPageState();
}

class _LiveCampsPageState extends State<LiveCampsPage>
    with TickerProviderStateMixin {
  String? selectedState;
  String? selectedCity;
  DateTime? selectedDate;
  List<String> states = [];
  List<String> cities = [];
  bool isLoading = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    fetchStates();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    if (AnimationManager.instance.hasAnimated('liveCampsPage')) {
      _fadeController.value = 1.0;
      _slideController.value = 1.0;
    }

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> fetchStates() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('bloodbanks').get();
      final uniqueStates = snapshot.docs
          .map((doc) => doc['state'] as String?)
          .whereType<String>()
          .toSet()
          .toList()
        ..sort();

      if (mounted) {
        setState(() {
          states = uniqueStates;
          isLoading = false;
        });

        if (!AnimationManager.instance.hasAnimated('liveCampsPage')) {
          _fadeController.forward();
          _slideController.forward();
          AnimationManager.instance.setAnimated('liveCampsPage');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showSnackBar('Error loading states: ${e.toString()}');
      }
    }
  }

  Future<void> fetchCitiesForState(String state) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bloodbanks')
          .where('state', isEqualTo: state)
          .get();
      final uniqueCities = snapshot.docs
          .map((doc) => doc['city'] as String?)
          .whereType<String>()
          .toSet()
          .toList()
        ..sort();
      if (mounted) {
        setState(() {
          cities = uniqueCities;
          selectedCity = null;
        });
      }
    } catch (e) {
      _showSnackBar('Error loading cities: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: GoogleFonts.poppins()),
      backgroundColor: const Color(0xFFFF6B6B),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme:
            GoogleFonts.poppinsTextTheme(), // Apply font to DatePicker
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
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget _buildModernDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFFF6B6B).withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item, style: GoogleFonts.poppins(fontSize: 16)),
          );
        }).toList(),
        onChanged: enabled ? onChanged : null,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
              color: enabled ? Colors.grey.shade700 : Colors.grey.shade500),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: enabled
                  ? const Color(0xFFFF6B6B).withOpacity(0.1)
                  : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                color:
                enabled ? const Color(0xFFFF6B6B) : Colors.grey.shade400,
                size: 20),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFFF6B6B).withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B).withOpacity(0.1),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.calendar_today,
                          color: Color(0xFFFF6B6B), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Select Date',
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF9E9E9E),
                                  fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            selectedDate != null
                                ? DateFormat('MMM dd, yyyy')
                                .format(selectedDate!)
                                : 'Choose a date',
                            style: GoogleFonts.poppins(
                              color: selectedDate != null
                                  ? const Color(0xFF2E2E2E)
                                  : const Color(0xFF9E9E9E),
                              fontSize: 16,
                              fontWeight: selectedDate != null
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (selectedDate != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                  shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.clear, color: Color(0xFFFF6B6B)),
                onPressed: () => setState(() => selectedDate = null),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCampCard(Map<String, dynamic> camp, String campName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFFF6B6B).withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    BloodCampDetailsPage(campName: campName))),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFFFF8A95), Color(0xFFFF6B6B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.local_hospital,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(campName,
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Blood Donation Camp',
                            style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.chevron_right, color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoRow(
                      Icons.location_on, 'Address', camp['address'] ?? 'N/A'),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                      Icons.phone, 'Contact', camp['phone'] ?? 'N/A'),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.person, 'Organizer',
                      camp['organizer'] ?? campName),
                  const SizedBox(height: 12),
                  if (camp['start_date'] != null && camp['end_date'] != null)
                    _buildInfoRow(Icons.calendar_today, 'Date Range',
                        '${_formatCampDate(camp['start_date'])} to ${_formatCampDate(camp['end_date'])}'),
                  if (camp['date'] != null)
                    _buildInfoRow(
                        Icons.calendar_today, 'Date', _formatCampDate(camp['date'])),
                  if (camp['time'] != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.access_time, 'Time', camp['time'])
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.1),
              shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: const Color(0xFFFF6B6B)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF9E9E9E),
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF2E2E2E),
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCampDate(String dateString) {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
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
            gradient: LinearGradient(
              colors: [Color(0xFFFF8A95), Color(0xFFFF6B6B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Live Blood Camps',
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(
          child: CircularProgressIndicator(
              valueColor:
              AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B))))
          : FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                            const Color(0xFFFF6B6B).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.filter_list,
                              color: Color(0xFFFF6B6B), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Filter Camps',
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E2E2E)),
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _buildModernDropdown(
                        label: "Select State",
                        icon: Icons.location_city,
                        value: selectedState,
                        items: states,
                        onChanged: (value) {
                          if (!mounted) return;
                          setState(() {
                            selectedState = value;
                            cities = [];
                            selectedCity = null;
                          });
                          if (value != null) {
                            fetchCitiesForState(value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildModernDropdown(
                        label: "Select City",
                        icon: Icons.location_on,
                        value: selectedCity,
                        items: cities,
                        onChanged: (value) {
                          if (!mounted) return;
                          setState(() => selectedCity = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDateSelector(),
                    ],
                  ),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bloodbanks')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                        child: Center(
                            child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Text('Error loading camps',
                                    style: GoogleFonts.poppins()))));
                  }
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const SliverFillRemaining(
                        child: Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFFF6B6B)))));
                  }

                  if (selectedState == null &&
                      selectedCity == null &&
                      selectedDate == null) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B6B)
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.search,
                                  size: 60, color: Color(0xFFFF6B6B)),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Find Blood Camps',
                              style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2E2E2E)),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select a state, city, or date to begin.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: const Color(0xFF9E9E9E)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final filtered = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final stateMatch = selectedState == null ||
                        data['state'] == selectedState;
                    final cityMatch =
                        selectedCity == null || data['city'] == selectedCity;

                    if (selectedDate == null) {
                      return stateMatch && cityMatch;
                    }

                    try {
                      if (data['start_date'] != null &&
                          data['end_date'] != null) {
                        final startDate = DateFormat('yyyy-MM-dd')
                            .parse(data['start_date']);
                        final endDate = DateFormat('yyyy-MM-dd')
                            .parse(data['end_date']);
                        return stateMatch &&
                            cityMatch &&
                            (selectedDate!.isAfter(startDate
                                .subtract(const Duration(days: 1))) &&
                                selectedDate!.isBefore(
                                    endDate.add(const Duration(days: 1))));
                      } else if (data['date'] != null) {
                        final campDate =
                        DateFormat('yyyy-MM-dd').parse(data['date']);
                        return stateMatch &&
                            cityMatch &&
                            (selectedDate!.year == campDate.year &&
                                selectedDate!.month == campDate.month &&
                                selectedDate!.day == campDate.day);
                      }
                      return false;
                    } catch (e) {
                      return false;
                    }
                  }).toList();

                  if (filtered.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B6B)
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.event_busy,
                                  size: 60, color: Color(0xFFFF6B6B)),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No active camps found',
                              style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2E2E2E)),
                            ),
                            const SizedBox(height: 8),
                            if (selectedDate != null)
                              Text(
                                'for ${DateFormat('MMM dd, yyyy').format(selectedDate!)}',
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: const Color(0xFF9E9E9E)),
                              ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                if (!mounted) return;
                                setState(() {
                                  selectedState = null;
                                  selectedCity = null;
                                  selectedDate = null;
                                  cities = [];
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6B6B),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(25)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 16),
                                  elevation: 5,
                                  shadowColor: const Color(0xFFFF6B6B)
                                      .withOpacity(0.3)),
                              child: Text(
                                "Clear Filters",
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final camp =
                          filtered[index].data() as Map<String, dynamic>;
                          final campName = camp['name'] ?? 'Blood Camp';
                          return _buildCampCard(camp, campName);
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}