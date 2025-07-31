import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // 👈 Import Google Fonts

class CampDetailsPage extends StatefulWidget {
  final String title;
  const CampDetailsPage({required this.title, super.key});

  @override
  _CampDetailsPageState createState() => _CampDetailsPageState();
}

class _CampDetailsPageState extends State<CampDetailsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Camp Details",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold), // 👈 Applied font
        ),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.poppins( // 👈 Applied font
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailCard("📍 Venue", "Rajkot City Center"),
                _buildDetailCard("📅 Date", "2025-07-10"),
                _buildDetailCard("🩸 Blood Types Needed", "A+, B+, O+"),
                const SizedBox(height: 30),
                _buildInfoText(
                  "🤝 Organized by: Indian Red Cross Society",
                  Colors.red.shade200,
                ),
                const SizedBox(height: 10),
                _buildInfoText(
                  "ℹ️ Please carry a valid ID proof. Avoid donating on an empty stomach. Drink plenty of water!",
                  Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade50,
            Colors.red.shade100.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade100.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        "$label: $value",
        style: GoogleFonts.poppins( // 👈 Applied font
            fontSize: 18, color: const Color(0xFF2E2E2E)),
      ),
    );
  }

  Widget _buildInfoText(String text, Color color) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontSize: 16, color: color), // 👈 Applied font
    );
  }
}