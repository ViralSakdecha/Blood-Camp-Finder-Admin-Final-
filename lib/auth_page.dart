import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bottom_nav_screen.dart';

class AuthPage extends StatefulWidget {
  final ValueNotifier<ThemeMode>? themeNotifier;
  const AuthPage({super.key, this.themeNotifier});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  // Common Controllers & State
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late PageController _pageController;
  int _currentPage = 0;
  bool isLoading = false;

  // Animation Controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Login Controllers
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  bool _obscureLoginPassword = true;

  // Register Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerPasswordController =
  TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Register State
  bool _obscureRegisterPassword = true;
  bool _obscureConfirmPassword = true;
  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedBloodGroup;
  // ✨ OPTIMIZATION: Made static lists const for performance.
  static const List<String> _genderOptions = ['Male', 'Female', 'Other'];
  static const List<String> _bloodGroupOptions = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Main page animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    _animationController.forward();

    // Listener for phone number length
    phoneController.addListener(() {
      if (phoneController.text.length > 10) {
        phoneController.text = phoneController.text.substring(0, 10);
        phoneController.selection = TextSelection.fromPosition(
          TextPosition(offset: phoneController.text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    nameController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    confirmPasswordController.dispose();
    dobController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // --- Utility & Helper Methods ---

  Future<bool> _isConnected() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onTabTapped(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // --- Login Logic ---

  Future<void> loginUser() async {
    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill in all fields");
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(email)) {
      _showSnackBar("Enter a valid email address");
      return;
    }

    setState(() => isLoading = true);

    try {
      if (!await _isConnected()) {
        throw FirebaseAuthException(
          code: 'network-request-failed',
          message: 'No internet connection',
        );
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = switch (e.code) {
        'user-not-found' => "No account found with this email.",
        'wrong-password' => "Incorrect password.",
        'invalid-email' => "Invalid email format.",
        'user-disabled' => "This account has been disabled.",
        'network-request-failed' => "No internet connection.",
        _ => "Login failed: ${e.message ?? 'Unknown error'}",
      };
      _showSnackBar(errorMessage);
    } catch (e) {
      _showSnackBar("An unexpected error occurred");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- Registration Logic ---

  Future<void> _selectDate(BuildContext context) async {
    final eighteenYearsAgo = DateTime(
      DateTime.now().year - 18,
      DateTime.now().month,
      DateTime.now().day,
    );
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? eighteenYearsAgo,
      firstDate: DateTime(1900),
      lastDate: eighteenYearsAgo,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6B6B),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        dobController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  bool _validatePhoneNumber(String phone) {
    if (phone.isEmpty) return false;
    if (phone.length != 10) return false;
    return RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
  }

  Future<void> registerUser() async {
    if (nameController.text.trim().isEmpty ||
        registerEmailController.text.trim().isEmpty ||
        registerPasswordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty ||
        _selectedGender == null ||
        _selectedDate == null ||
        phoneController.text.trim().isEmpty ||
        _selectedBloodGroup == null ||
        addressController.text.trim().isEmpty) {
      _showSnackBar("All fields are required");
      return;
    }

    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
    ).hasMatch(registerEmailController.text.trim())) {
      _showSnackBar("Enter a valid email address");
      return;
    }

    final eighteenYearsAgo = DateTime(
      DateTime.now().year - 18,
      DateTime.now().month,
      DateTime.now().day,
    );
    if (_selectedDate!.isAfter(eighteenYearsAgo)) {
      _showSnackBar('You must be at least 18 years old to register.');
      return;
    }

    if (!_validatePhoneNumber(phoneController.text.trim())) {
      _showSnackBar(
        "Please enter a valid 10-digit Indian phone number starting with 6-9",
      );
      return;
    }

    if (registerPasswordController.text.length < 6) {
      _showSnackBar("Password must be at least 6 characters");
      return;
    }

    if (registerPasswordController.text != confirmPasswordController.text) {
      _showSnackBar("Passwords do not match");
      return;
    }

    setState(() => isLoading = true);

    try {
      if (!await _isConnected()) {
        throw FirebaseAuthException(
          code: 'network-request-failed',
          message: 'No internet connection',
        );
      }

      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: registerEmailController.text.trim(),
        password: registerPasswordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'email': registerEmailController.text.trim(),
        'name': nameController.text.trim(),
        'gender': _selectedGender,
        'dob': Timestamp.fromDate(_selectedDate!),
        'phone': phoneController.text.trim(),
        'bloodGroup': _selectedBloodGroup,
        'address': addressController.text.trim(),
        'created_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = switch (e.code) {
        'email-already-in-use' => "An account with this email already exists.",
        'invalid-email' => "Invalid email format.",
        'weak-password' => "Password is too weak.",
        'network-request-failed' => "No internet connection.",
        _ => "Registration failed: ${e.message ?? 'Unknown error'}",
      };
      _showSnackBar(errorMessage);
    } catch (e) {
      _showSnackBar("An unexpected error occurred");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- UI Builder Widgets ---

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    int maxLines = 1,
  }) {
    // ✨ OPTIMIZATION: Extracted box decoration to a constant.
    const boxDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(16)),
      boxShadow: [
        BoxShadow(
          color: Color.fromRGBO(255, 107, 107, 0.1),
          blurRadius: 15,
          offset: Offset(0, 5),
        ),
      ],
    );

    return Container(
      decoration: boxDecoration,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: const Color(0xFF2E2E2E),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFFF6B6B), size: 20),
          ),
          suffixIcon: suffixIcon,
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
            borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
        ),
      ),
    );
  }

  Widget _buildModernDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    IconData? icon,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey.shade500,
          fontSize: 16,
        ),
        prefixIcon: icon != null
            ? Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B6B).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFFFF6B6B), size: 20),
        )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
        ),
      ),
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item,
            style: GoogleFonts.poppins(
              color: const Color(0xFF2E2E2E),
              fontSize: 16,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
      style: GoogleFonts.poppins(color: const Color(0xFF2E2E2E), fontSize: 16),
    );
  }

  Widget _buildAuthToggle() {
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => _onTabTapped(0),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 500),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: _currentPage == 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _currentPage == 0
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFF9E9E9E),
                  ),
                  child: const Text("Login"),
                ),
              ),
              GestureDetector(
                onTap: () => _onTabTapped(1),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 500),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: _currentPage == 1
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _currentPage == 1
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFF9E9E9E),
                  ),
                  child: const Text("Register"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedAlign(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: _currentPage == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              width: 100, // Half the width of the parent container
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF8A95), Color(0xFFFF6B6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.bloodtype,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _currentPage == 0 ? "Welcome Back!" : "Create Account",
                  key: ValueKey<int>(_currentPage),
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currentPage == 0 ? "Sign in to continue" : "Join us today",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopSection(),
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      _buildAuthToggle(),
                      const SizedBox(height: 30),
                      SizedBox(
                        // ✨ OPTIMIZATION: Set a more adaptive height
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          children: [_buildLoginForm(), _buildRegisterForm()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Form Builder Widgets ---

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      // ✨ OPTIMIZATION: Added physics for better scrolling on iOS
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildInputField(
            controller: loginEmailController,
            hintText: "Email",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 15),
          _buildInputField(
            controller: loginPasswordController,
            hintText: "Password",
            icon: Icons.lock_outline,
            obscureText: _obscureLoginPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureLoginPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFFFF6B6B),
              ),
              onPressed: () {
                setState(() => _obscureLoginPassword = !_obscureLoginPassword);
              },
            ),
          ),
          const SizedBox(height: 50),
          _buildActionButton("Login", loginUser),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      // ✨ OPTIMIZATION: Added physics for better scrolling on iOS
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildInputField(
            controller: nameController,
            hintText: "Full Name",
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 15),
          _buildInputField(
            controller: registerEmailController,
            hintText: "Email",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 15),
          _buildInputField(
            controller: phoneController,
            hintText: "Phone Number",
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: AbsorbPointer(
              child: _buildInputField(
                controller: dobController,
                hintText: "Date of Birth",
                icon: Icons.calendar_today_outlined,
              ),
            ),
          ),
          const SizedBox(height: 15),
          _buildModernDropdown(
            label: "Gender",
            icon: Icons.wc_outlined,
            value: _selectedGender,
            items: _genderOptions,
            onChanged: (value) => setState(() => _selectedGender = value),
          ),
          const SizedBox(height: 15),
          _buildModernDropdown(
            label: "Blood Group",
            icon: Icons.bloodtype_outlined,
            value: _selectedBloodGroup,
            items: _bloodGroupOptions,
            onChanged: (value) => setState(() => _selectedBloodGroup = value),
          ),
          const SizedBox(height: 15),
          _buildInputField(
            controller: addressController,
            hintText: "Address",
            icon: Icons.location_on_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 15),
          _buildInputField(
            controller: registerPasswordController,
            hintText: "Password",
            icon: Icons.lock_outline,
            obscureText: _obscureRegisterPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureRegisterPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFFFF6B6B),
              ),
              onPressed: () => setState(
                    () => _obscureRegisterPassword = !_obscureRegisterPassword,
              ),
            ),
          ),
          const SizedBox(height: 15),
          _buildInputField(
            controller: confirmPasswordController,
            hintText: "Confirm Password",
            icon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFFFF6B6B),
              ),
              onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildActionButton("Create Account", registerUser),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 55,
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
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}