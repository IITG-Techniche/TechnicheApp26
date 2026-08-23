import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:techniche26/providers/user_provider.dart';
import 'package:techniche26/providers/theme_provider.dart';
import 'package:techniche26/constant/appTheme.dart';
import 'package:techniche26/utils/errorHandler.dart';
import 'package:techniche26/view/auth/login_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  static const String routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  bool _isEditing = false;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _rollCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _branchCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String _selectedYear = '3rd Year';
  String _selectedProgram = 'B.Tech';
  bool _isSaving = false;

  final List<String> _years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    '5th Year',
    'Other'
  ];
  final List<String> _programs = [
    'B.Tech',
    'B.Des',
    'M.Tech',
    'Ph.D',
    'M.Sc',
    'M.Des',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rollCtrl.dispose();
    _emailCtrl.dispose();
    _branchCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _populateFields() {
    final user = ref.read(userProvider);
    if (user.isAuthenticated) {
      _nameCtrl.text = user.name;
      _emailCtrl.text = user.collegeEmail;
      _rollCtrl.text = user.rollNumber;
      _branchCtrl.text = user.branch;
      _phoneCtrl.text = user.phone;
      if (user.year.isNotEmpty && _years.contains(user.year)) {
        _selectedYear = user.year;
      }
      if (user.program.isNotEmpty && _programs.contains(user.program)) {
        _selectedProgram = user.program;
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        if (mounted) {
          final success = await ref.read(userProvider.notifier).signInWithGoogle(
                context: context,
                email: account.email,
                googleId: account.id,
                name: account.displayName,
              );

          if (success && mounted) {
            final prefs = await SharedPreferences.getInstance();
            final fcm = prefs.getString('fcm_token');
            if (fcm != null && fcm.isNotEmpty) {
              await ref.read(userProvider.notifier).syncFcmToken(fcm);
            }
            await prefs.setBool('seenLoginGate', true);
            _populateFields();
          }
        }
      }
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      if (mounted) {
        showMessage(context,
            "Google Sign-In failed due to an internet or connection issue.",
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      String? fullName;
      if (credential.givenName != null || credential.familyName != null) {
        fullName =
            '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim();
        if (fullName.isEmpty) fullName = null;
      }

      if (mounted) {
        final success = await ref.read(userProvider.notifier).signInWithApple(
              context: context,
              appleId: credential.userIdentifier ?? '',
              email: credential.email,
              name: fullName,
              identityToken: credential.identityToken,
            );

        if (success && mounted) {
          final prefs = await SharedPreferences.getInstance();
          final fcm = prefs.getString('fcm_token');
          if (fcm != null && fcm.isNotEmpty) {
            await ref.read(userProvider.notifier).syncFcmToken(fcm);
          }
          await prefs.setBool('seenLoginGate', true);
          _populateFields();
        }
      }
    } catch (e) {
      debugPrint("Apple Sign-In Error: $e");
      if (mounted) {
        showMessage(context,
            "Apple Sign-In failed due to an internet or connection issue.",
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmAndDeleteAccount() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Delete Account',
          style: TextStyle(
              fontFamily: AppTheme.fontUnivers, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to permanently delete your account and remove all your data? This action cannot be undone.',
          style: TextStyle(fontFamily: AppTheme.fontGeneralSans, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(userProvider.notifier).deleteAccount(context);
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          LoginScreen.routeName,
          (route) => false,
        );
      }
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final Uri url = Uri.parse('https://techniche.org.in/privacy');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          showMessage(context, "Privacy Policy: https://techniche.org.in/privacy");
        }
      }
    } catch (_) {
      if (mounted) {
        showMessage(context, "Privacy Policy: https://techniche.org.in/privacy");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final backgroundColor =
        isDark ? const Color(0xFF070B19) : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: const Text('MY PROFILE'),
        elevation: 0,
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: user.isAuthenticated && (_isEditing || !user.profileCompleted)
            ? _buildEditProfileForm(user, isDark)
            : _buildProfileMainView(user, isDark),
      ),
    );
  }

  // ──── MAIN PROFILE VIEW ────
  Widget _buildProfileMainView(UserState user, bool isDark) {
    final cardColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : AppTheme.textMain;
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. User Header or Guest Card
          if (user.isAuthenticated)
            _buildUserHeaderCard(user, cardColor, borderColor, textPrimary, textSecondary, isDark)
          else
            _buildGuestPromptCard(cardColor, borderColor, textPrimary, textSecondary, isDark),

          const SizedBox(height: 20),

          // 2. Academic / Personal Details (Only if Authenticated & Complete)
          if (user.isAuthenticated && user.profileCompleted) ...[
            _buildAcademicDetailsCard(user, cardColor, borderColor, textPrimary, textSecondary),
            const SizedBox(height: 24),
          ],

          // 3. Account & Auth Actions
          if (user.isAuthenticated) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _populateFields();
                      setState(() => _isEditing = true);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF3B82F6)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontFamily: AppTheme.fontGeneralSans,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref.read(userProvider.notifier).signOut();
                      if (mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          LoginScreen.routeName,
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontFamily: AppTheme.fontGeneralSans,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: _confirmAndDeleteAccount,
                icon: const Icon(Icons.delete_forever_rounded, size: 18, color: Colors.red),
                label: const Text(
                  'Delete Account',
                  style: TextStyle(
                    fontFamily: AppTheme.fontGeneralSans,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Privacy Policy Link
          Center(
            child: TextButton(
              onPressed: _openPrivacyPolicy,
              child: Text(
                'Privacy Policy',
                style: TextStyle(
                  fontFamily: AppTheme.fontGeneralSans,
                  color: textSecondary,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ──── USER HEADER CARD ────
  Widget _buildUserHeaderCard(
    UserState user,
    Color cardColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black45 : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: const Color(0xFF3B82F6).withOpacity(0.15),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontFamily: AppTheme.fontUnivers,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.isNotEmpty ? user.name : 'Techniche Participant',
                  style: TextStyle(
                    fontFamily: AppTheme.fontUnivers,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  user.email.isNotEmpty ? user.email : user.collegeEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontGeneralSans,
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──── GUEST PROMPT CARD ────
  Widget _buildGuestPromptCard(
    Color cardColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black45 : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF3B82F6).withOpacity(0.12),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 32,
              color: Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Guest Mode',
            style: TextStyle(
              fontFamily: AppTheme.fontUnivers,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sign in to complete your profile, register for events, and manage workshop bookings.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontGeneralSans,
              fontSize: 13,
              color: textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            )
          else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleGoogleSignIn,
                icon: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                  height: 18,
                  width: 18,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.g_mobiledata, size: 20, color: Colors.blue),
                ),
                label: const Text('Sign In with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  foregroundColor: textPrimary,
                  side: BorderSide(color: borderColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (Theme.of(context).platform == TargetPlatform.iOS) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SignInWithAppleButton(
                  onPressed: _handleAppleSignIn,
                  style: isDark
                      ? SignInWithAppleButtonStyle.white
                      : SignInWithAppleButtonStyle.black,
                  borderRadius: BorderRadius.circular(12),
                  height: 44,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ──── ACADEMIC DETAILS CARD ────
  Widget _buildAcademicDetailsCard(
    UserState user,
    Color cardColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Academic Details',
            style: TextStyle(
              fontFamily: AppTheme.fontUnivers,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const Divider(height: 20),
          _buildDetailRow('Roll Number', user.rollNumber, Icons.badge_outlined, textPrimary, textSecondary),
          _buildDetailRow('College Email', user.collegeEmail, Icons.alternate_email, textPrimary, textSecondary),
          _buildDetailRow('Program & Year', '${user.program} - ${user.year}', Icons.school_outlined, textPrimary, textSecondary),
          _buildDetailRow('Branch', user.branch, Icons.book_outlined, textPrimary, textSecondary),
          _buildDetailRow('Phone', user.phone, Icons.phone_outlined, textPrimary, textSecondary),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTheme.fontGeneralSans,
                    fontSize: 11,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value.isNotEmpty ? value : 'Not provided',
                  style: TextStyle(
                    fontFamily: AppTheme.fontGeneralSans,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──── EDIT/COMPLETE FORM ────
  Widget _buildEditProfileForm(UserState user, bool isDark) {
    final textPrimary = isDark ? Colors.white : AppTheme.textMain;
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.profileCompleted ? 'Update Profile' : 'Complete Your Profile',
              style: TextStyle(
                fontFamily: AppTheme.fontUnivers,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Please fill out these details to register for comedy night and other exclusive event privileges.',
              style: TextStyle(
                fontFamily: AppTheme.fontGeneralSans,
                fontSize: 13,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            _buildFormTextField('Full Name', _nameCtrl, Icons.person, (val) {
              if (val == null || val.trim().isEmpty) return 'Enter your name';
              return null;
            }, isDark),
            _buildFormTextField('Roll Number', _rollCtrl, Icons.badge, (val) {
              if (val == null || val.trim().isEmpty) return 'Enter your IITG Roll number';
              return null;
            }, isDark),
            _buildFormTextField('College Email', _emailCtrl, Icons.email, (val) {
              if (val == null || val.trim().isEmpty) return 'Enter your college email';
              if (!val.trim().endsWith('@iitg.ac.in')) return 'Email must end with @iitg.ac.in';
              return null;
            }, isDark),
            _buildFormTextField('Branch', _branchCtrl, Icons.book, (val) {
              if (val == null || val.trim().isEmpty) return 'Enter your academic branch (e.g. CSE)';
              return null;
            }, isDark),
            _buildFormTextField('Phone Number', _phoneCtrl, Icons.phone, (val) {
              if (val == null || val.trim().isEmpty) return 'Enter your contact number';
              return null;
            }, isDark, keyboardType: TextInputType.phone),

            const SizedBox(height: 12),
            // Dropdowns
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Year',
                        style: TextStyle(
                          fontFamily: AppTheme.fontGeneralSans,
                          color: textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedYear,
                            dropdownColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                            style: TextStyle(
                              fontFamily: AppTheme.fontGeneralSans,
                              color: textPrimary,
                            ),
                            items: _years.map((y) {
                              return DropdownMenuItem(value: y, child: Text(y));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedYear = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Program',
                        style: TextStyle(
                          fontFamily: AppTheme.fontGeneralSans,
                          color: textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedProgram,
                            dropdownColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                            style: TextStyle(
                              fontFamily: AppTheme.fontGeneralSans,
                              color: textPrimary,
                            ),
                            items: _programs.map((p) {
                              return DropdownMenuItem(value: p, child: Text(p));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedProgram = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSaving
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isSaving = true);
                          try {
                            final success = await ref
                                .read(userProvider.notifier)
                                .completeProfile(
                                  context: context,
                                  name: _nameCtrl.text.trim(),
                                  rollNumber: _rollCtrl.text.trim(),
                                  collegeEmail: _emailCtrl.text.trim(),
                                  year: _selectedYear,
                                  branch: _branchCtrl.text.trim(),
                                  program: _selectedProgram,
                                  phone: _phoneCtrl.text.trim(),
                                );

                            if (success && mounted) {
                              setState(() {
                                _isEditing = false;
                              });
                            }
                          } finally {
                            if (mounted) setState(() => _isSaving = false);
                          }
                        }
                      },
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Save Details',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            if (user.profileCompleted) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: isDark ? const Color(0xFF334155) : Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Cancel',
                      style: TextStyle(color: textSecondary, fontSize: 16)),
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                  },
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFormTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    String? Function(String?)? validator,
    bool isDark, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    final textPrimary = isDark ? Colors.white : AppTheme.textMain;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontGeneralSans,
              color: textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            style: TextStyle(color: textPrimary),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF3B82F6)),
              filled: true,
              fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF3B82F6)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
