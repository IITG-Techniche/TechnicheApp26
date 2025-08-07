import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GHMRegistrationScreen extends StatefulWidget {
  static const String routeName = '/ghm-registration';

  const GHMRegistrationScreen({Key? key}) : super(key: key);

  @override
  _GHMRegistrationScreenState createState() => _GHMRegistrationScreenState();
}

class _GHMRegistrationScreenState extends State<GHMRegistrationScreen> {
  static const bool registrationsOpen = false;
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

  final String baseUrl = 'http://192.168.128.52:3001';

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.085),
        child: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Color(0xFF181A20),
            statusBarIconBrightness: Brightness.light,
          ),
          backgroundColor: const Color(0xFF23242B),
          title: const Text(
            'Marathon Registration',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
        ),
      ),
      body: registrationsOpen
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildTextField(
                      label: "Full Name",
                      validator: (value) => value?.isEmpty ?? true
                          ? "Please enter your name"
                          : null,
                      controller: _nameController,
                    ),
                    _buildTextField(
                      label: "Age",
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true
                          ? "Please enter your age"
                          : null,
                      controller: _ageController,
                    ),
                    _buildDropdown(
                      label: "Gender",
                      items: ["Male", "Female", "Prefer not to say"],
                      value: gender,
                      onChanged: (value) => setState(() => gender = value),
                    ),
                    _buildTextField(
                      label: "College/Institution/Company",
                      validator: (value) => value?.isEmpty ?? true
                          ? "This field is required"
                          : null,
                      controller: _institutionController,
                    ),
                    _buildTextField(
                      label: "Contact No",
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your contact number";
                        }
                        if (value.length != 10) {
                          return "Contact number must be 10 digits";
                        }
                        if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                          return "Please enter valid contact number";
                        }
                        return null;
                      },
                      controller: _contactController,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    _buildTextField(
                      label: "Email",
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value?.isEmpty ?? true
                          ? "Please enter your email"
                          : null,
                      controller: _emailController,
                    ),
                    _buildTextField(
                        label: "Country", controller: _countryController),
                    _buildTextField(
                        label: "State", controller: _stateController),
                    _buildTextField(
                        label: "City/District", controller: _cityController),
                    _buildDropdown(
                      label: "Marathon Category",
                      items: ["21km", "6km"],
                      value: marathonCategory,
                      onChanged: (value) =>
                          setState(() => marathonCategory = value),
                      icon: Icon(
                        Icons.directions_run,
                        color: Colors.blue,
                      ),
                      prefixIcon: Icons.directions_run,
                    ),
                    _buildChampionshipSection(),
                    _buildDropdown(
                      label: "How did you come to know about the marathon?",
                      items: ["Social Media", "Friends", "Website", "Other"],
                      value: sourceOfInfo,
                      onChanged: (value) =>
                          setState(() => sourceOfInfo = value),
                    ),
                    const SizedBox(height: 20),
                    if (marathonCategory != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(14, 31, 72, 1),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Pay and Register",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
          : Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF23242B),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_busy, color: Colors.redAccent, size: 54),
                    const SizedBox(height: 24),
                    Text(
                      'Registrations Closed',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Registrations for\nGuwahati Half Marathon 2025\nare closed.\n\nSee you next year!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.blueAccent.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    TextEditingController? controller,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color.fromRGBO(14, 31, 72, 1),
            fontSize: 16,
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromRGBO(14, 31, 72, 1), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        ),
        style: const TextStyle(
          color: Color.fromRGBO(14, 31, 72, 1),
          fontSize: 16,
        ),
        keyboardType: keyboardType,
        validator: validator,
        controller: controller,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
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
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color.fromRGBO(14, 31, 72, 1), 
            fontSize: 16,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Color.fromRGBO(14, 31, 72, 1))
              : null,
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromRGBO(14, 31, 72, 1), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        ),
        value: value,
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(14, 31, 72, 1),
                    ),
                  ),
                ))
            .toList(),
        onChanged: onChanged,
        icon: icon ?? const Icon(Icons.arrow_drop_down_circle_outlined),
        iconSize: 24,
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
                  title: const Text("General Championship Information"),
                  content: const Text(
                      "The General Championship trophy will be awarded to the college, "
                      "institution, or group whose total distance covered by its runners "
                      "is the highest. To find the total distance covered, sum the "
                      "distances of all runners.\n\n"
                      "For example, if 10 runners cover 21 km each and 15 runners "
                      "cover 6 km each, the total is 300 km."),
                  actions: [
                    TextButton(
                      child: const Text("Close"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.centerLeft,
            child: Row(
              children: const [
                Text(
                  "What is General Championship?",
                  style: TextStyle(
                    color: Color.fromRGBO(14, 31, 72, 1),
                    decoration: TextDecoration.underline,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.info_outline,
                    color: Color.fromRGBO(14, 31, 72, 1), size: 16),
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
          'name': _nameController.text,
          'age': _ageController.text,
          'gender': gender,
          'institution': _institutionController.text,
          'contact': _contactController.text,
          'email': _emailController.text,
          'country': _countryController.text,
          'state': _stateController.text,
          'city': _cityController.text,
          'marathonCategory': marathonCategory,
          'participateInChampionship': participateInChampionship,
          'sourceOfInfo': sourceOfInfo,
        };

        // Make API call
        final response = await http.post(
          Uri.parse('$baseUrl/api/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(registrationData),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 30),
                    SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Registration Successful!',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Registration ID: ${responseData['registrationId']}'),
                    const SizedBox(height: 10),
                    const Text(
                        'Please check your email for confirmation details.'),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                      _showSuccessMessage();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          throw Exception('Failed to register');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(10),
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: const Text('Registration failed. Please try again.'),
          ),
        );
      }
    }
  }


  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Registration Successful!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }
}
