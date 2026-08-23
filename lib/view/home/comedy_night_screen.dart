import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../../providers/user_provider.dart';
import '../../providers/comedy_provider.dart';
import '../../utils/errorHandler.dart';
import '../../constant/appTheme.dart';

import 'widgets/comedy_pre_registration_view.dart';
import 'widgets/comedy_waitlist_ticket_view.dart';
import 'widgets/comedy_confirmed_ticket_view.dart';

class ComedyNightScreen extends ConsumerStatefulWidget {
  static const String routeName = '/comedy-night';
  const ComedyNightScreen({super.key});

  @override
  ConsumerState<ComedyNightScreen> createState() => _ComedyNightScreenState();
}

class _ComedyNightScreenState extends ConsumerState<ComedyNightScreen> {
  bool _isRemoteConfigLoading = true;

  // Timer & Registration Remote Config states
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
        ref.read(comedyProvider.notifier).fetchRegistrationStatus();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// Read Firebase Remote Config parameters for registration window & start time
  Future<void> _fetchRemoteConfig() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      if (!kIsWeb) {
        await remoteConfig.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(seconds: 5),
        ));
        await remoteConfig.setDefaults({
          'comedy_registration_open': false,
          'comedy_registration_start_time': '2026-08-29T20:00:00Z',
        });
        await remoteConfig.fetchAndActivate();
      }

      final openVal = remoteConfig.getBool('comedy_registration_open');
      final timeStr = remoteConfig.getString('comedy_registration_start_time');

      setState(() {
        _registrationOpen = openVal;
        if (timeStr.isNotEmpty) {
          _registrationStartTime = DateTime.tryParse(timeStr);
        } else {
          _registrationStartTime = null;
        }
        _isRemoteConfigLoading = false;
      });

      _startTimer();
    } catch (e) {
      debugPrint('Error fetching Firebase Remote Config: $e');
      setState(() {
        _registrationOpen = false;
        _isRemoteConfigLoading = false;
      });
    }
  }

  /// Start live countdown timer if start time is set
  void _startTimer() {
    _countdownTimer?.cancel();
    if (_registrationStartTime == null || _registrationOpen) return;

    final initialDiff = _registrationStartTime!.difference(DateTime.now());
    if (initialDiff.isNegative) {
      // Re-verify with Remote Config before enabling registration to prevent device clock tampering
      _fetchRemoteConfig();
      return;
    }

    setState(() {
      _timeLeft = initialDiff;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final diff = _registrationStartTime!.difference(now);

      if (diff.isNegative) {
        timer.cancel();
        // Re-verify with Remote Config server status when timer finishes
        _fetchRemoteConfig();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppTheme.darkPageBg : AppTheme.lightPageBg;
    final textPrimary =
        isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Standard App Header
            _buildHeader(context, textPrimary),

            // Main Body Content (Switches between Pre-reg, Waitlist, Confirmed)
            Expanded(
              child: comedyState.isLoading || _isRemoteConfigLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryBlue),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: _buildBodyContent(
                          context, isDark, userState, comedyState),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // APP HEADER
  // ─────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Icon(
              Icons.chevron_left_rounded,
              color: textPrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Comedy Night',
              style: TextStyle(
                color: textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: AppTheme.fontUnivers,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [

                Text(
                  'TECHNICHE 26',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppTheme.fontUnivers,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // BODY CONTENT SWITCHER
  // ─────────────────────────────────────────────────────────────
  Widget _buildBodyContent(
    BuildContext context,
    bool isDark,
    UserState userState,
    ComedyState comedyState,
  ) {
    // 1. Auth Gate: User not logged in
    if (!userState.isAuthenticated) {
      return _buildLoginRequiredView(context, isDark);
    }

    // 2. Auth Gate: User profile incomplete
    if (!userState.profileCompleted) {
      return _buildProfileRequiredView(context, isDark);
    }

    // 3. User Registered & Pass Confirmed View
    if (comedyState.registered && comedyState.status == 'CONFIRMED') {
      return ComedyConfirmedTicketView(
        isDark: isDark,
        userState: userState,
        comedyState: comedyState,
        onRefreshTap: () {
          ref
              .read(comedyProvider.notifier)
              .fetchRegistrationStatus(force: true);
          showMessage(context, 'Pass status refreshed.');
        },
      );
    }

    // 4. User Registered & Waitlist / Pass Review View
    if (comedyState.registered) {
      return ComedyWaitlistTicketView(
        isDark: isDark,
        userState: userState,
        comedyState: comedyState,
        onRefreshTap: () {
          ref
              .read(comedyProvider.notifier)
              .fetchRegistrationStatus(force: true);
          showMessage(context, 'Pass status refreshed.');
        },
      );
    }

    // 5. Pre-Registration View (Timer / Opening Soon / Register Now)
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ComedyPreRegistrationView(
        isDark: isDark,
        registrationOpen: _registrationOpen,
        registrationStartTime: _registrationStartTime,
        timeLeft: _timeLeft,
        comedyState: comedyState,
        onRegisterTap: () async {
          // Verify with Firebase Remote Config to prevent device clock tampering attacks
          if (!kIsWeb) {
            try {
              final remoteConfig = FirebaseRemoteConfig.instance;
              await remoteConfig.fetchAndActivate();
              final isReallyOpen =
                  remoteConfig.getBool('comedy_registration_open');
              if (!isReallyOpen) {
                if (mounted) {
                  setState(() {
                    _registrationOpen = false;
                  });
                  showMessage(
                      context, "Registration has not opened yet on the server.",
                      isError: true);
                }
                return;
              }
            } catch (e) {
              debugPrint(
                  'Error verifying Remote Config on registration tap: $e');
            }
          }
          await ref.read(comedyProvider.notifier).registerForComedy(context);
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // AUTH GATE VIEWS (LOGIN & PROFILE REQUIRED)
  // ─────────────────────────────────────────────────────────────
  Widget _buildLoginRequiredView(BuildContext context, bool isDark) {
    final textPrimary =
        isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textSecondary =
        isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryBlue.withOpacity(0.12),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              size: 64,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'SIGN IN REQUIRED',
            style: TextStyle(
              fontFamily: AppTheme.fontUnivers,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sign in to your Techniche account to view and claim exclusive Comedy Night passes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontGeneralSans,
              fontSize: 14,
              color: textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: const Text(
                'Go to Profile / Sign In',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTheme.fontUnivers,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRequiredView(BuildContext context, bool isDark) {
    final textPrimary =
        isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textSecondary =
        isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryBlue.withOpacity(0.12),
            ),
            child: const Icon(
              Icons.assignment_ind_outlined,
              size: 64,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'COMPLETE YOUR PROFILE',
            style: TextStyle(
              fontFamily: AppTheme.fontUnivers,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please complete your student profile details (Roll Number, Branch, College Email) to claim your Comedy Night pass.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontGeneralSans,
              fontSize: 14,
              color: textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
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
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTheme.fontUnivers,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
