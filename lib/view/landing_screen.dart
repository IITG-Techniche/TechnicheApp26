import 'package:amazon_clone/view/auth/authScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amazon_clone/utils/bottomNavBar.dart';
import 'package:amazon_clone/controller/authController.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingScreen extends StatelessWidget {
  static const String routeName = '/landing-screen';

  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF181A20),
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: const Color(0xFF23242B),
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
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.06),
        child: Column(
          children: [
            Flexible(
              flex: 4,
              child: AspectRatio(
                aspectRatio: 1,
                child: _ImageCarousel(),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              flex: 6,
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: screenWidth * 0.04,
                mainAxisSpacing: screenWidth * 0.04,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.95,
                children: [
                  _gridItem(
                    title: 'CA Portal',
                    description: 'Manage tasks and track your progress',
                    imagePath: 'assets/ca_icon.png',
                    color: const Color(0xFF23242B),
                    onTap: () => _handleAuthNavigation(context),
                  ),
                  _gridItem(
                    title: 'Technothlon',
                    description: 'See unique question papers of Technothlon!',
                    imagePath: 'assets/techno_logo.jpg',
                    color: const Color(0xFF23242B),
                    onTap: () => Navigator.pushNamed(context, '/technothlon-screen'),
                  ),
                  _gridItem(
                    title: 'Events',
                    description: 'Stay updated with the latest fest information',
                    imagePath: 'assets/techniche_events.png',
                    color: const Color(0xFF23242B),
                    onTap: () => Navigator.pushNamed(context, '/techniche-screen'),
                  ),
                  _gridItem(
                    title: 'GHM',
                    description: 'Track your steps and participate',
                    imagePath: 'assets/ghm_logo.jpg',
                    color: const Color(0xFF23242B),
                    onTap: () => Navigator.pushNamed(context, '/ghm-selection'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAuthNavigation(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      bool isAuth = await AuthController().isUserAuthenticated();
      if (context.mounted) Navigator.of(context).pop();
      if (isAuth) {
        bool valid = await AuthController().validateTokenAndFetchUser(context);
        if (valid && context.mounted) {
          Navigator.pushNamed(context, BottomNavBar.routeName);
        } else if (context.mounted) {
          Navigator.pushNamed(context, AuthScreen.routeName);
        }
      } else if (context.mounted) {
        Navigator.pushNamed(context, AuthScreen.routeName);
      }
    } catch (_) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error accessing CA portal.')),
        );
        Navigator.pushNamed(context, AuthScreen.routeName);
      }
    }
  }

  Widget _gridItem({
    required String title,
    required String description,
    required String imagePath,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.10),
              blurRadius: 24,
            ),
          ],
          border: Border.all(color: Colors.blueAccent.withOpacity(0.18), width: 1.5),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF35363C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Icon(
                Icons.arrow_forward,
                size: 18,
                color: Colors.blueAccent.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageCarousel extends StatefulWidget {
  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final List<String> imageUrls = [
    'assets/smash_kart.jpg',
    'assets/bgmi.jpg',
    'assets/chess.jpg',
    'assets/valo.jpg',
  ];
  final List<String> links = [
    'https://unstop.com/events/funniche-week-smash-karts-showdown-iit-guwahati-1500082',
    'https://unstop.com/events/funniche-week-bgmi-championship-iit-guwahati-1499627',
    'https://unstop.com/events/funniche-week-chess-championship-iit-guwahati-1499631',
    'https://unstop.com/events/funniche-week-valorant-championship-iit-guwahati-1499628',
  ];
  int _current = 0;
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
    _cycleImages();
  }

  void _cycleImages() async {
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    int next = (_current + 1) % imageUrls.length;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() => _current = next);
    _cycleImages();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: imageUrls.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (context, i) => GestureDetector(
            onTap: () async => await launchUrl(Uri.parse(links[i])),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: const Color(0xFF23242B),
                child: Image.asset(
                  imageUrls[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white.withOpacity(0.92),
                  colorBlendMode: BlendMode.modulate,
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            imageUrls.length,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _current == i ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
