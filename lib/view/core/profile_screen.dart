import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:techniche26/providers/user_provider.dart';
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

  final List<String> _years = ['1st Year', '2nd Year', '3rd Year', '4th Year', '5th Year', 'Other'];
  final List<String> _programs = ['B.Tech', 'B.Des', 'M.Tech', 'Ph.D', 'M.Sc', 'M.Des', 'Other'];

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
            // Sync FCM
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
        showMessage(context, "Google Sign-In failed due to an internet or connection issue.", isError: true);
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
        fullName = '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim();
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
        showMessage(context, "Apple Sign-In failed due to an internet or connection issue.", isError: true);
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
          style: TextStyle(fontFamily: AppTheme.fontUnivers, fontWeight: FontWeight.bold),
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
        if (mounted) showMessage(context, "Privacy Policy: https://techniche.org.in/privacy");
      }
    } catch (_) {
      if (mounted) showMessage(context, "Privacy Policy: https://techniche.org.in/privacy");
    }
  }


  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: const Text('MY PROFILE'),
        elevation: 0,
        backgroundColor: AppTheme.backgroundGray,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: user.isAuthenticated
            ? (_isEditing || !user.profileCompleted
                ? _buildEditProfileForm(user)
                : _buildProfileDetailsView(user))
            : _buildGuestView(),
      ),
    );
  }

  // ──── GUEST VIEW ────
  Widget _buildGuestView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_circle_outlined,
                size: 80,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Guest Mode',
              style: TextStyle(
                fontFamily: AppTheme.fontUnivers,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMain,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You are currently exploring the app as a guest. Please log in to complete your profile, register for events, workshops, and manage your account.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontGeneralSans,
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
            if (_isLoading)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              )
            else ...[
              ElevatedButton(
                onPressed: _handleGoogleSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.textMain,
                  side: BorderSide(color: Colors.grey.shade300),
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                      height: 20,
                      width: 20,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.g_mobiledata, size: 20, color: Colors.blue);
                      },
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Sign In with Google',
                      style: TextStyle(
                        fontFamily: AppTheme.fontGeneralSans,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              if (Theme.of(context).platform == TargetPlatform.iOS) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: 230,
                  child: SignInWithAppleButton(
                    onPressed: _handleAppleSignIn,
                    style: SignInWithAppleButtonStyle.black,
                    borderRadius: BorderRadius.circular(12),
                    height: 48,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  // ──── DETAILS VIEW ────
  Widget _buildProfileDetailsView(UserState user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Profile Card Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontUnivers,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontUnivers,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontGeneralSans,
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Academic / Personal details
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Academic Details',
                  style: TextStyle(
                    fontFamily: AppTheme.fontUnivers,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMain,
                  ),
                ),
                const Divider(height: 24),
                _buildDetailRow('Roll Number', user.rollNumber, Icons.badge),
                _buildDetailRow('College Email', user.collegeEmail, Icons.alternate_email),
                _buildDetailRow('Program & Year', '${user.program} - ${user.year}', Icons.school),
                _buildDetailRow('Branch', user.branch, Icons.book),
                _buildDetailRow('Phone', user.phone, Icons.phone),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _populateFields();
                    setState(() => _isEditing = true);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryBlue),
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
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await ref.read(userProvider.notifier).signOut();
                    if (context.mounted) {
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
          // Delete Account Button (App Store Guideline 5.1.1(v) compliance)
          TextButton.icon(
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
          const SizedBox(height: 4),
          // Privacy Policy Link
          TextButton(
            onPressed: _openPrivacyPolicy,
            child: const Text(
              'Privacy Policy',
              style: TextStyle(
                fontFamily: AppTheme.fontGeneralSans,
                color: AppTheme.textSecondary,
                fontSize: 12,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontGeneralSans,
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : 'Not provided',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontGeneralSans,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──── EDIT/COMPLETE VIEW ────
  Widget _buildEditProfileForm(UserState user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.profileCompleted ? 'Update Profile' : 'Complete Your Profile',
              style: const TextStyle(
                fontFamily: AppTheme.fontUnivers,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMain,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Please fill out these details to register for comedy night and other exclusive event privileges.',
              style: TextStyle(
                fontFamily: AppTheme.fontGeneralSans,
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            _buildFormTextField('Full Name', _nameCtrl, Icons.person, (val) {
              if (val == null || val.trim().isEmpty) return 'Enter your name';
              return null;
            }),
            _buildFormTextField('Roll Number', _rollCtrl, Icons.badge, (val) {
              if (val == null || val.trim().isEmpty) return 'Enter your IITG Roll number';
              return null;
            }),
            _buildFormTextField('College Email', _emailCtrl, Icons.email, (val) {
              if (val == null || val.trim().isEmpty) return 'Enter your college email';
              if (!val.trim().endsWith('@iitg.ac.in')) return 'Email must end with @iitg.ac.in';
              return null;
            }),
            _buildFormTextField('Branch', _branchCtrl, Icons.book, (val) {
              if (val == null || val.trim().isEmpty) return 'Enter your academic branch (e.g. CSE)';
              return null;
            }),
            _buildFormTextField('Phone Number', _phoneCtrl, Icons.phone, (val) {
              if (val == null || val.trim().isEmpty) return 'Enter your contact number';
              return null;
            }, keyboardType: TextInputType.phone),

            const SizedBox(height: 12),
            // Dropdowns
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Year',
                        style: TextStyle(
                          fontFamily: AppTheme.fontGeneralSans,
                          color: AppTheme.textMain,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedYear,
                            dropdownColor: Colors.white,
                            style: const TextStyle(
                              fontFamily: AppTheme.fontGeneralSans,
                              color: AppTheme.textMain,
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
                      const Text(
                        'Program',
                        style: TextStyle(
                          fontFamily: AppTheme.fontGeneralSans,
                          color: AppTheme.textMain,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedProgram,
                            dropdownColor: Colors.white,
                            style: const TextStyle(
                              fontFamily: AppTheme.fontGeneralSans,
                              color: AppTheme.textMain,
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
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
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
                            final success = await ref.read(userProvider.notifier).completeProfile(
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
                    : const Text('Save Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            if (user.profileCompleted) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: Colors.black54, fontSize: 16)),
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
    String? Function(String?)? validator, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppTheme.fontGeneralSans,
              color: AppTheme.textMain,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppTheme.textMain),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppTheme.primaryBlue),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
