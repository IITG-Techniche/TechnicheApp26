import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Static merch list — firestoreId maps to merch_items/{id} for the image
  final List<Map<String, String>> _merchList = const [
    {
      'firestoreId': 'glitched_gameboy',
      'name': 'Glitched GameBoy',
      'fallback': 'assets/glitched.png',
    },
    {
      'firestoreId': 'glorified_goodboy',
      'name': 'Glorified GoodBoy',
      'fallback': 'assets/goodboy.png',
    },
  ];

  // Firestore-fetched network image URLs, keyed by firestoreId
  final Map<String, String> _networkImages = {};

  @override
  void initState() {
    super.initState();
    _fetchMerchImages();
  }

  Future<void> _fetchMerchImages() async {
    try {
      for (final item in _merchList) {
        final id = item['firestoreId']!;
        final doc = await FirebaseFirestore.instance
            .collection('merch_items')
            .doc(id)
            .get();
        if (doc.exists && mounted) {
          final url = (doc.data()?['imageUrl'] as String?) ?? '';
          if (url.isNotEmpty) {
            setState(() => _networkImages[id] = _convertDriveUrl(url));
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ HomeMerchandiseSection image fetch failed: $e');
    }
  }

  /// Converts a Google Drive sharing URL to a direct image URL via the thumbnail endpoint.
  String _convertDriveUrl(String url) {
    final regex = RegExp(r'drive\.google\.com/file/d/([^/?]+)');
    final match = regex.firstMatch(url);
    if (match != null) {
      return 'https://drive.google.com/thumbnail?id=${match.group(1)}&sz=w1000';
    }
    return url;
  }

  void _toggleMerch() {
    setState(() {
      _selectedMerchIndex = (_selectedMerchIndex + 1) % _merchList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentMerch = _merchList[_selectedMerchIndex];
    final networkUrl = _networkImages[currentMerch['firestoreId']];
    final fallbackAsset = currentMerch['fallback']!;

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
          clipBehavior: Clip.hardEdge,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: AppTheme.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A63BA).withOpacity(0.40),
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

            // Merch Image — Firestore network URL with local asset fallback
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 210,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Glow backdrop
                  Container(
                    width: 100,
                    height: 100,
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

                  // Tappable merch image
                  GestureDetector(
                    onTap: _toggleMerch,
                    child: SizedBox(
                      width: 160,
                      height: 180,
                      child: networkUrl != null && networkUrl.isNotEmpty
                          ? Image.network(
                              networkUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                            progress.expectedTotalBytes!
                                        : null,
                                    color: AppTheme.primaryBlue,
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Image.asset(
                                fallbackAsset,
                                fit: BoxFit.contain,
                              ),
                            )
                          : Image.asset(
                              fallbackAsset,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),

                  // Toggle button
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
