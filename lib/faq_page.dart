import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // 👈 Import Google Fonts

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> with TickerProviderStateMixin {
  int? _expandedIndex;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Static flag for one-time animation per session
  static bool _hasAnimatedOnce = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    if (!_hasAnimatedOnce) {
      // First visit: Animate normally
      _fadeController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      );
      _slideController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      );
      _fadeController.forward();
      _slideController.forward();
      _hasAnimatedOnce = true;
    } else {
      // Subsequent visits: Show content immediately
      _fadeController = AnimationController(vsync: this, value: 1.0);
      _slideController = AnimationController(vsync: this, value: 1.0);
    }

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
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
        title: Text(
          "FAQs & Blood Donation Guide",
          style: GoogleFonts.poppins(
            // 👈 Applied font
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: () {
                _showInfoDialog();
              },
              tooltip: 'More Info',
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8A95), Color(0xFFFF6B6B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.quiz_outlined,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Got Questions?",
                              style: GoogleFonts.poppins(
                                // 👈 Applied font
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Everything you need to know about blood donation",
                              style: GoogleFonts.poppins(
                                // 👈 Applied font
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "Frequently Asked Questions",
                  style: GoogleFonts.poppins(
                    // 👈 Applied font
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tap on any question to learn more",
                  style: GoogleFonts.poppins(
                    // 👈 Applied font
                    fontSize: 16,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
                const SizedBox(height: 24),

                // FAQ Items
                ...faqData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final faq = entry.value;
                  return _buildFAQItem(faq, index);
                }),

                const SizedBox(height: 32),

                // Emergency Contact Card
                _buildEmergencyCard(),

                const SizedBox(height: 24),

                // Tips Section
                _buildTipsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> faq, int index) {
    final isExpanded = _expandedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedIndex = isExpanded ? null : index;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isExpanded
                            ? [const Color(0xFFFF8A95), const Color(0xFFFF6B6B)]
                            : [
                          const Color(0xFFFF6B6B).withOpacity(0.1),
                          const Color(0xFFFF6B6B).withOpacity(0.1)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      faq['icon'] as IconData,
                      color:
                      isExpanded ? Colors.white : const Color(0xFFFF6B6B),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          faq['question'] as String,
                          style: GoogleFonts.poppins(
                            // 👈 Applied font
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isExpanded
                                ? const Color(0xFFFF6B6B)
                                : const Color(0xFF2E2E2E),
                          ),
                        ),
                        if (faq['subtitle'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            faq['subtitle'] as String,
                            style: GoogleFonts.poppins(
                              // 👈 Applied font
                              fontSize: 14,
                              color: const Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFFFF6B6B),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 1,
                    margin: const EdgeInsets.only(bottom: 16),
                    color: const Color(0xFFFF6B6B).withOpacity(0.2),
                  ),
                  Text(
                    faq['answer'] as String,
                    style: GoogleFonts.poppins(
                      // 👈 Applied font
                      fontSize: 15,
                      color: const Color(0xFF666666),
                      height: 1.5,
                    ),
                    // ✨ FIX APPLIED HERE
                    textAlign: TextAlign.justify,
                  ),
                  if (faq['tips'] != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color:
                              const Color(0xFFFF6B6B).withOpacity(0.1))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                color: Color(0xFFFF6B6B),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Pro Tips:",
                                style: GoogleFonts.poppins(
                                  // 👈 Applied font
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFF6B6B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...(faq['tips'] as List<String>).map(
                                (tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "• ",
                                    style: GoogleFonts.poppins(
                                      // 👈 Applied font
                                      color: const Color(0xFFFF6B6B),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: GoogleFonts.poppins(
                                        // 👈 Applied font
                                        fontSize: 14,
                                        color: const Color(0xFF666666),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF8A95), Color(0xFFFF6B6B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emergency,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Emergency Blood Request",
                      style: GoogleFonts.poppins(
                        // 👈 Applied font
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E2E2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Need blood urgently? Contact these numbers",
                      style: GoogleFonts.poppins(
                        // 👈 Applied font
                        fontSize: 14,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "National Helpline",
                        style: GoogleFonts.poppins(
                          // 👈 Applied font
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF6B6B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "1910",
                        style: GoogleFonts.poppins(
                          // 👈 Applied font
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E2E2E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Blood Bank",
                        style: GoogleFonts.poppins(
                          // 👈 Applied font
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF6B6B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "104",
                        style: GoogleFonts.poppins(
                          // 👈 Applied font
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E2E2E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8A95), Color(0xFFFF6B6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "Be a Hero, Save Lives",
                  style: GoogleFonts.poppins(
                    // 👈 Applied font
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Every blood donation can save up to 3 lives. Your contribution makes a difference in someone's life. Thank you for being a hero!",
            style: GoogleFonts.poppins(
              // 👈 Applied font
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline,
                color: Color(0xFFFF6B6B),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "About Blood Donation",
              style: GoogleFonts.poppins(
                // 👈 Applied font
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          "Blood donation is a voluntary procedure that can help save lives. Donated blood is used for transfusions and for manufacturing medicines. Every unit of blood donated can save up to 3 lives.",
          style: GoogleFonts.poppins(fontSize: 16, height: 1.5), // 👈 Applied font
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Got it",
              style: GoogleFonts.poppins(
                // 👈 Applied font
                color: const Color(0xFFFF6B6B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const List<Map<String, dynamic>> faqData = [
    {
      'icon': Icons.person_outline,
      'question': 'Who can donate blood?',
      'subtitle': 'Eligibility criteria',
      'answer':
      'Anyone aged 18–65 years old, in good health, and weighing at least 50kg (110 lbs) can donate blood. You should not have any infections, chronic conditions, or be taking certain medications that could affect your health or the safety of the blood supply.',
      'tips': [
        'Must be in good general health',
        'No fever or illness in the past 2 weeks',
        'Not pregnant or breastfeeding',
        'No recent tattoos or piercings (varies by location)',
      ],
    },
    {
      'icon': Icons.schedule,
      'question': 'How often can I donate blood?',
      'subtitle': 'Donation frequency',
      'answer':
      'Males can donate every 3 months (12 weeks), while females can donate every 4 months (16 weeks). This interval allows your body enough time to replenish the red blood cells and maintain healthy iron levels.',
      'tips': [
        'Males: Every 12 weeks (4 times per year)',
        'Females: Every 16 weeks (3 times per year)',
        'Platelet donors can donate every 2 weeks',
        'Plasma donors can donate twice per week',
      ],
    },
    {
      'icon': Icons.restaurant,
      'question': 'What should I do before donating?',
      'subtitle': 'Pre-donation preparation',
      'answer':
      'Stay well-hydrated by drinking plenty of water, eat a light nutritious meal 2-3 hours before donating, get adequate sleep the night before, and avoid alcohol for 24 hours prior to donation. Also, bring a valid ID and list of medications.',
      'tips': [
        'Drink 16-20 oz of water before donating',
        'Eat iron-rich foods like spinach, beans, red meat',
        'Get 7-8 hours of sleep the night before',
        'Wear comfortable clothing with sleeves that can be rolled up',
      ],
    },
    {
      'icon': Icons.security,
      'question': 'Is blood donation safe?',
      'subtitle': 'Safety measures',
      'answer':
      'Yes, blood donation is completely safe. All equipment is sterile, single-use, and disposed of after each donation. The donation process is conducted by trained medical professionals in a clean, controlled environment following strict safety protocols.',
      'tips': [
        'All needles and tubes are sterile and single-use',
        'Professional medical staff oversee the process',
        'Strict screening procedures are followed',
        'Less than 1% of donors experience any complications',
      ],
    },
    {
      'icon': Icons.timer,
      'question': 'How long does the donation process take?',
      'subtitle': 'Time commitment',
      'answer':
      'The entire process typically takes 45-60 minutes, including registration, health screening, mini-physical, donation, and recovery time. The actual blood collection usually takes only 8-10 minutes.',
      'tips': [
        'Registration: 5-10 minutes',
        'Health screening: 10-15 minutes',
        'Actual donation: 8-10 minutes',
        'Recovery and refreshments: 15-20 minutes',
      ],
    },
    {
      'icon': Icons.science,
      'question': 'What happens to my blood after donation?',
      'subtitle': 'Blood processing',
      'answer':
      'Your blood is tested for safety, processed into different components (red cells, plasma, platelets), and distributed to hospitals where it can help save up to three lives. Each component serves different medical purposes.',
      'tips': [
        'Tested for infectious diseases',
        'Separated into red cells, plasma, and platelets',
        'Stored at specific temperatures',
        'Distributed to hospitals within 2-3 days',
      ],
    },
    {
      'icon': Icons.health_and_safety,
      'question': 'Are there any side effects?',
      'subtitle': 'Post-donation care',
      'answer':
      'Most people experience no side effects. Some may feel slightly dizzy, tired, or have minor bruising at the needle site. These effects are temporary and usually resolve within a few hours to a day.',
      'tips': [
        'Drink plenty of fluids after donation',
        'Avoid heavy lifting for 24 hours',
        'Keep the bandage on for at least 4 hours',
        'Contact the blood center if you feel unwell',
      ],
    },
    {
      'icon': Icons.colorize,
      'question': 'Can I donate if I have tattoos or piercings?',
      'subtitle': 'Tattoo and piercing policies',
      'answer':
      'Yes, you can donate if your tattoos or piercings were done at a licensed, regulated facility using sterile equipment. There may be a waiting period of 3-12 months depending on when they were done and local regulations.',
      'tips': [
        'Must be done at a licensed facility',
        'Waiting period varies by location',
        'Bring documentation if available',
        'Temporary tattoos are usually not a concern',
      ],
    },
    {
      'icon': Icons.local_hospital,
      'question': 'What blood types are needed most?',
      'subtitle': 'Blood type demand',
      'answer':
      'O-negative blood is the universal donor type and is always in high demand. However, all blood types are needed. AB-positive is the universal plasma donor, while O-positive is the most common blood type.',
      'tips': [
        'O-negative: Universal red blood cell donor',
        'AB-positive: Universal plasma donor',
        'Type O blood is used in emergencies',
        'Rare blood types are especially valuable',
      ],
    },
  ];
}