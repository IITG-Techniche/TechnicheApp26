import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:techniche26/view/landing_screen.dart';

class GHMRegistrationScreen extends StatefulWidget {
  static const String routeName = '/ghm-registration';
  final bool isTab;

  const GHMRegistrationScreen({super.key, this.isTab = false});

  @override
  _GHMRegistrationScreenState createState() => _GHMRegistrationScreenState();
}

class _GHMRegistrationScreenState extends State<GHMRegistrationScreen> {
  bool registrationsOpen = true;
  final _formKey = GlobalKey<FormState>();
  String? gender;
  String? marathonCategory;
  String? sourceOfInfo;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();

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
    final bodyContent = registrationsOpen
        ? _buildRegistrationForm()
        : Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildClosedMessage()),
            ],
          );

    if (widget.isTab) {
      return Container(
        color: const Color(0xFFEDF1F5),
        child: bodyContent,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEDF1F5),
      body: bodyContent,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF002B5B),
        image: DecorationImage(
          image: AssetImage('assets/ghm/frame3.png'),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFAFAFAF)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (widget.isTab) {
                        Scaffold.of(context).openDrawer();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isTab
                            ? Icons.menu_rounded
                            : Icons.arrow_back_rounded,
                        color: const Color(0xFF6D7985),
                        size: 20,
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                  const Text(
                    'GHM REGISTRATION',
                    style: TextStyle(
                      color: Color(0XFF232930),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Univers',
                      height: 1.2,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildHeader(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE8E8E8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(
                    label: "Full Name*",
                    icon: Icons.person_outline_rounded,
                    validator: (value) => value?.isEmpty ?? true
                        ? "Please enter your name"
                        : null,
                    controller: _nameController,
                  ),
                  _buildTextField(
                    label: "Age*",
                    icon: Icons.calendar_today_rounded,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? "Required" : null,
                    controller: _ageController,
                  ),
                  _buildDropdown(
                    label: "Gender*",
                    items: ["Male", "Female", "Prefer not to say"],
                    value: gender,
                    prefixIcon: Icons.wc_rounded,
                    onChanged: (value) => setState(() => gender = value),
                  ),
                  _buildTextField(
                    label: "Organisation*",
                    icon: Icons.business_rounded,
                    controller: _organizationController,
                    validator: (value) =>
                        value?.isEmpty ?? true ? "Required" : null,
                  ),
                  _buildTextField(
                    label: "Mobile Number*",
                    icon: Icons.phone_android_rounded,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Required";
                      if (value.length != 10) return "10 digits";
                      return null;
                    },
                    controller: _contactController,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  _buildTextField(
                    label: "Email ID*",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value?.isEmpty ?? true ? "Required" : null,
                    controller: _emailController,
                  ),
                  _buildTextField(
                    label: "Country*",
                    icon: Icons.public_rounded,
                    controller: _countryController,
                    validator: (value) =>
                        value?.isEmpty ?? true ? "Required" : null,
                  ),
                  _buildTextField(
                    label: "State*",
                    icon: Icons.map_rounded,
                    controller: _stateController,
                    validator: (value) =>
                        value?.isEmpty ?? true ? "Required" : null,
                  ),
                  _buildTextField(
                    label: "City*",
                    icon: Icons.location_city_rounded,
                    controller: _cityController,
                    validator: (value) =>
                        value?.isEmpty ?? true ? "Required" : null,
                  ),
                  const Divider(height: 32, color: Color(0xFFE8E8E8)),
                  _buildDropdown(
                    label: "Category of Race*",
                    items: ["21km", "6km"],
                    value: marathonCategory,
                    onChanged: (value) =>
                        setState(() => marathonCategory = value),
                    prefixIcon: Icons.directions_run_rounded,
                  ),
                  _buildTextField(
                    label: "Referral Code (Optional)",
                    icon: Icons.confirmation_number_outlined,
                    controller: _referralCodeController,
                    hintText: "Enter code if any",
                  ),
                  _buildDropdown(
                    label: "How did you hear about us?*",
                    items: [
                      "Social Media",
                      "Friends/Family",
                      "Website",
                      "News",
                      "Campaign",
                      "Other"
                    ],
                    value: sourceOfInfo,
                    prefixIcon: Icons.info_outline_rounded,
                    onChanged: (value) => setState(() => sourceOfInfo = value),
                  ),
                  const SizedBox(height: 24),
                  if (marathonCategory != null)
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF002B5B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        marathonCategory == "6km"
                            ? "REGISTER"
                            : "PAY AND REGISTER",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'General Sans',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
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
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: const Color(0xFF6D7985), size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                    color: Color(0XFF232930),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'General Sans',
                    height: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: const TextStyle(
              color: Color(0XFF232930),
              fontSize: 16,
              fontFamily: 'General Sans',
              height: 1.2,
              fontWeight: FontWeight.w600,
            ),
            keyboardType: keyboardType,
            validator: validator,
            maxLength: maxLength,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hintText ?? "Enter your $label",
              hintStyle: const TextStyle(
                color: Color(0xFFBDBDBD),
                fontSize: 14,
                fontFamily: 'General Sans',
                height: 1.2,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF002B5B), width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              counterText: "",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required void Function(String?)? onChanged,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (prefixIcon != null) ...[
                Icon(prefixIcon, color: const Color(0xFF6D7985), size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                    color: Color(0XFF232930),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'General Sans',
                    height: 1.20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            style: const TextStyle(
              color: Color(0XFF232930),
              fontSize: 16,
              fontFamily: 'General Sans',
              height: 1.2,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF002B5B), width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            value: value,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF6D7985)),
          ),
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
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event_busy_rounded,
                  color: Color(0xFFE53935), size: 80),
              const SizedBox(height: 24),
              const Text(
                'REGISTRATIONS UNAVAILABLE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0XFF232930),
                  fontFamily: 'Univers',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Official registrations for Guwahati Half Marathon 2026 are currently unavailable from the app.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: const Color(0xFF6D7985),
                  height: 1.5,
                  fontFamily: 'General Sans',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final registrationData = {
          'Name': _nameController.text.trim(),
          'Age': int.tryParse(_ageController.text) ?? 0,
          'Gender': gender,
          'Organization': _organizationController.text.trim(),
          'Contact': _contactController.text.trim(),
          'Email': _emailController.text.trim(),
          'City': _cityController.text.trim(),
          'State': _stateController.text.trim(),
          'Country': _countryController.text.trim(),
          'CategoryofRace': marathonCategory?.replaceAll('km', '') ?? '',
          'GeneralChampionship': _referralCodeController.text.trim().isEmpty
              ? 'None'
              : _referralCodeController.text.trim(),
          'Mediaform': sourceOfInfo,
        };

        final response = await http.post(
          Uri.parse('$baseUrl/api/ghm/ghmregister'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(registrationData),
        );

        if (response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          final String ghmId = responseData['GHM_ID'] ?? "UNKNOWN";
          final bool isGloryRun = marathonCategory == "21km";

          if (!mounted) return;

          if (isGloryRun) {
            _showGHMSuccessDialog("", isGloryRun);
          } else {
            _showGHMSuccessDialog(ghmId, isGloryRun);
          }
        } else {
          _showGHMErrorDialog("Registration Failed",
              "Something went wrong. Please check your data or try again later.");
        }
      } catch (e) {
        _showGHMErrorDialog("Connection Error",
            "Check your internet connection and try again.");
      }
    }
  }

  void _showGHMSuccessDialog(String ghmId, bool isGloryRun) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1EBFF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isGloryRun
                      ? Icons.payment_rounded
                      : Icons.check_circle_rounded,
                  color: const Color(0xFF002B5B),
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isGloryRun
                    ? 'REGISTRATION INITIATED'
                    : 'REGISTRATION SUCCESSFUL',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Univers',
                  color: Color(0XFF232930),
                ),
              ),
              const SizedBox(height: 16),
              if (!isGloryRun && ghmId.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("GHM ID: ",
                          style: TextStyle(
                              color: Color(0xFF6D7985),
                              fontSize: 14,
                              fontFamily: 'General Sans',
                              height: 1.2,
                              fontWeight: FontWeight.w400)),
                      Text(ghmId,
                          style: const TextStyle(
                              color: Color(0xFF002B5B),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'General Sans',
                              height: 1.2)),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                isGloryRun
                    ? "We will send you a payment link to your registered email shortly. Kindly complete the payment from there to get your GHM ID."
                    : "Official confirmation along with your GHM ID has been sent to your email. We look forward to seeing you at the marathon!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF6D7985),
                    fontSize: 14,
                    height: 1.5,
                    fontFamily: 'General Sans'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002B5B),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("GREAT!",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'General Sans',
                        height: 1.2,
                      )),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LandingScreen()));
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
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title,
              style: const TextStyle(
                  color: Color(0xFFE53935),
                  fontSize: 18,
                  fontFamily: 'Univers',
                  fontWeight: FontWeight.w700,
                  height: 1.2)),
          content: Text(message,
              style: const TextStyle(
                  color: Color(0xFF6D7985),
                  fontSize: 14,
                  fontFamily: 'General Sans',
                  height: 1.2)),
          actions: [
            TextButton(
              child: const Text("RETRY",
                  style: TextStyle(
                      color: Color(0xFF002B5B),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'General Sans',
                      height: 1.2)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
