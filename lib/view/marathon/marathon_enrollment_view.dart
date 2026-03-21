import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/marathon_provider.dart';
import '../../utils/animate_gradient_background.dart';

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
  String _selectedDistance = '6KM'; // Default

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
      // Check if enrolled, if not insert, then update provider
      final participant = await marathonService.getParticipant(username);

      if (participant == null) {
        // New user
        await marathonService.enrollUser(username, _selectedDistance, pin);
        ref.read(marathonCategoryProvider.notifier).state = _selectedDistance;
        ref.read(marathonUsernameProvider.notifier).state = username;
        // Persist enrollment
        await saveMarathonEnrollment(username, _selectedDistance);
      } else {
        // Existing user check pin
        if (participant.pin == pin) {
          ref.read(marathonCategoryProvider.notifier).state =
              participant.category;
          ref.read(marathonUsernameProvider.notifier).state = username;
          // Persist enrollment
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const AnimatedGradientBackground(),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.0),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'JOIN GUWAHATI HALF MARATHON',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Text(
                          'LEADERBOARD',
                          style: TextStyle(
                            color: Color(0xFF00E5FF),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ready to leave your mark on the track?',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Claim your racer name',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Text Field Username
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF161B22),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: TextField(
                            controller: _usernameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'e.g., RunnerPro99',
                              hintStyle: TextStyle(color: Colors.grey[600]),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Text Field PIN
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Enter 4-Digit PIN',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF161B22),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: TextField(
                            controller: _pinController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            maxLength: 4,
                            style: const TextStyle(
                                color: Colors.white,
                                letterSpacing: 8,
                                fontSize: 18),
                            decoration: InputDecoration(
                              hintText: '••••',
                              counterText: '',
                              hintStyle: TextStyle(
                                  color: Colors.grey[600], letterSpacing: 8),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Choose your category',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedDistance = '6KM'),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  decoration: BoxDecoration(
                                    color: _selectedDistance == '6KM'
                                        ? const Color(0xFF0D2530)
                                        : const Color(0xFF23242B),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.blueAccent.withOpacity(0.10),
                                        blurRadius: 24,
                                      ),
                                    ],
                                    border: Border.all(
                                      color: _selectedDistance == '6KM'
                                          ? const Color(0xFF00E5FF)
                                          : Colors.blueAccent.withOpacity(0.18),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Column(
                                    children: [
                                      Text('6KM',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedDistance = '21KM'),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  decoration: BoxDecoration(
                                    color: _selectedDistance == '21KM'
                                        ? const Color(0xFF0D2530)
                                        : const Color(0xFF23242B),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.blueAccent.withOpacity(0.10),
                                        blurRadius: 24,
                                      ),
                                    ],
                                    border: Border.all(
                                      color: _selectedDistance == '21KM'
                                          ? const Color(0xFF00E5FF)
                                          : Colors.blueAccent.withOpacity(0.18),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Column(
                                    children: [
                                      Text('21KM',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),

                        // Enroll Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _enroll,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E5FF),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 10,
                              shadowColor:
                                  const Color(0xFF00E5FF).withOpacity(0.5),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.black)
                                : const Text(
                                    'ENROLL NOW',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pushNamed(
                                context, '/ghm-registration'),
                            child: const Text(
                              'Register for the official GHM event here 🏃‍♂️',
                              style: TextStyle(
                                  color: Color(0xFF00E5FF),
                                  fontSize: 14,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Username will be visible on leaderboard.',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 13),
                          ),
                        ),
                      ],
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
}
