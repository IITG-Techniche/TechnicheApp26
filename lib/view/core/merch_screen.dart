import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constant/appTheme.dart';
import 'package:animated_glitch/animated_glitch.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class MerchScreen extends StatefulWidget {
  static const String routeName = '/merch';
  const MerchScreen({Key? key}) : super(key: key);

  @override
  State<MerchScreen> createState() => _MerchScreenState();
}

class _MerchScreenState extends State<MerchScreen> {
  late final PageController _pageController;

  final AnimatedGlitchController _glitchController = AnimatedGlitchController(
    frequency: const Duration(milliseconds: 160),
    level: 1.8,
    distortionShift: const DistortionShift(count: 4),
  );

  Timer? _autoScrollTimer;
  bool _glitchActive = false;

  final List<Map<String, String>> merchItems = [
    {
      "title": "Glitched GameBoy",
      "image": "assets/glitched.png",
      "model": "assets/MerchBlack.glb",
      "price": "₹449",
      "description":
          "When circuits fry but style survives. It’s rebellious, loud, and built for those who’d rather crash the system than play by its rules.",
    },
    {
      "title": "Glorified GoodBoy",
      "image": "assets/goodboy.png",
      "model": "assets/merchself.glb",
      "price": "₹399",
      "description":
          "Channeling collective consciousness, algorithms, and aesthetics that scream main character energy. Rock it, & Beyond the club, you are the vibe.",
    },
  ];

  final String orderFormUrl = "https://forms.gle/87Zf6bjNXU8hwwAdA";

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: merchItems.length * 1000);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (var item in merchItems) {
        if (item['image'] != null) {
          precacheImage(AssetImage(item['image']!), context);
        }
      }
      if (mounted) {
        _startAutoScroll();
      }
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_pageController.hasClients || !mounted) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  void _startGlitchIfNeeded() {
    if (!_glitchActive) {
      _glitchActive = true;
      _glitchController.start();
    }
  }

  void _stopGlitchIfNeeded() {
    if (_glitchActive) {
      _glitchActive = false;
      _glitchController.stop();
    }
  }

  Future<void> _launchURL() async {
    final Uri url = Uri.parse(orderFormUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $url");
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _glitchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: SizedBox(
          width: screenWidth * 0.4,
          child: Image.asset(
            'assets/logo_withoutBG.png',
            fit: BoxFit.contain,
            color: AppTheme.primaryBlue,
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          const _AnimatedGradientBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Merchandise',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMain,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Roam around the campus in style! Browse and buy official Techniche merchandise.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollStartNotification) {
                          _startGlitchIfNeeded();
                        } else if (notification is ScrollEndNotification) {
                          Future.delayed(const Duration(milliseconds: 100), () {
                            _stopGlitchIfNeeded();
                          });
                        }
                        return false;
                      },
                      child: PageView.builder(
                        controller: _pageController,
                        itemBuilder: (context, index) {
                          final item = merchItems[index % merchItems.length];
                          return _merchCard(
                            title: item["title"]!,
                            imagePath: item["image"],
                            modelPath: item["model"],
                            price: item["price"]!,
                            description: item["description"]!,
                            onBuy: _launchURL,
                          );
                        },
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

  Widget _merchCard({
    required String title,
    String? imagePath,
    String? modelPath,
    required String price,
    required String description,
    required VoidCallback onBuy,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 320,
              height: 320,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: modelPath != null
                    ? ModelViewer(
                        src: modelPath,
                        alt: "3D Shirt Model",
                        autoRotate: true,
                        // cameraControls: true,
                        rotationPerSecond: "20deg",
                        autoRotateDelay: 0,
                        disableZoom: true,
                        backgroundColor: Colors.transparent,
                      )
                    : AnimatedGlitch(
                        controller: _glitchController,
                        showColorChannels: true,
                        showDistortions: true,
                        child: Image.asset(
                          imagePath!,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                        ),
                      ),
              ),
            ),
            // const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textMain,
                letterSpacing: 0.5,
              ),
            ),
            // const SizedBox(height: 6),
            Text(
              price,
              style: const TextStyle(
                fontSize: 18,
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade800,
                    Colors.grey.shade900,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: null, // Disabled
                icon: const Icon(Icons.remove_shopping_cart,
                    color: Colors.white38),
                label: const Text(
                  "SOLD OUT",
                  style: TextStyle(color: Color.fromARGB(97, 224, 25, 25)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white38,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------------------
  Background Gradient
----------------------------*/
class _AnimatedGradientBackground extends StatefulWidget {
  const _AnimatedGradientBackground({Key? key}) : super(key: key);
  @override
  State<_AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<_AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<List<Color>> gradients = [
    [Color(0xFFB0BEC5), Color(0xFFCFD8DC), Color(0xFFECEFF1)],
    [Color(0xFFCFD8DC), Color(0xFFECEFF1), Color(0xFFB0BEC5)],
    [Color(0xFFECEFF1), Color(0xFFCFD8DC), Color(0xFFB0BEC5)],
    [Color(0xFFB0BEC5), Color(0xFFECEFF1), Color(0xFFCFD8DC)],
  ];
  int _currentGradient = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _currentGradient = (_currentGradient + 1) % gradients.length;
              _controller.forward(from: 0);
            }
          });
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextGradient = gradients[(_currentGradient + 1) % gradients.length];
    final currentGradient = gradients[_currentGradient];
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: List.generate(currentGradient.length, (i) {
                return Color.lerp(
                    currentGradient[i], nextGradient[i], _animation.value)!;
              }),
            ),
          ),
        );
      },
    );
  }
}
