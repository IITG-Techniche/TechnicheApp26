import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constant/appTheme.dart';

class LegacyDetailScreen extends StatefulWidget {
  static const String routeName = '/legacy-detail';
  const LegacyDetailScreen({super.key});

  @override
  State<LegacyDetailScreen> createState() => _LegacyDetailScreenState();
}

class _LegacyDetailScreenState extends State<LegacyDetailScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _autoPlayTimer;

  final List<_TimelineCardData> _cards = [
    _TimelineCardData(
      year: '1999',
      title: 'TECHNICHE',
      description: 'Journey of Techniche begins',
      metricNumber: 20,
      metricSymbol: '₹',
      metricUnit: ' L',
      metricLabel: 'WORTH PRIZES\nDISTRIBUTED',
      imageAsset: 'assets/legacy1.png',
      alignRight: true,
    ),
    _TimelineCardData(
      year: '2009',
      title: 'GHM',
      description: 'First edition of Guwahati\nHalf Marathon commenced',
      metricNumber: 1,
      metricSymbol: '',
      metricUnit: ' LAKH+',
      metricLabel: 'LIVES IMPACTED',
      imageAsset: 'assets/legacy2.png',
      alignRight: true,
    ),
    _TimelineCardData(
      year: '2010',
      title: 'TECHNOTHLON',
      description:
          'Technothlon achieves global\nreach, emerging as India’s\npremier logic exam for\nstudents',
      metricNumber: 3,
      metricSymbol: '',
      metricUnit: 'X YoY',
      metricLabel: 'GROWTH',
      imageAsset: 'assets/legacy1.png',
      alignRight: false,
    ),
    _TimelineCardData(
      year: '2017',
      title: 'PRAGATI',
      description:
          'Five neighboring villages\nadopted under the Pragati\ninitiatives',
      metricNumber: 150,
      metricSymbol: '',
      metricUnit: 'K+',
      metricLabel: 'LIKES ON META',
      imageAsset: 'assets/legacy2.png',
      alignRight: true,
    ),
    _TimelineCardData(
      year: '2025',
      title: 'TECHNICHE',
      description:
          'Techniche successfully\ncompletes 28 years',
      metricNumber: 50,
      metricSymbol: '',
      metricUnit: 'K+',
      metricLabel: 'FOOTFALL',
      imageAsset: 'assets/legacy1.png',
      alignRight: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_pageController.hasClients) {
        final nextPage = (_currentIndex + 1) % _cards.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF03050B) : const Color(0xFFF8FAFC);
    final primaryBlue = isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E3A8A);
    final secondaryText = isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF64748B);
    final dotInactive = isDark ? Colors.white.withOpacity(0.25) : Colors.black.withOpacity(0.18);
    final iconColor = isDark ? Colors.white : Colors.black87;
    final backBg = isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.06);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Full-Height Animated Horizontal PageView Carousel
            PageView.builder(
              controller: _pageController,
              itemCount: _cards.length,
              onPageChanged: (index) {
                HapticFeedback.selectionClick();
                setState(() {
                  _currentIndex = index;
                });
                _startAutoPlay(); // Reset timer on manual swipe
              },
              itemBuilder: (context, index) {
                final card = _cards[index];
                final isSelected = index == _currentIndex;
                return _LegacyTimelineCard(
                  key: ValueKey('legacy_card_$index'),
                  data: card,
                  isSelected: isSelected,
                  isDark: isDark,
                );
              },
            ),

            // Top Left Floating Back Button
            Positioned(
              top: 14,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: backBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.25) : Colors.black.withOpacity(0.12),
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 18,
                        color: iconColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Timeline Progress Indicator & Dots
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Smooth 5-Dot Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _cards.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: index == _currentIndex ? 28 : 8,
                        decoration: BoxDecoration(
                          color: index == _currentIndex
                              ? primaryBlue
                              : dotInactive,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SWIPE OR WAIT TO EXPLORE • ${_currentIndex + 1} OF ${_cards.length}',
                    style: TextStyle(
                      fontFamily: AppTheme.fontUnivers,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: secondaryText,
                      letterSpacing: 1.5,
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

class _TimelineCardData {
  final String year;
  final String title;
  final String description;
  final int metricNumber;
  final String metricSymbol;
  final String metricUnit;
  final String metricLabel;
  final String imageAsset;
  final bool alignRight;

  _TimelineCardData({
    required this.year,
    required this.title,
    required this.description,
    required this.metricNumber,
    required this.metricSymbol,
    required this.metricUnit,
    required this.metricLabel,
    required this.imageAsset,
    required this.alignRight,
  });
}

class _LegacyTimelineCard extends StatefulWidget {
  final _TimelineCardData data;
  final bool isSelected;
  final bool isDark;

  const _LegacyTimelineCard({
    super.key,
    required this.data,
    required this.isSelected,
    required this.isDark,
  });

  @override
  State<_LegacyTimelineCard> createState() => _LegacyTimelineCardState();
}

class _LegacyTimelineCardState extends State<_LegacyTimelineCard>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _breathingController;

  late final Animation<double> _arcScale;
  late final Animation<double> _arcOpacity;
  late final Animation<Offset> _beeSlide;
  late final Animation<double> _beeOpacity;
  late final Animation<int> _numberValue;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    // 1. Entrance Staggered Animation Controller
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // 2. Infinite Breathing Arc Rotation Controller
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    // Arc Scale & Opacity
    _arcScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );
    _arcOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Bee Logo Soft Bounce Slide & Opacity
    _beeSlide = Tween<Offset>(
      begin: const Offset(0.0, -0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.65, curve: Curves.elasticOut),
      ),
    );
    _beeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.4, curve: Curves.easeIn),
      ),
    );

    // Metric Number Count Up Tween
    _numberValue = IntTween(begin: 0, end: widget.data.metricNumber).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    // Year + Text Slide & Opacity
    _textSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.45, 0.95, curve: Curves.easeOutCubic),
      ),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.45, 0.8, curve: Curves.easeIn),
      ),
    );

    if (widget.isSelected) {
      _entranceController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _LegacyTimelineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _entranceController.forward(from: 0.0);
      } else {
        _entranceController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final m = widget.data;
    final isDark = widget.isDark;

    final primaryBlue = isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E3A8A);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final descColor = isDark ? Colors.white.withOpacity(0.85) : const Color(0xFF334155);
    final outlineColor = isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB);
    final yearFillColor = isDark ? const Color(0xFF03050B) : const Color(0xFFF8FAFC);

    return Stack(
      children: [
        // 1. TOP HEADER & BEE LOGO
        Positioned(
          top: 60,
          left: 28,
          right: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SlideTransition(
                  position: _beeSlide,
                  child: FadeTransition(
                    opacity: _beeOpacity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LEGACY',
                          style: TextStyle(
                            fontFamily: AppTheme.fontUnivers,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            height: 0.95,
                            color: primaryBlue,
                          ),
                        ),
                        Text(
                          'TIMELINE',
                          style: TextStyle(
                            fontFamily: AppTheme.fontUnivers,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            height: 0.95,
                            color: titleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Animated Bee Illustration
              SlideTransition(
                position: _beeSlide,
                child: FadeTransition(
                  opacity: _beeOpacity,
                  child: Image.asset(
                    'assets/hero/meetheads/bettle1.png',
                    width: 110,
                    height: 110,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. BACKGROUND ANIMATED BOTH ARC IMAGES
        Positioned(
          top: size.height * 0.16,
          left: -130,
          child: AnimatedBuilder(
            animation: Listenable.merge([_arcScale, _breathingController]),
            builder: (context, child) {
              final breathAngle = (_breathingController.value * 0.08) - 0.04;
              return Transform.scale(
                scale: _arcScale.value,
                child: Transform.rotate(
                  angle: breathAngle,
                  child: FadeTransition(
                    opacity: _arcOpacity,
                    child: Image.asset(
                      'assets/legacy1.png',
                      width: 360,
                      height: 360,
                      fit: BoxFit.contain,
                      color: isDark ? null : Colors.black.withOpacity(0.08),
                      colorBlendMode: isDark ? null : BlendMode.srcIn,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        Positioned(
          top: size.height * 0.42,
          right: -130,
          child: AnimatedBuilder(
            animation: Listenable.merge([_arcScale, _breathingController]),
            builder: (context, child) {
              final breathAngle = -((_breathingController.value * 0.08) - 0.04);
              return Transform.scale(
                scale: _arcScale.value,
                child: Transform.rotate(
                  angle: breathAngle,
                  child: FadeTransition(
                    opacity: _arcOpacity,
                    child: Image.asset(
                      'assets/legacy2.png',
                      width: 360,
                      height: 360,
                      fit: BoxFit.contain,
                      color: isDark ? null : Colors.black.withOpacity(0.08),
                      colorBlendMode: isDark ? null : BlendMode.srcIn,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // 3. MIDDLE BIG METRIC COUNT-UP ANIMATION (Right Side)
        Positioned(
          top: size.height * 0.22,
          right: 28,
          child: AnimatedBuilder(
            animation: _numberValue,
            builder: (context, child) {
              return FadeTransition(
                opacity: _arcOpacity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        if (m.metricSymbol.isNotEmpty)
                          Text(
                            m.metricSymbol,
                            style: TextStyle(
                              fontFamily: AppTheme.fontUnivers,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: primaryBlue,
                            ),
                          ),
                        Text(
                          '${_numberValue.value}',
                          style: TextStyle(
                            fontFamily: AppTheme.fontUnivers,
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: primaryBlue,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          m.metricUnit,
                          style: TextStyle(
                            fontFamily: AppTheme.fontUnivers,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: titleColor,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      m.metricLabel,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: AppTheme.fontGeneralSans,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: titleColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // 4. BOTTOM YEAR + TITLE + DESCRIPTION (Left Side)
        Positioned(
          top: size.height * 0.50,
          left: 28,
          width: size.width * 0.65,
          child: SlideTransition(
            position: _textSlide,
            child: FadeTransition(
              opacity: _textOpacity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hollow Outlined Year Text
                  Stack(
                    children: [
                      Text(
                        m.year,
                        style: TextStyle(
                          fontFamily: AppTheme.fontUnivers,
                          fontSize: 54,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 3.0
                            ..color = outlineColor,
                        ),
                      ),
                      Text(
                        m.year,
                        style: TextStyle(
                          fontFamily: AppTheme.fontUnivers,
                          fontSize: 54,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: yearFillColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    m.title,
                    style: TextStyle(
                      fontFamily: AppTheme.fontUnivers,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    m.description,
                    style: TextStyle(
                      fontFamily: AppTheme.fontGeneralSans,
                      fontSize: 13,
                      color: descColor,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
