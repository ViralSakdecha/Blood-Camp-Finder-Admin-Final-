import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart'; // 👈 Import Google Fonts
import 'feedback_form.dart';

class BloodCampDetailsPage extends StatelessWidget {
  final String campName;

  const BloodCampDetailsPage({super.key, required this.campName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        title: Text(
          "Blood Camp Details",
          style: GoogleFonts.poppins( // 👈 Applied font
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('bloodbanks')
            .where('name', isEqualTo: campName)
            .limit(1)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Camp not found.'));
          }

          final camp =
          snapshot.data!.docs.first.data() as Map<String, dynamic>;

          final name = camp['name'] ?? 'Not available';
          final organizer = camp['organized_by'] ?? 'Not available';
          final address = camp['address'] ?? 'Not available';
          final phone = camp['phone'] ?? 'Not available';
          final city = camp['city'] ?? 'N/A';
          final state = camp['state'] ?? 'N/A';
          final startDate = camp['start_date'] ?? 'N/A';
          final endDate = camp['end_date'] ?? 'N/A';
          final hours = camp['hours_active'] ?? 'N/A';
          final bloodTypes =
              (camp['blood_required'] as List<dynamic>?)?.join(', ') ?? 'N/A';
          final isCamp = camp['is_blood_camp'] == true;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.bloodtype,
                          color: Color(0xFFFF6B6B), size: 60),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        style: GoogleFonts.poppins( // 👈 Applied font
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildDetailTile(Icons.group, 'Organizer', organizer),
                _buildDetailTile(Icons.location_on, 'Address', address),
                _buildDetailTile(Icons.phone, 'Contact Number', phone),
                _buildDetailTile(Icons.location_city, 'City', city),
                _buildDetailTile(Icons.map, 'State', state),
                _buildDetailTile(Icons.calendar_today, 'Start Date', startDate),
                _buildDetailTile(
                  Icons.calendar_today_outlined,
                  'End Date',
                  endDate,
                ),
                _buildDetailTile(Icons.access_time, 'Hours Active', hours),
                _buildDetailTile(
                  Icons.bloodtype_outlined,
                  'Blood Required',
                  bloodTypes,
                ),
                _buildDetailTile(
                  Icons.event,
                  'Camp Type',
                  isCamp ? 'Blood Donation Camp' : 'Permanent Blood Bank',
                ),
                const SizedBox(height: 30),
                if (isCamp) const SizedBox(height: 20),
                // Styled Feedback Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8A95), Color(0xFFFF6B6B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FeedbackForm(campName: campName),
                        ),
                      );
                    },
                    icon: const Icon(Icons.feedback_outlined,
                        color: Colors.white),
                    label: Text(
                      "Give Feedback",
                      style: GoogleFonts.poppins( // 👈 Applied font
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFF6B6B), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins( // 👈 Applied font
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins( // 👈 Applied font
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Divider(color: Colors.grey.shade300),
              ],
            ),
          ),
        ],
      ),
    );
  }
}