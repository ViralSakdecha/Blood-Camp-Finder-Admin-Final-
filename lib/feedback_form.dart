import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart'; // 👈 Import Google Fonts

class FeedbackForm extends StatefulWidget {
  final String campName;
  const FeedbackForm({required this.campName, super.key});

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();

  String? _userEmail;
  String? _userName;
  bool _isLoading = true;
  bool _isSubmitting = false;

  final List<String> _feedbackCategories = [
    'Staff Service',
    'Facility Cleanliness',
    'Wait Time',
    'Overall Experience'
  ];
  final Map<String, int> _categoryRatings = {};

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchUserData();
    for (var category in _feedbackCategories) {
      _categoryRatings[category] = 0;
    }
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
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
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _userEmail = user.email;
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          _userName = userDoc.data()?['name'] ?? 'User';
        }
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      _showSnackBar('Error fetching user data. Please try again.',
          isError: true);
      Navigator.pop(context);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()), // 👈 Applied font
        backgroundColor: isError ? const Color(0xFFFF6B6B) : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    bool hasRatedSomething =
    _categoryRatings.values.any((rating) => rating > 0);
    if (!hasRatedSomething) {
      _showSnackBar('Please provide at least one rating', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final feedbackData = {
        'campName': widget.campName,
        'userDetails': {
          'email': _userEmail,
          'name': _userName,
          'userId': FirebaseAuth.instance.currentUser?.uid,
        },
        'ratings': {
          'overallExperience': _categoryRatings['Overall Experience'],
          'staffService': _categoryRatings['Staff Service'],
          'cleanliness': _categoryRatings['Facility Cleanliness'],
          'waitTime': _categoryRatings['Wait Time'],
        },
        'comments': _commentController.text.trim(),
        'submittedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'appVersion': '1.0.0',
          'platform': kIsWeb ? 'web' : Platform.operatingSystem,
        },
      };

      await FirebaseFirestore.instance
          .collection('campFeedbacks')
          .add(feedbackData);

      if (!mounted) return;
      _showSnackBar('Thank you for your feedback!');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to submit feedback. Please try again.',
          isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildRatingBar(int rating, Function(int) onChanged,
      {double size = 36,
        MainAxisAlignment alignment = MainAxisAlignment.center}) {
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          constraints: const BoxConstraints(),
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: const Color(0xFFFF6B6B),
            size: size,
          ),
          onPressed: () => onChanged(index + 1),
        );
      }),
    );
  }

  Widget _buildCategoryRating(String category) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              category,
              style: GoogleFonts.poppins( // 👈 Applied font
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2E2E2E),
              ),
            ),
          ),
          _buildRatingBar(
            _categoryRatings[category] ?? 0,
                (rating) => setState(() => _categoryRatings[category] = rating),
            size: 28,
            alignment: MainAxisAlignment.end,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
            ),
            const SizedBox(height: 16),
            Text(
              "Loading feedback form...",
              style: GoogleFonts.poppins( // 👈 Applied font
                color: const Color(0xFF9E9E9E),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Give Feedback',
          style: GoogleFonts.poppins( // 👈 Applied font
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rate Your Experience At',
                    style: GoogleFonts.poppins( // 👈 Applied font
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E2E2E),
                    ),
                  ),
                  Text(
                    widget.campName,
                    style: GoogleFonts.poppins( // 👈 Applied font
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF6B6B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ..._feedbackCategories.map(_buildCategoryRating),
                  const SizedBox(height: 24),
                  Text(
                    'Additional Comments (Optional)',
                    style: GoogleFonts.poppins( // 👈 Applied font
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E2E2E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _commentController,
                    maxLines: 5,
                    style: GoogleFonts.poppins(), // 👈 Applied font to input text
                    decoration: InputDecoration(
                      hintText: 'Your feedback helps us improve...',
                      hintStyle: GoogleFonts.poppins(), // 👈 Applied font to hint text
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFFFF6B6B),
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
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
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                          : Text(
                        'Submit Feedback',
                        style: GoogleFonts.poppins( // 👈 Applied font
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}