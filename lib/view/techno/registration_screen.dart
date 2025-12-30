import 'package:flutter/material.dart';
import '../../constant/appTheme.dart';
import '../../model/registration_model.dart';
import '../../services/registration_service.dart';
import '../../constant/techno_city.dart';
import 'payment_screen.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String?) onSaved,
      {TextInputType type = TextInputType.text, bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textColorSecondary),
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
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textColorSecondary),
        ),
        value:
            currentValue == null || currentValue.isEmpty ? null : currentValue,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? "Required" : null,
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
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1990),
                  lastDate: DateTime.now(),
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
                  labelStyle:
                      const TextStyle(color: AppTheme.textColorSecondary),
                  errorText: state.errorText,
                ),
                child: Text(
                  currentValue == null || currentValue.isEmpty
                      ? 'Select Date'
                      : currentValue,
                  style: TextStyle(
                      color: currentValue == null || currentValue.isEmpty
                          ? Colors.white54
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
      appBar: AppBar(title: const Text("Student Registration")),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Student Information 1"),
                    _buildTextField("Name", (v) => _team.name1 = v!),
                    _buildDatePicker("Date of Birth", _team.dob1,
                        (v) => setState(() => _team.dob1 = v)),
                    _buildTextField("Contact", (v) => _team.contact1 = v!,
                        type: TextInputType.phone),
                    _buildTextField("Email", (v) => _team.email1 = v!,
                        type: TextInputType.emailAddress),
                    _buildTextField(
                        "Confirm Email", (v) => _team.confirmEmail1 = v!,
                        type: TextInputType.emailAddress),
                    _buildTextField("School", (v) => _team.school1 = v!),
                    _buildDropdown("Class", _classes, _team.class1,
                        (v) => setState(() => _team.class1 = v!)),

                    _buildSectionTitle("Student Information 2"),
                    _buildTextField("Name", (v) => _team.name2 = v!),
                    _buildDatePicker("Date of Birth", _team.dob2,
                        (v) => setState(() => _team.dob2 = v)),
                    _buildTextField("Contact", (v) => _team.contact2 = v!,
                        type: TextInputType.phone),
                    _buildTextField("Email", (v) => _team.email2 = v!,
                        type: TextInputType.emailAddress),
                    _buildTextField(
                        "Confirm Email", (v) => _team.confirmEmail2 = v!,
                        type: TextInputType.emailAddress),
                    _buildTextField("School", (v) => _team.school2 = v!),
                    _buildDropdown("Class", _classes, _team.class2,
                        (v) => setState(() => _team.class2 = v!)),

                    _buildSectionTitle("Team Information"),
                    _buildDropdown("Squad", _squads, _team.squad,
                        (v) => setState(() => _team.squad = v!)),
                    _buildDropdown("Language", _languages, _team.language,
                        (v) => setState(() => _team.language = v!)),

                    // Country with Autocomplete or Dropdown. Using Dropdown for simplicity if list is small, but list is truncated.
                    // Using Autocomplete for Country and State is better.
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return const Iterable<String>.empty();
                          }
                          return _allCountries.where((String option) {
                            return option
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        onSelected: (String selection) {
                          _team.country = selection;
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: "Country",
                              labelStyle:
                                  TextStyle(color: AppTheme.textColorSecondary),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? "Required"
                                : null,
                            onSaved: (value) => _team.country = value ?? "",
                          );
                        },
                      ),
                    ),

                    // State
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return const Iterable<String>.empty();
                          }
                          return _allStates.where((String option) {
                            return option
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        onSelected: (String selection) {
                          _handleStateChange(selection);
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: "State",
                              labelStyle:
                                  TextStyle(color: AppTheme.textColorSecondary),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? "Required"
                                : null,
                            onSaved: (value) => _team.state = value ?? "",
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return const Iterable<String>.empty();
                          }
                          return TechnoCity.cityToId.keys
                              .where((String option) {
                            return option
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        onSelected: (String selection) {
                          _team.city = selection;
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                          if (_team.city.isNotEmpty &&
                              controller.text.isEmpty) {
                            controller.text = _team.city;
                          }
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: "City",
                              labelStyle:
                                  TextStyle(color: AppTheme.textColorSecondary),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Required";
                              }
                              if (!TechnoCity.cityToId.containsKey(value)) {
                                return "Please select a valid city from the list";
                              }
                              return null;
                            },
                            onSaved: (value) => _team.city = value ?? "",
                          );
                        },
                      ),
                    ),
                    _buildDropdown(
                        "How did you hear about Technothlon?",
                        _views,
                        _team.view,
                        (v) => setState(() => _team.view = v!)),

                    const SizedBox(height: 20),
                    CheckboxListTile(
                      title: const Text(
                          "I have read the instructions carefully",
                          style: TextStyle(color: Colors.white)),
                      value: _readInstructions,
                      onChanged: (v) => setState(() => _readInstructions = v!),
                      checkColor: AppTheme.scaffoldBackgroundColor,
                      activeColor: AppTheme.primaryColor,
                    ),
                    CheckboxListTile(
                      title: const Text("I confirm my details are correct",
                          style: TextStyle(color: Colors.white)),
                      value: _confirmDetails,
                      onChanged: (v) => setState(() => _confirmDetails = v!),
                      checkColor: AppTheme.scaffoldBackgroundColor,
                      activeColor: AppTheme.primaryColor,
                    ),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (_readInstructions && _confirmDetails)
                            ? _submitForm
                            : null,
                        child: const Text("PAY NOW"),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
