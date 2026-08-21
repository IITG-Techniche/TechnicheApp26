import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/user_provider.dart';
import '../../providers/comedy_provider.dart';
import '../../utils/errorHandler.dart';
import '../../constant/appTheme.dart';

class ComedyNightScreen extends ConsumerStatefulWidget {
  static const String routeName = '/comedy-night';
  const ComedyNightScreen({super.key});

  @override
  ConsumerState<ComedyNightScreen> createState() => _ComedyNightScreenState();
}

class _ComedyNightScreenState extends ConsumerState<ComedyNightScreen> {
  bool _isRemoteConfigLoading = true;
  
  // Timer config states
  bool _registrationOpen = false;
  DateTime? _registrationStartTime;
  Timer? _countdownTimer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _fetchRemoteConfig();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProvider);
      if (user.isAuthenticated) {
        // Fetch fresh comedy status (it checks SharedPreferences cache internally to prevent spamming!)
        ref.read(comedyProvider.notifier).fetchRegistrationStatus();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
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
      return _buildLoginRequiredView();
    }

    if (!userState.profileCompleted) {
      return _buildProfileRequiredView();
    }

    return _buildEventRegistration(userState, comedyState);
  }

  Widget _buildLoginRequiredView() {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(0.1),
                border: Border.all(color: Colors.purpleAccent.withOpacity(0.2), width: 2),
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.purpleAccent,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Sign In Required',
              style: TextStyle(
                fontFamily: AppTheme.fontUnivers,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'To register for the Comedy Night, you must sign in first. You can log in securely via Google inside the Profile section.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontGeneralSans,
                fontSize: 15,
                color: Colors.white70,
                height: 1.4,
              ),
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
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: const Text(
                  'Go to Profile / Login',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRequiredView() {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(0.1),
                border: Border.all(color: Colors.purpleAccent.withOpacity(0.2), width: 2),
              ),
              child: const Icon(
                Icons.assignment_ind_outlined,
                size: 80,
                color: Colors.purpleAccent,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Complete Your Profile',
              style: TextStyle(
                fontFamily: AppTheme.fontUnivers,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'A completed IITG student profile is required to register for comedy night privileges. Please fill in your Roll Number, Branch, and College Email in your profile screen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontGeneralSans,
                fontSize: 15,
                color: Colors.white70,
                height: 1.4,
              ),
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
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: const Text(
                  'Complete Profile Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
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
                      elevation: comedyState.isLoading ? 0 : 8,
                      shadowColor: Colors.purpleAccent.withOpacity(0.5),
                    ),
                    onPressed: comedyState.isLoading
                        ? null
                        : () async {
                            await ref.read(comedyProvider.notifier).registerForComedy(context);
                          },
                    child: comedyState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'REGISTER NOW',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
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
                  ref.read(comedyProvider.notifier).fetchRegistrationStatus(force: true);
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
