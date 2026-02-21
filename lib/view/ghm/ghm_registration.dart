import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../../utils/animate_gradient_background.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ghm_payment_screen.dart';

class GHMRegistrationScreen extends StatefulWidget {
  static const String routeName = '/ghm-registration';

  const GHMRegistrationScreen({Key? key}) : super(key: key);

  @override
  _GHMRegistrationScreenState createState() => _GHMRegistrationScreenState();
}

class _GHMRegistrationScreenState extends State<GHMRegistrationScreen> {
  bool registrationsOpen = true;
  final _formKey = GlobalKey<FormState>();
  String? gender;
  String? marathonCategory;
  String? participateInChampionship;
  String? sourceOfInfo;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  final String baseUrl = 'https://techniche.org.in';

  @override
  void initState() {
    super.initState();
    _loadRemoteConfig();
  }

  Future<void> _loadRemoteConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    try {
      await remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint("Error fetching remote config: $e");
    }
    if (mounted) {
      setState(() {
        registrationsOpen = remoteConfig.getBool('marathon_registrations_open');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'GHM REGISTRATION',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const AnimatedGradientBackground(),
          registrationsOpen ? _buildRegistrationForm() : _buildClosedMessage(),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 20),
              _buildSectionCard(
                title: "Personal Details",
                children: [
                  _buildTextField(
                    label: "Full Name",
                    icon: Icons.person_outline,
                    validator: (value) => value?.isEmpty ?? true
                        ? "Please enter your name"
                        : null,
                    controller: _nameController,
                  ),
                  _buildTextField(
                    label: "Age",
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? "Please enter your age" : null,
                    controller: _ageController,
                  ),
                  _buildDropdown(
                    label: "Gender",
                    items: ["Male", "Female", "Prefer not to say"],
                    value: gender,
                    prefixIcon: Icons.wc,
                    onChanged: (value) => setState(() => gender = value),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: "Contact Information",
                children: [
                  _buildTextField(
                    label: "Institution / Company",
                    icon: Icons.business_outlined,
                    validator: (value) => value?.isEmpty ?? true
                        ? "This field is required"
                        : null,
                    controller: _institutionController,
                  ),
                  _buildTextField(
                    label: "Contact No",
                    icon: Icons.phone_android_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter contact number";
                      }
                      if (value.length != 10) {
                        return "Must be 10 digits";
                      }
                      return null;
                    },
                    controller: _contactController,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  _buildTextField(
                    label: "Email ID",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value?.isEmpty ?? true
                        ? "Please enter your email"
                        : null,
                    controller: _emailController,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: "Location Details",
                children: [
                  _buildTextField(
                    label: "Country",
                    icon: Icons.public,
                    controller: _countryController,
                  ),
                  _buildTextField(
                    label: "State",
                    icon: Icons.map_outlined,
                    controller: _stateController,
                  ),
                  _buildTextField(
                    label: "City / District",
                    icon: Icons.location_city_outlined,
                    controller: _cityController,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: "Marathon Selection",
                children: [
                  _buildDropdown(
                    label: "Category",
                    items: ["21km", "6km"],
                    value: marathonCategory,
                    onChanged: (value) =>
                        setState(() => marathonCategory = value),
                    prefixIcon: Icons.directions_run,
                  ),
                  _buildChampionshipSection(),
                  _buildDropdown(
                    label: "How did you hear about us?",
                    items: ["Social Media", "Friends", "Website", "Other"],
                    value: sourceOfInfo,
                    prefixIcon: Icons.info_outline,
                    onChanged: (value) => setState(() => sourceOfInfo = value),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (marathonCategory != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0xFF00E5FF).withOpacity(0.4),
                    ),
                    child: Text(
                      marathonCategory == "6km"
                          ? "REGISTER"
                          : "PROCEED TO PAYMENT",
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
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

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.orbitron(
              color: const Color(0xFF00E5FF),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildClosedMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event_busy, color: Colors.redAccent, size: 80),
              const SizedBox(height: 24),
              Text(
                'REGISTRATIONS\nUNAVAILABLE',
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Official registrations for\nGuwahati Half Marathon 2026\nare currently unavailable from app.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    TextEditingController? controller,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        keyboardType: keyboardType,
        validator: validator,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: icon != null
              ? Icon(icon, color: const Color(0xFF00E5FF), size: 20)
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          counterStyle: const TextStyle(color: Colors.white30),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required void Function(String?)? onChanged,
    IconData? prefixIcon,
    Widget? icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
        dropdownColor: const Color(0xFF1A1D24),
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: const Color(0xFF00E5FF), size: 20)
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        value: value,
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
            .toList(),
        onChanged: onChanged,
        icon: icon ??
            const Icon(Icons.keyboard_arrow_down, color: Colors.white60),
      ),
    );
  }

  Widget _buildChampionshipSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: const Color(0xFF1A1D24),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: Text(
                    "General Championship",
                    style: GoogleFonts.orbitron(
                        color: const Color(0xFF00E5FF), fontSize: 18),
                  ),
                  content: Text(
                    "The General Championship trophy will be awarded to the college, "
                    "institution, or group whose total distance covered by its runners "
                    "is the highest. Total distance = Sum of distances of all runners.\n\n"
                    "Example: 10 runners (21km) + 15 runners (6km) = 300km total.",
                    style: TextStyle(
                        color: Colors.grey[300], fontSize: 14, height: 1.5),
                  ),
                  actions: [
                    TextButton(
                      child: const Text("CLOSE",
                          style: TextStyle(color: Color(0xFF00E5FF))),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                );
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 4, top: 4, bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: Color(0xFF00E5FF), size: 16),
                const SizedBox(width: 6),
                Text(
                  "What is General Championship?",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildDropdown(
          label: "Would you like to participate in General Championship?",
          items: ["Yes", "No"],
          value: participateInChampionship,
          onChanged: (value) =>
              setState(() => participateInChampionship = value),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final registrationData = {
          'Name': _nameController.text,
          'Age': int.tryParse(_ageController.text) ?? 0,
          'Gender': gender,
          'Organization': _institutionController.text,
          'Contact': int.tryParse(_contactController.text) ?? 0,
          'Email': _emailController.text,
          'Country': _countryController.text,
          'State': _stateController.text,
          'City': _cityController.text,
          'CategoryofRace': marathonCategory?.replaceAll('km', '') ?? '',
          'GeneralChampionship': participateInChampionship ?? 'None',
          'Mediaform': sourceOfInfo,
        };

        // Make API call
        final response = await http.post(
          Uri.parse('$baseUrl/api/ghm/ghmregister'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(registrationData),
        );

        if (response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          debugPrint("GHM Response: $responseData");
          final String ghmId = responseData['GHM_ID'] ?? "UNKNOWN";
          final String? paymentUrl = responseData['paymentUrl'];
          debugPrint("Detected Payment URL: $paymentUrl");
          final bool isGloryRun = marathonCategory == "21km";

          if (!mounted) return;

          if (isGloryRun && paymentUrl != null && paymentUrl.isNotEmpty) {
            // Option B: Direct Payment Flow
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GHMPaymentScreen(
                  paymentUrl: paymentUrl,
                  onPaymentSuccess: () {
                    Navigator.pop(context); // Close Payment WebView
                    _showGHMSuccessDialog(ghmId, isGloryRun,
                        paymentCompleted: true);
                  },
                ),
              ),
            );
          } else {
            // Option A: Instruction Flow (or fallback for missing URL)
            _showGHMSuccessDialog(ghmId, isGloryRun);
          }
        } else if (response.statusCode == 409) {
          if (!mounted) return;
          _showGHMErrorDialog("Already Registered",
              "You are already registered for this category.");
        } else if (response.statusCode == 400) {
          if (!mounted) return;
          _showGHMErrorDialog(
              "Invalid Category", "Please select a valid race category.");
        } else {
          if (!mounted) return;
          _showGHMErrorDialog("Server Error",
              "Something went wrong on our end. Please try again later.");
        }
      } catch (e) {
        if (!mounted) return;
        _showGHMErrorDialog("Connection Error",
            "Could not connect to the server. Please check your internet.");
      }
    }
  }

  void _showGHMSuccessDialog(String ghmId, bool isGloryRun,
      {bool paymentCompleted = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1D24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isGloryRun && !paymentCompleted)
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                    (isGloryRun && !paymentCompleted)
                        ? Icons.payment
                        : Icons.check_circle,
                    color: const Color(0xFF00E5FF),
                    size: 60),
              ),
              const SizedBox(height: 24),
              Text(
                (isGloryRun && !paymentCompleted)
                    ? 'REGISTRATION INITIATED'
                    : 'REGISTRATION SUCCESSFUL',
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              if (!isGloryRun || paymentCompleted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "GHM ID: ",
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                      Text(
                        ghmId,
                        style: const TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              if (!isGloryRun || paymentCompleted) const SizedBox(height: 20),
              Text(
                (isGloryRun && !paymentCompleted)
                    ? "Please check your email to complete the payment for the 21km Glory Run."
                    : (isGloryRun && paymentCompleted)
                        ? "Payment successful! Your 21km Glory Run registration is now confirmed. See you at the finish line!"
                        : "Official confirmation has been sent to your email. We look forward to seeing you at the Spirit Run!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey[300], fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    "GREAT!",
                    style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to Home/Previous
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGHMErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1D24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            title,
            style: GoogleFonts.orbitron(color: Colors.redAccent, fontSize: 18),
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.grey[300], fontSize: 14),
          ),
          actions: [
            TextButton(
              child: const Text("RETRY",
                  style: TextStyle(color: Color(0xFF00E5FF))),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
