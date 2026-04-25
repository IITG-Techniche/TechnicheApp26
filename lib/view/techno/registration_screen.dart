import 'package:flutter/material.dart';
import '../../model/registration_model.dart';
import '../../services/registration_service.dart';
import '../../constant/techno_city.dart';
import 'payment_screen.dart';
import 'package:flutter/services.dart';

class TechnoRegistrationScreen extends StatefulWidget {
  const TechnoRegistrationScreen({super.key});

  @override
  State<TechnoRegistrationScreen> createState() => _TechnoRegistrationScreenState();
}

class _TechnoRegistrationScreenState extends State<TechnoRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TecnoTeamRegistration _team = TecnoTeamRegistration();

  bool _isLoading = false;
  bool _readInstructions = false;
  bool _confirmDetails = false;

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
      _showErrorDialog("Validation Error", "Emails for Student 1 do not match");
      return false;
    }
    if (_team.email2 != _team.confirmEmail2) {
      _showErrorDialog("Validation Error", "Emails for Student 2 do not match");
      return false;
    }
    return true;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _validateEmails()) {
      _formKey.currentState!.save();

      if (!_readInstructions || !_confirmDetails) {
        _showErrorDialog(
            "Requirements", "Please accept instructions and confirm details");
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final result = await RegistrationService.registerTeam(_team);
        final paymentUrl = result['paymentUrl'];

        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PaymentScreen(
                    paymentUrl: paymentUrl,
                    onPaymentSuccess: (regId) {
                      Navigator.pop(context);
                      _handlePaymentSuccess(regId);
                    },
                  )),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog("Registration Failed", e.toString());
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

      _showSuccessDialog(credentials['rollNumber'], credentials['password']);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog("Verification Error",
          "Payment verified but error getting credentials: $e");
    }
  }

  void _showSuccessDialog(String rollNumber, String password) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF002B5B), size: 60),
            const SizedBox(height: 24),
            const Text(
              "REGISTRATION SUCCESSFUL!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0XFF232930),
                  fontSize: 18,
                  fontFamily: 'Univers',
                  fontWeight: FontWeight.w700,
                  height: 1.2),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildDialogInfoRow("Roll Number", rollNumber),
                  const SizedBox(height: 12),
                  _buildDialogInfoRow("Password", password),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "These details have been sent to your email. Keep them safe for future rounds.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xFF6D7985),
                  fontSize: 13,
                  fontFamily: 'General Sans',
                  height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002B5B),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("GREAT!",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'General Sans',
                        fontSize: 16)),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF6D7985),
                fontSize: 13,
                fontFamily: 'General Sans')),
        Text(value,
            style: const TextStyle(
                color: Color(0xFF002B5B),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'General Sans')),
      ],
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            child: const Text("OK",
                style: TextStyle(
                    color: Color(0xFF002B5B),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'General Sans')),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
                color: Color(0xFF002B5B),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'Univers',
                height: 1.2,
                letterSpacing: 1.2),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, Function(String?) onSaved,
      {TextInputType type = TextInputType.text, bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0XFF232930),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'General Sans',
                  height: 1.2)),
          const SizedBox(height: 8),
          TextFormField(
            style: const TextStyle(
                color: Color(0XFF232930),
                fontSize: 16,
                fontFamily: 'General Sans',
                fontWeight: FontWeight.w600,
                height: 1.2),
            decoration: InputDecoration(
              hintText: "Enter $label",
              hintStyle: const TextStyle(
                  color: Color(0xFFBDBDBD),
                  fontSize: 14,
                  fontFamily: 'General Sans',
                  height: 1.2),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF002B5B), width: 1.5)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            keyboardType: type,
            validator: (value) => required && (value == null || value.isEmpty)
                ? "Required"
                : null,
            onSaved: onSaved,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? currentValue,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0XFF232930),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'General Sans',
                  height: 1.2)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            style: const TextStyle(
                color: Color(0XFF232930),
                fontSize: 16,
                fontFamily: 'General Sans',
                fontWeight: FontWeight.w600,
                height: 1.2),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF002B5B), width: 1.5)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            value: currentValue == null || currentValue.isEmpty
                ? null
                : currentValue,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
            validator: (value) => value == null ? "Required" : null,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF6D7985)),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(
      String label, String? currentValue, Function(String) onDateSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0XFF232930),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'General Sans',
                  height: 1.2)),
          const SizedBox(height: 8),
          FormField<String>(
              validator: (value) => currentValue == null || currentValue.isEmpty
                  ? "Required"
                  : null,
              builder: (state) {
                return InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now()
                          .subtract(const Duration(days: 365 * 15)),
                      firstDate: DateTime(1990),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF002B5B),
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: Color(0XFF232930),
                            ),
                            dialogBackgroundColor: Colors.white,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      String formatted =
                          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                      onDateSelected(formatted);
                      state.didChange(formatted);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE8E8E8))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE8E8E8))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF002B5B), width: 1.5)),
                      errorText: state.errorText,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currentValue == null || currentValue.isEmpty
                              ? 'Select Date'
                              : currentValue,
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'General Sans',
                              fontWeight: FontWeight.w600,
                              color:
                                  currentValue == null || currentValue.isEmpty
                                      ? const Color(0xFFBDBDBD)
                                      : const Color(0XFF232930)),
                        ),
                        const Icon(Icons.calendar_today_rounded,
                            size: 18, color: Color(0xFF6D7985)),
                      ],
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF002B5B)))
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildHeader(context),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            "I have read the instructions carefully",
                            _readInstructions,
                            (v) => setState(() => _readInstructions = v!)),
                        _buildCheckboxTile(
                            "I confirm my details are correct",
                            _confirmDetails,
                            (v) => setState(() => _confirmDetails = v!)),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (_readInstructions && _confirmDetails)
                                ? _submitForm
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF002B5B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                              disabledBackgroundColor: const Color(0xFFF5F5F5),
                            ),
                            child: const Text(
                              "PAY NOW",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'General Sans',
                                  height: 1.2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
                shadows: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: Color(0xFFF5F5F5), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Color(0xFF6D7985), size: 20),
                    ),
                  ),
                  const Spacer(flex: 1),
                  const Text(
                    'STUDENT REGISTRATION',
                    style: TextStyle(
                        color: Color(0XFF232930),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Univers',
                        height: 1.2),
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

  Widget _buildAutocomplete({
    required String label,
    required List<String> options,
    required Function(String) onSelected,
    required String initialValue,
    required Function(String?) onSaved,
    bool isCity = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0XFF232930),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'General Sans',
                  height: 1.2)),
          const SizedBox(height: 8),
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '')
                return const Iterable<String>.empty();
              return options.where((String option) => option
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: onSelected,
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
              if (initialValue.isNotEmpty && controller.text.isEmpty)
                controller.text = initialValue;
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                style: const TextStyle(
                    color: Color(0XFF232930),
                    fontSize: 16,
                    fontFamily: 'General Sans',
                    fontWeight: FontWeight.w600,
                    height: 1.2),
                decoration: InputDecoration(
                  hintText: "Select $label",
                  hintStyle: const TextStyle(
                      color: Color(0xFFBDBDBD),
                      fontSize: 14,
                      fontFamily: 'General Sans',
                      height: 1.2),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFF002B5B), width: 1.5)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Required";
                  if (isCity && !TechnoCity.cityToId.containsKey(value))
                    return "Select a valid city";
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8E8E8)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ]),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (context, index) =>
                          const Divider(color: Color(0xFFE8E8E8), height: 1),
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: Text(option,
                              style: const TextStyle(
                                  color: Color(0XFF232930),
                                  fontSize: 14,
                                  fontFamily: 'General Sans')),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(
      String title, bool value, void Function(bool?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: value
                  ? const Color(0xFF002B5B).withOpacity(0.3)
                  : const Color(0xFFE8E8E8))),
      child: CheckboxListTile(
        title: Text(title,
            style: TextStyle(
                color:
                    value ? const Color(0XFF232930) : const Color(0xFF6D7985),
                fontSize: 14,
                fontFamily: 'General Sans',
                fontWeight: value ? FontWeight.w600 : FontWeight.w400)),
        value: value,
        onChanged: onChanged,
        checkColor: Colors.white,
        activeColor: const Color(0xFF002B5B),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
