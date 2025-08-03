import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;
  late String _email;
  String _gender = 'Male';
  String _bloodGroup = 'A+';
  DateTime? _selectedDate;
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
  ];
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _dobController = TextEditingController();
    _loadUserData();

    _phoneController.addListener(() {
      final text = _phoneController.text;
      if (text.length > 10) {
        _phoneController.text = text.substring(0, 10);
        _phoneController.selection = TextSelection.fromPosition(
          TextPosition(offset: _phoneController.text.length),
        );
      }
    });
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    _email = user.email ?? '';

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (mounted) {
      final data = doc.data();
      if (data != null) {
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _addressController.text = data['address'] ?? '';
        _gender = data['gender'] ?? 'Male';
        _bloodGroup = data['bloodGroup'] ?? 'A+';

        final dob = data['dob'] as Timestamp?;
        if (dob != null) {
          _selectedDate = dob.toDate();
          _dobController.text = DateFormat('dd MMM yyyy').format(_selectedDate!);
        }
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final eighteenYearsAgo = DateTime(
        DateTime.now().year - 18, DateTime.now().month, DateTime.now().day);
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
        _dobController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      setState(() => _isSaving = false);
      return;
    }

    try {
      await _firestore.collection('users').doc(uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'gender': _gender,
        'dob': _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text("Profile updated successfully", style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text("Failed to update profile: $e", style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
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
          "Edit Profile",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
          ))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextFormField(
                controller: _nameController,
                label: "Full Name",
                icon: Icons.person,
                validator: (value) =>
                value == null || value.isEmpty
                    ? "Full Name is required"
                    : null,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                initialValue: _email,
                label: "Email",
                icon: Icons.email,
                enabled: false,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _phoneController,
                label: "Phone Number",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Phone number is required";
                  }
                  String pattern = r'^[6-9]\d{9}$';
                  RegExp regExp = RegExp(pattern);
                  if (!regExp.hasMatch(value)) {
                    return "Enter a valid 10-digit Indian mobile number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _dobController,
                label: "Date of Birth",
                icon: Icons.calendar_today,
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Date of Birth is required";
                  }
                  if (_selectedDate != null) {
                    final eighteenYearsAgo = DateTime(
                        DateTime.now().year - 18,
                        DateTime.now().month,
                        DateTime.now().day);
                    if (_selectedDate!.isAfter(eighteenYearsAgo)) {
                      return 'You must be at least 18 years old.';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildModernDropdown(
                label: "Gender",
                icon: Icons.wc,
                value: _gender,
                items: _genders,
                onChanged: (value) => setState(() => _gender = value!),
              ),
              const SizedBox(height: 20),
              _buildModernDropdown(
                label: "Blood Group",
                icon: Icons.bloodtype,
                value: _bloodGroup,
                items: _bloodGroups,
                onChanged: null,
                enabled: false,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _addressController,
                label: "Address",
                icon: Icons.location_on,
                maxLines: 3,
                validator: (value) =>
                value == null || value.isEmpty
                    ? "Address is required"
                    : null,
              ),
              const SizedBox(height: 30),
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
                  onPressed: _saveProfile,
                  icon: _isSaving
                      ? Container(
                    width: 24,
                    height: 24,
                    padding: const EdgeInsets.all(2.0),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                      : const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    _isSaving ? "Saving..." : "Save Profile",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding:
                    const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required IconData icon,
    TextEditingController? controller,
    String? initialValue,
    bool enabled = true,
    int? maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(),
      decoration: _buildInputDecoration(label, icon, enabled: enabled),
      validator: validator,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      onTap: onTap,
    );
  }

  Widget _buildModernDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item, style: GoogleFonts.poppins()),
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
            borderSide:
            const BorderSide(color: Color(0xFFFF6B6B), width: 2.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon,
      {bool enabled = true}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
          color: enabled ? Colors.grey.shade700 : Colors.grey.shade500),
      prefixIcon: Icon(icon,
          color: enabled ? const Color(0xFFFF6B6B) : Colors.grey.shade400),
      filled: true,
      fillColor: enabled ? Colors.white : Colors.grey.shade200,
      contentPadding:
      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2.0),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}