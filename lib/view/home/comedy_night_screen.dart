import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/user_provider.dart';
import '../../providers/comedy_provider.dart';
import '../../utils/errorHandler.dart';

class ComedyNightScreen extends ConsumerStatefulWidget {
  static const String routeName = '/comedy-night';
  const ComedyNightScreen({super.key});

  @override
  ConsumerState<ComedyNightScreen> createState() => _ComedyNightScreenState();
}

class _ComedyNightScreenState extends ConsumerState<ComedyNightScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  bool _isGoogleLoggingIn = false;
  bool _isRemoteConfigLoading = true;
  
  // Timer config states
  bool _registrationOpen = false;
  DateTime? _registrationStartTime;
  Timer? _countdownTimer;
  Duration _timeLeft = Duration.zero;

  // Form keys and controllers
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _rollCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _branchCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  
  String _selectedYear = '3rd Year';
  String _selectedProgram = 'B.Tech';

  final List<String> _years = ['1st Year', '2nd Year', '3rd Year', '4th Year', '5th Year', 'Other'];
  final List<String> _programs = ['B.Tech', 'B.Des', 'M.Tech', 'Ph.D', 'M.Sc', 'M.Des', 'Other'];

  @override
  void initState() {
    super.initState();
    _fetchRemoteConfig();
    
    // Auto-populate form when user profile is updated or loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProvider);
      if (user.isAuthenticated) {
        _nameCtrl.text = user.name;
        _emailCtrl.text = user.collegeEmail.isNotEmpty ? user.collegeEmail : user.email;
        _rollCtrl.text = user.rollNumber;
        _branchCtrl.text = user.branch;
        _phoneCtrl.text = user.phone;
        if (user.year.isNotEmpty && _years.contains(user.year)) {
          _selectedYear = user.year;
        }
        if (user.program.isNotEmpty && _programs.contains(user.program)) {
          _selectedProgram = user.program;
        }
        // Fetch fresh comedy status
        ref.read(comedyProvider.notifier).fetchRegistrationStatus();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _nameCtrl.dispose();
    _rollCtrl.dispose();
    _emailCtrl.dispose();
    _branchCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  /// Initialize and read remote config parameters for the timer
  Future<void> _fetchRemoteConfig() async {
    if (kIsWeb) {
      setState(() {
        _registrationOpen = true; // Open by default on web for testing
        _isRemoteConfigLoading = false;
      });
      return;
    }

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.fetchAndActivate();

      final openVal = remoteConfig.getBool('comedy_registration_open');
      final timeStr = remoteConfig.getString('comedy_registration_start_time');
      
      setState(() {
        _registrationOpen = openVal;
        if (timeStr.isNotEmpty) {
          _registrationStartTime = DateTime.tryParse(timeStr);
        }
        _isRemoteConfigLoading = false;
      });

      _startTimer();
    } catch (e) {
      debugPrint('Error fetching Firebase Remote Config: $e');
      setState(() {
        // Fallback default (open registration)
        _registrationOpen = true;
        _isRemoteConfigLoading = false;
      });
    }
  }

  /// Start countdown timer if registration start time is defined
  void _startTimer() {
    _countdownTimer?.cancel();
    if (_registrationStartTime == null || _registrationOpen) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final diff = _registrationStartTime!.difference(now);

      if (diff.isNegative) {
        timer.cancel();
        setState(() {
          _registrationOpen = true;
          _timeLeft = Duration.zero;
        });
      } else {
        setState(() {
          _timeLeft = diff;
        });
      }
    });
  }

  /// Trigger actual Google Authentication
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoggingIn = true);
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
            // Auto populate details
            final user = ref.read(userProvider);
            _nameCtrl.text = user.name;
            _emailCtrl.text = user.email;
            
            // Sync FCM Token
            final prefs = await SharedPreferences.getInstance();
            final fcm = prefs.getString('fcm_token');
            if (fcm != null && fcm.isNotEmpty) {
              await ref.read(userProvider.notifier).syncFcmToken(fcm);
            }

            // Fetch registration status
            ref.read(comedyProvider.notifier).fetchRegistrationStatus();
          }
        }
      }
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      if (mounted) {
        showMessage(context, "Google login failed: $e", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoggingIn = false);
    }
  }

  /// Developer bypass to authenticate without a working Google setup (e.g. in Emulator)
  Future<void> _developerBypassLogin() async {
    setState(() => _isGoogleLoggingIn = true);
    try {
      final String mockEmail = "comedy_tester@iitg.ac.in";
      final String mockGoogleId = "mock_google_id_1012398";
      final String mockName = "Techniche Tester";

      final success = await ref.read(userProvider.notifier).signInWithGoogle(
        context: context,
        email: mockEmail,
        googleId: mockGoogleId,
        name: mockName,
      );

      if (success && mounted) {
        final user = ref.read(userProvider);
        _nameCtrl.text = user.name;
        _emailCtrl.text = user.email;
        ref.read(comedyProvider.notifier).fetchRegistrationStatus();
      }
    } catch (e) {
      if (mounted) showMessage(context, "Bypass failed: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isGoogleLoggingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final comedyState = ref.watch(comedyProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'COMEDY NIGHT',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontFamily: 'Orbitron',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (userState.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              tooltip: 'Sign Out',
              onPressed: () {
                ref.read(userProvider.notifier).signOut();
                showMessage(context, "Logged out successfully");
              },
            )
        ],
      ),
      body: Stack(
        children: [
          // Background elegant neon glow circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.withOpacity(0.15),
              ),
            ),
          ),

          // Main body content wrapper
          SafeArea(
            child: comedyState.isLoading || _isRemoteConfigLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                    ),
                  )
                : _buildBody(userState, comedyState),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(UserState userState, ComedyState comedyState) {
    if (!userState.isAuthenticated) {
      return _buildLoginView();
    }

    if (!userState.profileCompleted) {
      return _buildProfileForm(userState);
    }

    return _buildEventRegistration(userState, comedyState);
  }

  // ──── 1. LOGIN SCREEN VIEW ────
  Widget _buildLoginView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purple.withOpacity(0.1),
                  border: Border.all(color: Colors.purple.withOpacity(0.3), width: 2),
                ),
                child: const Icon(
                  Icons.theater_comedy,
                  size: 90,
                  color: Colors.purpleAccent,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Unlock Comedy Night',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Univers',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sign in with your Google account to complete your student profile and secure your ticket.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.4,
                  fontFamily: 'General Sans',
                ),
              ),
              const SizedBox(height: 40),
              
              if (_isGoogleLoggingIn)
                const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.purpleAccent))
              else ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  icon: Image.asset(
                    'assets/logo_withoutBG.png', // Assuming we can use this or direct icon
                    width: 22,
                    height: 22,
                    errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, color: Colors.blue, size: 24),
                  ),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _handleGoogleSignIn,
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _developerBypassLogin,
                  child: Text(
                    '[Dev Mode] Bypass Google Login',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ──── 2. PROFILE COMPLETION VIEW ────
  Widget _buildProfileForm(UserState userState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Complete Student Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Univers',
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'All fields are required to register for Comedy Night events.',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 24),

              _buildTextField('Full Name', _nameCtrl, Icons.person, (val) {
                if (val == null || val.trim().isEmpty) return 'Enter your name';
                return null;
              }),
              _buildTextField('Roll Number', _rollCtrl, Icons.badge, (val) {
                if (val == null || val.trim().isEmpty) return 'Enter your IITG Roll number';
                return null;
              }),
              _buildTextField('College Email', _emailCtrl, Icons.email, (val) {
                if (val == null || val.trim().isEmpty) return 'Enter your college email';
                if (!val.contains('@')) return 'Enter a valid email';
                return null;
              }),
              _buildTextField('Branch', _branchCtrl, Icons.book, (val) {
                if (val == null || val.trim().isEmpty) return 'Enter your academic branch (e.g. CSE)';
                return null;
              }),
              _buildTextField('Phone Number', _phoneCtrl, Icons.phone, (val) {
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
                        const Text('Year', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.purple.withOpacity(0.3)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedYear,
                              dropdownColor: Colors.grey[950],
                              style: const TextStyle(color: Colors.white),
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
                        const Text('Program', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.purple.withOpacity(0.3)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedProgram,
                              dropdownColor: Colors.grey[950],
                              style: const TextStyle(color: Colors.white),
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
                    backgroundColor: Colors.purpleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save & Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
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

                      if (success) {
                        // Reload comedy night status
                        ref.read(comedyProvider.notifier).fetchRegistrationStatus();
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
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
          Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.purpleAccent),
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.purple.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.purple.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.purpleAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──── 3. REGISTRATION / TICKET DISPLAY VIEW ────
  Widget _buildEventRegistration(UserState userState, ComedyState comedyState) {
    if (comedyState.registered) {
      return _buildRegisteredTicket(userState, comedyState);
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Banner Poster Mock
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2C003E), Color(0xFF510A32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.theater_comedy, size: 70, color: Colors.purpleAccent),
                    const SizedBox(height: 16),
                    const Text(
                      "TECHNICHE COMEDY NIGHT",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Orbitron',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "An unforgettable night of laughter and fun featuring India's top standup comedians.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withOpacity(0.2)),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors.purpleAccent),
                            SizedBox(width: 6),
                            Text("Sept 5, 2026", style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.purpleAccent),
                            SizedBox(width: 6),
                            Text("Dr. Bhupen Hazarika Auditorium", style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Conditional Display: Timer countdown vs "Register Now" button
              if (!_registrationOpen && _registrationStartTime != null) ...[
                const Text(
                  "REGISTRATION OPENS IN",
                  style: TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 16),
                _buildCountdownTimerWidget(),
                const SizedBox(height: 24),
                // Toggle Button for debug
                TextButton(
                  onPressed: () {
                    setState(() {
                      _registrationOpen = true;
                    });
                  },
                  child: const Text("Bypass Timer (For Testing)", style: TextStyle(color: Colors.purpleAccent, fontSize: 12)),
                ),
              ] else ...[
                const Text(
                  "REGISTRATIONS ARE OPEN!",
                  style: TextStyle(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      shadowColor: Colors.purpleAccent.withOpacity(0.5),
                    ),
                    child: const Text(
                      'REGISTER NOW',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    onPressed: () async {
                      await ref.read(comedyProvider.notifier).registerForComedy(context);
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Visual representations of the countdown widget
  Widget _buildCountdownTimerWidget() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final days = twoDigits(_timeLeft.inDays);
    final hours = twoDigits(_timeLeft.inHours.remainder(24));
    final minutes = twoDigits(_timeLeft.inMinutes.remainder(60));
    final seconds = twoDigits(_timeLeft.inSeconds.remainder(60));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimerBlock(days, 'Days'),
        _buildTimerDivider(),
        _buildTimerBlock(hours, 'Hours'),
        _buildTimerDivider(),
        _buildTimerBlock(minutes, 'Mins'),
        _buildTimerDivider(),
        _buildTimerBlock(seconds, 'Secs'),
      ],
    );
  }

  Widget _buildTimerBlock(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.purple.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.2),
                blurRadius: 8,
              )
            ],
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Orbitron',
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildTimerDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 6.0, right: 6.0, bottom: 20.0),
      child: Text(
        ':',
        style: TextStyle(color: Colors.purpleAccent, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ──── 4. VIRTUAL TICKET PANEL VIEW ────
  Widget _buildRegisteredTicket(UserState userState, ComedyState comedyState) {
    final bool isConfirmed = comedyState.status == 'CONFIRMED';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ticket container
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isConfirmed ? Colors.greenAccent : Colors.amberAccent,
                    width: 2.0,
                  ),
                  color: const Color(0xFF140727),
                  boxShadow: [
                    BoxShadow(
                      color: (isConfirmed ? Colors.greenAccent : Colors.amberAccent).withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "ENTRY TICKET",
                            style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isConfirmed ? Colors.green.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              comedyState.status,
                              style: TextStyle(
                                color: isConfirmed ? Colors.greenAccent : Colors.amberAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Event Information
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "TECHNICHE COMEDY NIGHT",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Orbitron'),
                          ),
                          const SizedBox(height: 6),
                          const Text("Sept 5, 2026 • 7:00 PM onwards", style: TextStyle(color: Colors.white60, fontSize: 13)),
                          const SizedBox(height: 4),
                          const Text("Dr. Bhupen Hazarika Auditorium", style: TextStyle(color: Colors.purpleAccent, fontSize: 13)),
                          
                          const SizedBox(height: 20),
                          Divider(color: Colors.white.withOpacity(0.1)),
                          const SizedBox(height: 12),

                          // Attendee details
                          _buildTicketInfoRow("ATTENDEE", userState.name),
                          _buildTicketInfoRow("ROLL NUMBER", userState.rollNumber),
                          _buildTicketInfoRow("EMAIL", userState.collegeEmail),
                        ],
                      ),
                    ),

                    // Ticket dotted divider line
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Row(
                        children: List.generate(
                          30,
                          (index) => Expanded(
                            child: Container(
                              color: index % 2 == 0 ? Colors.transparent : Colors.white.withOpacity(0.2),
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Code / Barcode section
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0, left: 20, right: 20),
                      child: Column(
                        children: [
                          if (isConfirmed && comedyState.ticketCode != null) ...[
                            // Pseudo barcode representation
                            Container(
                              height: 60,
                              width: double.infinity,
                              color: Colors.white,
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: List.generate(
                                  35,
                                  (index) => Container(
                                    width: (index % 3 == 0) ? 3 : (index % 5 == 0 ? 1 : 2),
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              comedyState.ticketCode!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                                fontFamily: 'Orbitron',
                              ),
                            ),
                          ] else ...[
                            const Icon(Icons.hourglass_empty, color: Colors.amberAccent, size: 40),
                            const SizedBox(height: 10),
                            const Text(
                              "WAITING FOR CONFIRMATION",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Registrations are waitlisted by default. Once confirmed by the organizers, your unique entry barcode will appear here.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              // Refresh status button
              TextButton.icon(
                icon: const Icon(Icons.refresh, color: Colors.purpleAccent),
                label: const Text("Refresh Ticket Status", style: TextStyle(color: Colors.purpleAccent)),
                onPressed: () {
                  ref.read(comedyProvider.notifier).fetchRegistrationStatus();
                  showMessage(context, "Status updated.");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
