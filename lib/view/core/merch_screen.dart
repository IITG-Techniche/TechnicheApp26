import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constant/appTheme.dart';

class MerchScreen extends StatefulWidget {
  static const String routeName = '/merch';
  const MerchScreen({Key? key}) : super(key: key);

  @override
  State<MerchScreen> createState() => _MerchScreenState();
}

class _MerchScreenState extends State<MerchScreen> {
  late final PageController _pageController;
  int _activePageIndex = 0;

  Timer? _autoScrollTimer;

  // Firestore-driven values (from app_config/merch)
  bool _isSoldOut = false;
  String _orderFormUrl = 'https://forms.gle/87Zf6bjNXU8hwwAdA';

  // Firestore-driven network image URLs, keyed by firestoreId
  final Map<String, String> _networkImages = {};

  // firestoreId maps to a document in the `merch_items` Firestore collection
  final List<Map<String, String>> merchItems = [
    {
      "firestoreId": "glitched_gameboy",
      "title": "Glitched GameBoy",
      "fallbackImage": "assets/glitched.png",
      "price": "₹449",
      "badge": "Limited Edition",
      "description":
          "When circuits fry but style survives. It's rebellious, loud, and built for those who'd rather crash the system than play by its rules.",
    },
    {
      "firestoreId": "glorified_goodboy",
      "title": "Glorified GoodBoy",
      "fallbackImage": "assets/goodboy.png",
      "price": "₹399",
      "badge": "Official Drop",
      "description":
          "Channeling collective consciousness, algorithms, and aesthetics that scream main character energy. Rock it, & Beyond the club, you are the vibe.",
    },
  ];



  @override
  void initState() {
    super.initState();
    final initialPage = merchItems.length * 1000;
    _pageController = PageController(
      initialPage: initialPage,
      viewportFraction: 0.90,
    );
    _activePageIndex = initialPage % merchItems.length;

    _fetchMerchConfig();
    _fetchMerchImages();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startAutoScroll();
    });
  }

  /// Fetches imageUrl for each merch item from `merch_items` Firestore collection.
  Future<void> _fetchMerchImages() async {
    try {
      for (final item in merchItems) {
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
      debugPrint('⚠️ Merch image fetch failed: $e');
    }
  }

  /// Converts a Google Drive sharing URL to a direct image URL via the thumbnail endpoint.
  /// https://drive.google.com/file/d/FILE_ID/view → https://drive.google.com/thumbnail?id=FILE_ID&sz=w1000
  String _convertDriveUrl(String url) {
    final regex = RegExp(r'drive\.google\.com/file/d/([^/?]+)');
    final match = regex.firstMatch(url);
    if (match != null) {
      final fileId = match.group(1)!;
      debugPrint('🖼️ Drive URL converted: id=$fileId');
      return 'https://drive.google.com/thumbnail?id=$fileId&sz=w1000';
    }
    return url;
  }

  /// Fetches isSoldOut and orderFormUrl from Firestore `app_config/merch`.
  Future<void> _fetchMerchConfig() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('merch')
          .get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _isSoldOut = (data['isSoldOut'] as bool?) ?? false;
          _orderFormUrl = (data['orderFormUrl'] as String?)
              ?? 'https://forms.gle/87Zf6bjNXU8hwwAdA';
        });
        debugPrint('🛒 Merch config: isSoldOut=$_isSoldOut, url=$_orderFormUrl');
      }
    } catch (e) {
      debugPrint('⚠️ Merch config fetch failed, using defaults: $e');
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!_pageController.hasClients || !mounted) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    });
  }



  Future<void> _launchURL() async {
    final Uri url = Uri.parse(_orderFormUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? AppTheme.darkPageBg : AppTheme.lightPageBg;
    final cardBg = isDark ? AppTheme.darkCardsBg : AppTheme.lightCardsBg;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context, isDark: isDark, textPrimary: textPrimary),

            // Subtitle banner / intro text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
              child: Text(
                'Roam around the campus in style! Browse official Techniche merchandise.',
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                  fontFamily: AppTheme.fontGeneralSans,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // PageView Slider of Merchandise items
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  return false;
                },
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _activePageIndex = index % merchItems.length;
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = merchItems[index % merchItems.length];
                    final networkUrl = _networkImages[item['firestoreId']];
                    return _merchCard(
                      context: context,
                      isDark: isDark,
                      cardBg: cardBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      title: item['title']!,
                      fallbackImagePath: item['fallbackImage']!,
                      networkImageUrl: networkUrl,
                      price: item['price']!,
                      badge: item['badge'] ?? 'Official Merch',
                      description: item['description']!,
                      isSoldOut: _isSoldOut,
                      onBuy: _launchURL,
                    );
                  },
                ),
              ),
            ),

            // Bottom Carousel Indicator Dots
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  merchItems.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: _activePageIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _activePageIndex == index
                          ? AppTheme.primaryBlue
                          : (isDark
                              ? Colors.white.withOpacity(0.2)
                              : Colors.black.withOpacity(0.15)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {required bool isDark, required Color textPrimary}) {
    final canPop = Navigator.canPop(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 24.0, 8.0),
      child: Row(
        children: [
          if (canPop) ...[
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: textPrimary,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Merchandise',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    fontFamily: AppTheme.fontUnivers,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'TECHNICHE 26',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryBlue,
                          fontFamily: AppTheme.fontGeneralSans,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _merchCard({
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
    required String title,
    required String fallbackImagePath,
    String? networkImageUrl,
    required String price,
    required String badge,
    required String description,
    required bool isSoldOut,
    required VoidCallback onBuy,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : const Color(0xFF30499E).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Badge & Price Tag Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkChip.withOpacity(0.2)
                          : AppTheme.lightChip,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      badge.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.darkChip : AppTheme.primaryBlue,
                        fontFamily: AppTheme.fontGeneralSans,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      price,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontFamily: AppTheme.fontUnivers,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Merch Image — network (Firestore) with local asset fallback
              SizedBox(
                height: 300,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow backdrop
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentBlue
                                .withOpacity(isDark ? 0.30 : 0.15),
                            blurRadius: 60,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    // Image — network if available, else local asset
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: networkImageUrl != null && networkImageUrl.isNotEmpty
                          ? Image.network(
                              networkImageUrl,
                              height: 280,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return SizedBox(
                                  height: 280,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                          : null,
                                      color: AppTheme.primaryBlue,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Image.asset(
                                fallbackImagePath,
                                height: 280,
                                fit: BoxFit.contain,
                              ),
                            )
                          : Image.asset(
                              fallbackImagePath,
                              height: 280,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Item Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  fontFamily: AppTheme.fontUnivers,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 8),

              // Item Description
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                  fontFamily: AppTheme.fontGeneralSans,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              // Order / Sold Out Button — driven by Remote Config
              isSoldOut
                  ? Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.remove_shopping_cart_rounded,
                            color: isDark ? Colors.white38 : Colors.black38,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'SOLD OUT',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.redAccent.shade100.withOpacity(0.8)
                                  : Colors.red.shade700,
                              fontFamily: AppTheme.fontGeneralSans,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GestureDetector(
                      onTap: onBuy,
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'ORDER NOW',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: AppTheme.fontGeneralSans,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
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

