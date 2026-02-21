import 'package:flutter/material.dart';
import '../../model/registration_model.dart';
import '../../services/registration_service.dart';
import '../../constant/techno_city.dart';
import 'payment_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/animate_gradient_background.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TecnoTeamRegistration _team = TecnoTeamRegistration();

  bool _isLoading = false;
  bool _readInstructions = false;
  bool _confirmDetails = false;

  // Controllers to manage dependent fields
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  final List<String> _allStates = [
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
    "Ladakh",
    "Jammu & Kashmir",
    "Puducherry",
    "Lakshadweep",
    "Delhi",
    "Chandigarh",
    "Dadra and Nagar Haveli and Daman & Diu",
    "Andaman and Nicobar"
  ];

  final Map<String, String> _stateToZoneMap = {
    "Jammu & Kashmir": "North",
    "Jammu and Kashmir": "North",
    "Ladakh": "North",
    "Himachal Pradesh": "North",
    "Punjab": "North",
    "Chandigarh": "North",
    "Haryana": "North",
    "Uttarakhand": "North",
    "Delhi": "North",
    "Uttar Pradesh": "North",
    "Bihar": "North",
    "Telangana": "South",
    "Andhra Pradesh": "South",
    "Karnataka": "South",
    "Kerala": "South",
    "Tamil Nadu": "South",
    "Puducherry": "South",
    "Andaman and Nicobar": "South",
    "Lakshadweep": "South",
    "Jharkhand": "East",
    "Chhattisgarh": "East",
    "Odisha": "East",
    "West Bengal": "East",
    "Assam": "East",
    "Meghalaya": "East",
    "Manipur": "East",
    "Tripura": "East",
    "Mizoram": "East",
    "Nagaland": "East",
    "Arunachal Pradesh": "East",
    "Sikkim": "East",
    "Rajasthan": "West",
    "Madhya Pradesh": "West",
    "Gujarat": "West",
    "Maharashtra": "West",
    "Goa": "West",
    "Dadra and Nagar Haveli and Daman & Diu": "West"
  };

  final List<String> _allCountries = [
    "India",
    "Afghanistan",
    "Albania",
    "Algeria",
    "Andorra",
    "Angola",
    "Antigua and Barbuda",
    "Argentina",
    "Armenia",
    "Australia",
    "Austria",
    "Azerbaijan",
    "Bahamas",
    "Bahrain",
    "Bangladesh",
    "Barbados",
    "Belarus",
    "Belgium",
    "United States of America",
    "United Kingdom",
    "Canada"
  ];

  final List<String> _classes = ['9', '10', '11', '12'];
  final List<String> _squads = ['Juniors', 'Hauts'];
  final List<String> _languages = ['English', 'Hindi'];
  final List<String> _views = [
    "Cityrep",
    "School",
    "Friends",
    "Social Media",
    "Newspaper",
    "Website",
    "Already Participated",
    "Event",
    "Other"
  ];

  @override
  void dispose() {
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _handleStateChange(String? value) {
    if (value == null) return;
    setState(() {
      _team.state = value;
      _team.zone = _stateToZoneMap[value] ?? "";
    });
  }

  bool _validateEmails() {
    if (_team.email1 != _team.confirmEmail1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Emails for Student 1 do not match")),
      );
      return false;
    }
    if (_team.email2 != _team.confirmEmail2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Emails for Student 2 do not match")),
      );
      return false;
    }
    return true;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _validateEmails()) {
      _formKey.currentState!.save();

      if (!_readInstructions || !_confirmDetails) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please accept instructions and confirm details")),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // 1. Register
        final result = await RegistrationService.registerTeam(_team);
        final paymentUrl = result['paymentUrl'];

        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        // 2. Open Payment
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PaymentScreen(
                    paymentUrl: paymentUrl,
                    onPaymentSuccess: (regId) {
                      Navigator.pop(context); // Close Payment Screen
                      _handlePaymentSuccess(regId);
                    },
                  )),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _handlePaymentSuccess(String regId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final credentials = await RegistrationService.confirmPayment(regId);
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text("Registration Successful!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Roll Number: ${credentials['rollNumber']}"),
              const SizedBox(height: 8),
              Text("Password: ${credentials['password']}"),
              const SizedBox(height: 16),
              const Text("These details have been sent to your email."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Close Dialog
                Navigator.pop(context); // Go back to previous screen (Home)
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Payment verified but error getting credentials: $e")),
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.orbitron(
          color: const Color(0xFF00E5FF),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
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
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(title),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, Function(String?) onSaved,
      {TextInputType type = TextInputType.text, bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
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
        keyboardType: type,
        validator: (value) =>
            required && (value == null || value.isEmpty) ? "Required" : null,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? currentValue,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        dropdownColor: const Color(0xFF1A1D24),
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
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
        value:
            currentValue == null || currentValue.isEmpty ? null : currentValue,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? "Required" : null,
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white60),
      ),
    );
  }

  Widget _buildDatePicker(
      String label, String? currentValue, Function(String) onDateSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: FormField<String>(
          validator: (value) =>
              currentValue == null || currentValue.isEmpty ? "Required" : null,
          builder: (state) {
            return InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      DateTime.now().subtract(const Duration(days: 365 * 15)),
                  firstDate: DateTime(1990),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: Color(0xFF00E5FF),
                          onPrimary: Colors.black,
                          surface: Color(0xFF1A1D24),
                          onSurface: Colors.white,
                        ),
                        dialogBackgroundColor: const Color(0xFF1A1D24),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  // Format YYYY-MM-DD
                  String formatted =
                      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  onDateSelected(formatted);
                  state.didChange(formatted);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
                  ),
                  errorText: state.errorText,
                ),
                child: Text(
                  currentValue == null || currentValue.isEmpty
                      ? 'Select Date'
                      : currentValue,
                  style: TextStyle(
                      fontSize: 16,
                      color: currentValue == null || currentValue.isEmpty
                          ? Colors.grey[600]
                          : Colors.white),
                ),
              ),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "STUDENT REGISTRATION",
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const AnimatedGradientBackground(),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _buildSectionCard(
                            title: "Student Information 1",
                            children: [
                              _buildTextField("Name", (v) => _team.name1 = v!),
                              _buildDatePicker("Date of Birth", _team.dob1,
                                  (v) => setState(() => _team.dob1 = v)),
                              _buildTextField(
                                  "Contact", (v) => _team.contact1 = v!,
                                  type: TextInputType.phone),
                              _buildTextField("Email", (v) => _team.email1 = v!,
                                  type: TextInputType.emailAddress),
                              _buildTextField("Confirm Email",
                                  (v) => _team.confirmEmail1 = v!,
                                  type: TextInputType.emailAddress),
                              _buildTextField(
                                  "School", (v) => _team.school1 = v!),
                              _buildDropdown("Class", _classes, _team.class1,
                                  (v) => setState(() => _team.class1 = v!)),
                            ],
                          ),
                          _buildSectionCard(
                            title: "Student Information 2",
                            children: [
                              _buildTextField("Name", (v) => _team.name2 = v!),
                              _buildDatePicker("Date of Birth", _team.dob2,
                                  (v) => setState(() => _team.dob2 = v)),
                              _buildTextField(
                                  "Contact", (v) => _team.contact2 = v!,
                                  type: TextInputType.phone),
                              _buildTextField("Email", (v) => _team.email2 = v!,
                                  type: TextInputType.emailAddress),
                              _buildTextField("Confirm Email",
                                  (v) => _team.confirmEmail2 = v!,
                                  type: TextInputType.emailAddress),
                              _buildTextField(
                                  "School", (v) => _team.school2 = v!),
                              _buildDropdown("Class", _classes, _team.class2,
                                  (v) => setState(() => _team.class2 = v!)),
                            ],
                          ),
                          _buildSectionCard(
                            title: "Team Discovery",
                            children: [
                              _buildDropdown("Squad", _squads, _team.squad,
                                  (v) => setState(() => _team.squad = v!)),
                              _buildDropdown(
                                  "Language",
                                  _languages,
                                  _team.language,
                                  (v) => setState(() => _team.language = v!)),
                              _buildDropdown(
                                  "How did you hear about Technothlon?",
                                  _views,
                                  _team.view,
                                  (v) => setState(() => _team.view = v!)),
                            ],
                          ),
                          _buildSectionCard(
                            title: "Location Details",
                            children: [
                              _buildAutocomplete(
                                label: "Country",
                                options: _allCountries,
                                onSelected: (val) => _team.country = val,
                                initialValue: _team.country,
                                onSaved: (val) => _team.country = val ?? "",
                              ),
                              _buildAutocomplete(
                                label: "State",
                                options: _allStates,
                                onSelected: (val) => _handleStateChange(val),
                                initialValue: _team.state,
                                onSaved: (val) => _team.state = val ?? "",
                              ),
                              _buildAutocomplete(
                                label: "City",
                                options: TechnoCity.cityToId.keys.toList(),
                                onSelected: (val) => _team.city = val,
                                initialValue: _team.city,
                                onSaved: (val) => _team.city = val ?? "",
                                isCity: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildCheckboxTile(
                            title: "I have read the instructions carefully",
                            value: _readInstructions,
                            onChanged: (v) =>
                                setState(() => _readInstructions = v!),
                          ),
                          _buildCheckboxTile(
                            title: "I confirm my details are correct",
                            value: _confirmDetails,
                            onChanged: (v) =>
                                setState(() => _confirmDetails = v!),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (_readInstructions && _confirmDetails)
                                  ? _submitForm
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00E5FF),
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 8,
                                disabledBackgroundColor: Colors.white10,
                                shadowColor:
                                    const Color(0xFF00E5FF).withOpacity(0.4),
                              ),
                              child: Text(
                                "PAY NOW",
                                style: GoogleFonts.orbitron(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildAutocomplete({
    required String label,
    required List<String> options,
    required Function(String) onSelected,
    required String initialValue,
    required Function(String?) onSaved,
    bool isCity = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == '') {
            return const Iterable<String>.empty();
          }
          return options.where((String option) {
            return option
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase());
          });
        },
        onSelected: onSelected,
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          if (initialValue.isNotEmpty && controller.text.isEmpty) {
            controller.text = initialValue;
          }
          return TextFormField(
            controller: controller,
            focusNode: focusNode,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
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
                borderSide:
                    const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "Required";
              if (isCity && !TechnoCity.cityToId.containsKey(value)) {
                return "Please select a valid city from the list";
              }
              return null;
            },
            onSaved: onSaved,
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width - 80,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2128),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.white.withOpacity(0.05),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return ListTile(
                      title: Text(option,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14)),
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required void Function(bool?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: value
                ? const Color(0xFF00E5FF).withOpacity(0.3)
                : Colors.white.withOpacity(0.1)),
      ),
      child: CheckboxListTile(
        title: Text(
          title,
          style: TextStyle(
            color: value ? Colors.white : Colors.grey[400],
            fontSize: 14,
          ),
        ),
        value: value,
        onChanged: onChanged,
        checkColor: Colors.black,
        activeColor: const Color(0xFF00E5FF),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
