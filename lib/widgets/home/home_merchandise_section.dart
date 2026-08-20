import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:techniche26/constant/appTheme.dart';

class HomeMerchandiseSection extends StatefulWidget {
  final bool isDark;

  const HomeMerchandiseSection({
    super.key,
    required this.isDark,
  });

  @override
  State<HomeMerchandiseSection> createState() => _HomeMerchandiseSectionState();
}

class _HomeMerchandiseSectionState extends State<HomeMerchandiseSection> {
  int _selectedMerchIndex = 0;

  final List<Map<String, String>> _merchList = const [
    {
      "name": "Glitched GameBoy",
      "model": "assets/MerchBlack.glb",
      "alt": "Black Merch 3D Model",
    },
    {
      "name": "Glorified GoodBoy",
      "model": "assets/merchself.glb",
      "alt": "White Merch 3D Model",
    },
  ];

  void _toggleMerch() {
    setState(() {
      _selectedMerchIndex = (_selectedMerchIndex + 1) % _merchList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentMerch = _merchList[_selectedMerchIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        height: 215,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              widget.isDark
                  ? 'assets/hero/heroMerchSection.png'
                  : 'assets/hero/heroMerchLight.png',
            ),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Techniche Merchandise Title Text (Top Left)
            Positioned(
              left: 22,
              top: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Techniche',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: widget.isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF475569),
                      fontFamily: 'General Sans',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Merchandise',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                      fontFamily: AppTheme.fontUnivers,
                    ),
                  ),
                ],
              ),
            ),

            // Explore Collection Button (Bottom Left)
            Positioned(
              left: 18,
              bottom: 18,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/merch'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 11),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF3363EC),
                        Color(0xFF193798),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF244ECC).withOpacity(0.40),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Explore Collection',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'General Sans',
                    ),
                  ),
                ),
              ),
            ),

            // Enlarged 3D Merch Shirt GLB Model with Switcher
            Positioned(
              right: 2,
              top: -32,
              bottom: -10,
              width: 210,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Cyan/Blue Glowing Backdrop Aura
                  Container(
                    width: 140,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A80FF).withOpacity(0.60),
                          blurRadius: 48,
                          spreadRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  // ModelViewer 3D GLB Model (Large size: 200x240)
                  GestureDetector(
                    onTap: _toggleMerch,
                    child: SizedBox(
                      width: 200,
                      height: 240,
                      child: ModelViewer(
                        key: ValueKey(currentMerch["model"]),
                        src: currentMerch["model"]!,
                        alt: currentMerch["alt"]!,
                        autoRotate: true,
                        rotationPerSecond: "28deg",
                        autoRotateDelay: 0,
                        disableZoom: true,
                        backgroundColor: Colors.transparent,
                        loading: Loading.eager,
                      ),
                    ),
                  ),
                  // Toggle Merch Arrow Button overlay
                  Positioned(
                    right: 4,
                    bottom: 24,
                    child: GestureDetector(
                      onTap: _toggleMerch,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.swap_horiz_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
