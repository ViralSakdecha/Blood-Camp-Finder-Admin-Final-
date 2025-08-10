import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class BloodInfoPage extends StatefulWidget {
  const BloodInfoPage({super.key});

  @override
  _BloodInfoPageState createState() => _BloodInfoPageState();
}

class _BloodInfoPageState extends State<BloodInfoPage>
    with TickerProviderStateMixin {
  String? selectedBloodType;
  bool showCompatibilityChart = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final Map<String, dynamic> bloodData = {
    'A+': {
      'canDonateTo': ['A+', 'AB+'],
      'canReceiveFrom': ['A+', 'A-', 'O+', 'O-'],
      'populationPercent': 34,
      'info':
      'A+ is one of the most common blood types. Contains A antigens and Rh factor.',
      'color': Colors.red.shade400,
      'emergencyInfo':
      'High demand blood type. Regularly needed for trauma patients.',
      'medicalFacts': [
        'Contains A antigens on red blood cells',
        'Has Rh factor (positive)',
        'Most common blood type in many populations',
        'Safe for A+ and AB+ recipients',
      ],
      'donationFrequency': 'Every 8 weeks',
      'storageLife': '42 days refrigerated',
    },
    'A-': {
      'canDonateTo': ['A+', 'A-', 'AB+', 'AB-'],
      'canReceiveFrom': ['A-', 'O-'],
      'populationPercent': 6,
      'info': 'A- is less common and highly valuable for donations.',
      'color': Colors.red.shade300,
      'emergencyInfo': 'Critical for A- and AB- patients. High demand.',
      'medicalFacts': [
        'Contains A antigens, no Rh factor',
        'Compatible with both A+ and A- recipients',
        'Rare and valuable blood type',
        'Safe for emergency transfusions to A types',
      ],
      'donationFrequency': 'Every 8 weeks',
      'storageLife': '42 days refrigerated',
    },
    'B+': {
      'canDonateTo': ['B+', 'AB+'],
      'canReceiveFrom': ['B+', 'B-', 'O+', 'O-'],
      'populationPercent': 8,
      'info': 'B+ can donate to B+ and AB+. Fairly rare globally.',
      'color': Colors.blue.shade400,
      'emergencyInfo': 'Needed for B+ and AB+ patients. Moderate demand.',
      'medicalFacts': [
        'Contains B antigens and Rh factor',
        'Compatible with B+ and AB+ recipients',
        'Less common than A and O types',
        'Important for specific patient groups',
      ],
      'donationFrequency': 'Every 8 weeks',
      'storageLife': '42 days refrigerated',
    },
    'B-': {
      'canDonateTo': ['B+', 'B-', 'AB+', 'AB-'],
      'canReceiveFrom': ['B-', 'O-'],
      'populationPercent': 2,
      'info': 'B- is rare and valuable for transfusions.',
      'color': Colors.blue.shade300,
      'emergencyInfo': 'Very rare. Critical for B- and AB- patients.',
      'medicalFacts': [
        'Contains B antigens, no Rh factor',
        'Very rare blood type',
        'Critical for emergency situations',
        'Can donate to all B and AB types',
      ],
      'donationFrequency': 'Every 8 weeks',
      'storageLife': '42 days refrigerated',
    },
    'AB+': {
      'canDonateTo': ['AB+'],
      'canReceiveFrom': ['Everyone'],
      'populationPercent': 3,
      'info':
      'AB+ is the universal recipient. Can receive from all blood types.',
      'color': Colors.purple.shade400,
      'emergencyInfo': 'Universal plasma donor. Rare but versatile.',
      'medicalFacts': [
        'Contains both A and B antigens',
        'Universal recipient for red blood cells',
        'Universal plasma donor',
        'Rarest of the positive blood types',
      ],
      'donationFrequency': 'Every 8 weeks',
      'storageLife': '42 days refrigerated',
    },
    'AB-': {
      'canDonateTo': ['AB+', 'AB-'],
      'canReceiveFrom': ['A-', 'B-', 'AB-', 'O-'],
      'populationPercent': 1,
      'info': 'AB- is extremely rare and valuable.',
      'color': Colors.purple.shade300,
      'emergencyInfo': 'Extremely rare. Universal plasma donor.',
      'medicalFacts': [
        'Contains A and B antigens, no Rh factor',
        'Rarest blood type',
        'Universal plasma donor',
        'Critical for AB- patients',
      ],
      'donationFrequency': 'Every 8 weeks',
      'storageLife': '42 days refrigerated',
    },
    'O+': {
      'canDonateTo': ['O+', 'A+', 'B+', 'AB+'],
      'canReceiveFrom': ['O+', 'O-'],
      'populationPercent': 39,
      'info':
      'O+ is the most common blood type. Universal donor for all Rh+ types.',
      'color': Colors.orange.shade400,
      'emergencyInfo': 'Most common type. High demand in emergencies.',
      'medicalFacts': [
        'No A or B antigens',
        'Contains Rh factor',
        'Most common blood type worldwide',
        'Universal donor for Rh+ recipients',
      ],
      'donationFrequency': 'Every 8 weeks',
      'storageLife': '42 days refrigerated',
    },
    'O-': {
      'canDonateTo': ['Everyone'],
      'canReceiveFrom': ['O-'],
      'populationPercent': 7,
      'info': 'O- is the universal donor. Can donate to all blood types.',
      'color': Colors.orange.shade600,
      'emergencyInfo':
      'Universal donor. Critical for all emergency situations.',
      'medicalFacts': [
        'No A, B, or Rh antigens',
        'Universal donor for all blood types',
        'Most needed in emergency rooms',
        'Only 7% of population has this type',
      ],
      'donationFrequency': 'Every 8 weeks',
      'storageLife': '42 days refrigerated',
    },
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _selectBloodType(String type) {
    setState(() {
      selectedBloodType = type;
    });
    _animationController.reset();
    _animationController.forward();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Blood Type Information",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red.shade200,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showInfoDialog(),
          ),
        ],
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderSection(),
            _buildBloodTypeGrid(),
            if (selectedBloodType != null) ...[
              _buildSelectedTypeHeader(),
              _buildDetailCards(),
              _buildCompatibilitySection(),
              _buildDonationInfo(),
            ],
            _buildGeneralInfo(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF8A95), Color(0xFFFF6B6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.bloodtype, size: 60, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              "Discover Your Blood Type",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            // ✨ LINE REMOVED FROM HERE
          ],
        ),
      ),
    );
  }

  Widget _buildBloodTypeGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Your Blood Type",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: bloodData.keys.length,
            itemBuilder: (context, index) {
              String type = bloodData.keys.elementAt(index);
              bool isSelected = selectedBloodType == type;
              return _buildBloodTypeCard(type, isSelected);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBloodTypeCard(String type, bool isSelected) {
    final data = bloodData[type]!;
    return GestureDetector(
      onTap: () => _selectBloodType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [data['color'], data['color'].withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [Colors.white, Colors.grey.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? data['color'] : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: data['color'].withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              type,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${data['populationPercent']}%",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isSelected
                    ? Colors.white.withOpacity(0.8)
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTypeHeader() {
    final data = bloodData[selectedBloodType]!;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [data['color'], data['color'].withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: data['color'].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.bloodtype, size: 40, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Blood Type $selectedBloodType",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${data['populationPercent']}% of population",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
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

  Widget _buildDetailCards() {
    final data = bloodData[selectedBloodType]!;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoCard(
              "Medical Information",
              Icons.medical_information,
              data['info'],
              Colors.blue.shade600,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              "Emergency Info",
              Icons.emergency,
              data['emergencyInfo'],
              Colors.red.shade600,
            ),
            const SizedBox(height: 12),
            _buildMedicalFactsCard(data['medicalFacts']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      String title,
      IconData icon,
      String content,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalFactsCard(List<String> facts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.science,
                  color: Colors.green.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Medical Facts",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...facts.map(
                (fact) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fact,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
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

  Widget _buildCompatibilitySection() {
    final data = bloodData[selectedBloodType]!;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Blood Compatibility",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 16),
              _buildCompatibilityRow(
                "Can Donate To",
                data['canDonateTo'],
                Icons.volunteer_activism,
                Colors.green.shade600,
              ),
              const SizedBox(height: 12),
              _buildCompatibilityRow(
                "Can Receive From",
                data['canReceiveFrom'],
                Icons.arrow_downward,
                Colors.blue.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompatibilityRow(
      String title,
      List<dynamic> types,
      IconData icon,
      Color color,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: types
                    .map(
                      (type) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Text(
                      type.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDonationInfo() {
    final data = bloodData[selectedBloodType]!;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Donation Information",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 16),
              _buildDonationInfoRow(
                "Donation Frequency",
                data['donationFrequency'],
                Icons.schedule,
              ),
              const SizedBox(height: 12),
              _buildDonationInfoRow(
                "Storage Life",
                data['storageLife'],
                Icons.storage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDonationInfoRow(String title, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.orange.shade600, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade800),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 8),
                Text(
                  "Did You Know?",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "• One blood donation can save up to 3 lives\n"
                  "• O- donors are called universal donors\n"
                  "• AB+ recipients can receive any blood type\n"
                  "• Blood donation is completely safe and takes about 8-10 minutes\n"
                  "• Your body replaces donated blood within 24-48 hours",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.blue.shade700,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("About Blood Types", style: GoogleFonts.poppins()),
          content: SingleChildScrollView(
            child: Text(
              "Blood types are determined by the presence or absence of certain antigens on red blood cells. "
                  "The ABO system (A, B, AB, O) and Rh factor (+ or -) are the most important for transfusions.\n\n"
                  "Understanding your blood type is crucial for:\n"
                  "• Safe blood transfusions\n"
                  "• Organ transplants\n"
                  "• Pregnancy planning\n"
                  "• Medical emergencies\n\n"
                  "Regular blood donation helps maintain blood supplies and can save lives in emergencies.",
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Got it", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }
}