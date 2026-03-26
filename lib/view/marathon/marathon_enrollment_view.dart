import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/marathon_provider.dart';
import '../../constant/appTheme.dart';

class MarathonEnrollmentView extends ConsumerStatefulWidget {
  const MarathonEnrollmentView({super.key});

  @override
  ConsumerState<MarathonEnrollmentView> createState() =>
      _MarathonEnrollmentViewState();
}

class _MarathonEnrollmentViewState
    extends ConsumerState<MarathonEnrollmentView> {
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String _selectedDistance = '6KM';

  // ── Backend logic (unchanged) ─────────────────────────────────
  Future<void> _enroll() async {
    final username = _usernameController.text.trim();
    final pin = _pinController.text.trim();

    if (username.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a username and a 4-digit PIN')),
      );
      return;
    }

    if (pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN must be exactly 4 digits')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final marathonService = ref.read(marathonServiceProvider);
      final participant = await marathonService.getParticipant(username);

      if (participant == null) {
        await marathonService.enrollUser(username, _selectedDistance, pin);
        ref.read(marathonCategoryProvider.notifier).state = _selectedDistance;
        ref.read(marathonUsernameProvider.notifier).state = username;
        await saveMarathonEnrollment(username, _selectedDistance);
      } else {
        if (participant.pin == pin) {
          ref.read(marathonCategoryProvider.notifier).state =
              participant.category;
          ref.read(marathonUsernameProvider.notifier).state = username;
          await saveMarathonEnrollment(username, participant.category);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username taken or incorrect PIN.')),
          );
          return;
        }
      }
    } catch (e) {
      debugPrint('Enrollment error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error enrolling: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: Column(
        children: [
          // ── 1. Hero Image ─────────────────────────────────────
          SizedBox(
            height: 201,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                SvgPicture.asset(
                  'assets/ghm/theme02.svg',
                  fit: BoxFit.cover,
                ),

                // Back button
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, top: 10),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 47,
                          height: 47,

                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: Color(0xFFB2B8BF),
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: SvgPicture.asset(
                            'assets/ghm/iconback.svg', // Path to your SVG
                            width: 16,
                            height: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 2. White body ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Headline
                  const Text(
                    'Join Guwahati Half Marathon\nLeaderboard',
                    style: TextStyle(
                      fontFamily: AppTheme.fontUnivers,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMain,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Subtitle
                  const Text(
                    'Ready to leave your mark on the track?',
                    style: TextStyle(
                      fontFamily: AppTheme.fontGeneralSans,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textSecondary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Input card ────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF3F3F3),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFFE8E8E8),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username
                        _fieldLabel('Claim your racer name'),
                        const SizedBox(height: 6),
                        _inputField(
                          controller: _usernameController,
                          hint: 'sanjay@123',
                        ),
                        const SizedBox(height: 16),

                        // PIN
                        _fieldLabel('Enter 4 digit pin'),
                        const SizedBox(height: 6),
                        _inputField(
                          controller: _pinController,
                          hint: '. . . .',
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          maxLength: 4,
                        ),
                        const SizedBox(height: 20),

                        // Category
                        _fieldLabel('Choose your category'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _categoryCard('6 KM', '6KM')),
                            const SizedBox(width: 12),
                            Expanded(child: _categoryCard('21 KM', '21KM')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Register button ───────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: _isLoading ? null : _enroll,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isLoading) ...[
                                  const SizedBox(
                                    width: 21,
                                    height: 21,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ] else ...[
                                  const Icon(
                                    Icons.person_add_alt_1_rounded,
                                    size: 21,
                                    color: Color(0xFFEDEFF0),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Register',
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontGeneralSans,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Field label ───────────────────────────────────────────────
  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: AppTheme.fontGeneralSans,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black,
        height: 1.14,
      ),
    );
  }

  // ── Input field ───────────────────────────────────────────────
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int? maxLength,
  }) {
    return Theme(
      data: ThemeData.light().copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppTheme.primaryBlue,
          selectionColor: Color(0x33002B5B),
          selectionHandleColor: AppTheme.primaryBlue,
        ),
      ),
      child: Container(

        decoration: ShapeDecoration(
          color: const Color(0xFFE8E8E8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLength: maxLength,
          cursorColor: AppTheme.textSecondary,
          style: const TextStyle(
            fontFamily: AppTheme.fontGeneralSans,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppTheme.textMain,
            height: 1.4,
          ),
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            hintStyle: const TextStyle(
              fontFamily: AppTheme.fontGeneralSans,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            filled: true,
            fillColor: Colors.transparent,
          ),
        ),
      ),
    );
  }

  // ── Category card ─────────────────────────────────────────────
  Widget _categoryCard(String label, String key) {
    final isSelected = _selectedDistance == key;

    return GestureDetector(
      onTap: () => setState(() => _selectedDistance = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: ShapeDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          shape: RoundedRectangleBorder(
            side: isSelected
                ? BorderSide.none
                : const BorderSide(width: 1, color: Color(0xFFE8E8E8)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontGeneralSans,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}