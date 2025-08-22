import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animated_glitch/animated_glitch.dart';

class MerchScreen extends StatefulWidget {
  static const String routeName = '/merch';
  const MerchScreen({Key? key}) : super(key: key);

  @override
  State<MerchScreen> createState() => _MerchScreenState();
}

class _MerchScreenState extends State<MerchScreen> {
  // initialize controller in initState so we can set a large initial page for a circular feel
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
      "price": "₹449",
      "description":
          "When circuits fry but style survives. It’s rebellious, loud, and built for those who’d rather crash the system than play by its rules."
    },
    {
      "title": "Glorified GoodBoy",
      "image": "assets/goodboy.png",
      "price": "₹399",
      "description":
          "Channeling collective consciousness, algorithms, and aesthetics that scream main character energy. Rock it, & you’re not just in the club, you are the vibe."
    },
  ];

  final String orderFormUrl = "https://forms.gle/87Zf6bjNXU8hwwAdA";

  @override
  void initState() {
    super.initState();

    // start at a large page so nextPage feels "infinite" (round-and-round)
    _pageController = PageController(initialPage: merchItems.length * 1000);

    // Precache asset images after first frame to avoid flicker
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var item in merchItems) {
        precacheImage(AssetImage(item['image']!), context);
      }
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!_pageController.hasClients || !mounted) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  // void _stopAutoScroll() {
  //   _autoScrollTimer?.cancel();
  //   _autoScrollTimer = null;
  // }

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
// ...existing code...

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.transparent,
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
            color: Colors.white,
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
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
// ...existing code...
                  Text(
                    'Roam around the campus in style! Browse and buy official Techniche merchandise.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Detect scroll start/end reliably and trigger glitch accordingly
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollStartNotification) {
                          _startGlitchIfNeeded();
                        } else if (notification is ScrollEndNotification) {
                          // tiny delay to let final frames render
                          Future.delayed(const Duration(milliseconds: 60), () {
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
                            imagePath: item["image"]!,
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
    required String imagePath,
    required String price,
    required String description,
    required VoidCallback onBuy,
  }) {
    // Floating item — no box container around the card
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 320,
                height: 320,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedGlitch(
                    controller: _glitchController,
                    showColorChannels: true,
                    showDistortions: true,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onBuy,
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                label: const Text("Buy Now"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------------------------
  Background (unchanged)
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
    [const Color(0xFF181A20), const Color(0xFF23242B), const Color(0xFF35363C)],
    [const Color(0xFF23242B), const Color(0xFF35363C), const Color(0xFF181A20)],
    [const Color(0xFF35363C), const Color(0xFF23242B), const Color(0xFF181A20)],
    [const Color(0xFF181A20), const Color(0xFF35363C), const Color(0xFF23242B)],
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
