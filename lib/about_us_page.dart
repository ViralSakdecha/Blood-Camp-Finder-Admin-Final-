// lib/about_us_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // 👈 Import Google Fonts
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static bool _hasAnimatedOnce = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    if (!_hasAnimatedOnce) {
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
      _fadeController = AnimationController(vsync: this, value: 1.0);
      _slideController = AnimationController(vsync: this, value: 1.0);
    }

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url', style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
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
        title: Text(
          "About Us",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
                          Icons.favorite,
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
                              "Blood Camp Finder",
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Connecting donors with those in need",
                              style: GoogleFonts.poppins(
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

                _buildModernCard(
                  icon: Icons.track_changes,
                  title: "Our Mission",
                  subtitle: "Making blood donation accessible",
                  content:
                  "Our mission is to bridge the gap between blood donors and those in need. We aim to create a unified platform where users can find nearby blood banks, participate in donation camps, and help save lives with just a few taps.",
                ),

                const SizedBox(height: 20),

                Text(
                  "Meet Our Team",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "The developers behind the project",
                  style: GoogleFonts.poppins(fontSize: 16, color: const Color(0xFF9E9E9E)),
                ),
                const SizedBox(height: 20),

                ...teamMembers.map((member) => _buildTeamMemberCard(member)),

                const SizedBox(height: 20),

                _buildModernCard(
                  icon: Icons.location_on,
                  title: "Our Headquarters",
                  subtitle: "Based in Gujarat, India",
                  content: "Rajkot, Gujarat, India",
                ),

                const SizedBox(height: 20),

                _buildModernCard(
                  icon: Icons.alternate_email,
                  title: "Get In Touch",
                  subtitle: "Contact us for support",
                  content: "Email: bloodeveryone@gmail.com",
                ),

                const SizedBox(height: 32),

                _buildCallToActionSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  content,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: const Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberCard(Map<String, dynamic> member) {
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
      child: InkWell(
        onTap: () => _showTeamMemberDialog(member),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
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
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E2E2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member['role'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFFFF6B6B),
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallToActionSection() {
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
                  Icons.volunteer_activism,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "Join Our Mission",
                  style: GoogleFonts.poppins(
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
            "Together, we can save lives and make a difference in our community. Every donation counts, every camp matters, and every life saved is precious.",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showTeamMemberDialog(Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF8A95), Color(0xFFFF6B6B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    member['role'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Student ID: ${member['id']}",
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              "Connect with me:",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialButton(
                  icon: Icons.email,
                  label: "Email",
                  color: Colors.red,
                  onTap: () => _launchURL(member['email']),
                ),
                _buildSocialButton(
                  icon: Icons.link,
                  label: "LinkedIn",
                  color: Colors.blue,
                  onTap: () => _launchURL(member['linkedin']),
                ),
                _buildSocialButton(
                  icon: Icons.code,
                  label: "GitHub",
                  color: Colors.black,
                  onTap: () => _launchURL(member['github']),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: GoogleFonts.poppins(
                color: const Color(0xFFFF6B6B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<Map<String, dynamic>> teamMembers = [
    {
      'name': 'Viral Sakdecha',
      'role': 'Lead Developer',
      'id': '23020201139',
      'email': 'mailto:viral.sakdecha@gmail.com',
      'linkedin': "https://www.linkedin.com/in/viralsakdecha/",
      'github': 'https://github.com/viralsakdecha',
    },
    {
      'name': 'Dhrumil Dashadia',
      'role': 'Full Stack Developer',
      'id': '23020201038',
      'email': 'mailto:dhrumil1411@gmail.com',
      'linkedin': 'https://www.linkedin.com/in/dhrumil-dashadia-43903a30a/',
      'github': "https://github.com/Dhrumil1411",
    },
    {
      'name': 'Sinhal Joshi',
      'role': 'UI/UX Designer & Developer',
      'id': '23020201071',
      'email': 'mailto:sinhalz4772@gmail.com',
      'linkedin': 'https://www.linkedin.com/in/sinhal-joshi-244603275/',
      'github': 'https://github.com/Zephyr4772',
    },
  ];
}