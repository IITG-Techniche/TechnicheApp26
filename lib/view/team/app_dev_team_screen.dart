import 'dart:async';
import 'package:flutter/material.dart';
import '../../constant/appTheme.dart';
import '../../model/team_data.dart';

class AppDevTeamScreen extends StatefulWidget {
  static const String routeName = '/app-dev-team';
  final List<TeamMember> members;

  const AppDevTeamScreen({
    super.key,
    this.members = kDevTeamMembers,
  });

  @override
  State<AppDevTeamScreen> createState() => _AppDevTeamScreenState();
}

class _AppDevTeamScreenState extends State<AppDevTeamScreen> {
  late final PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.80, initialPage: 0);
    _resumeAutoPlay();
  }

  void _resumeAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (t) {
      if (!mounted || widget.members.isEmpty) return;
      final next = (_currentIndex + 1) % widget.members.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
        setState(() => _currentIndex = next);
      }
    });
  }

  void _pauseAutoPlay() {
    _autoPlayTimer?.cancel();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _openMemberDialog(TeamMember m, bool isDark) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE1EBFF),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: m.imageUrl.startsWith('http')
                      ? Image.network(
                          m.imageUrl,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey[200],
                            child: const Icon(Icons.person, size: 60, color: Color(0xFF6D7985)),
                          ),
                        )
                      : Image.asset(
                          m.imageUrl,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey[200],
                            child: const Icon(Icons.person, size: 60, color: Color(0xFF6D7985)),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                m.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTheme.fontUnivers,
                  color: isDark ? Colors.white : AppTheme.textMain,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                m.role,
                style: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppTheme.fontGeneralSans,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF070B19) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('APP DEVELOPERS'),
        backgroundColor: isDark ? const Color(0xFF070B19) : const Color(0xFFF8F9FA),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Meet the developers who engineered the Techniche 2026 application.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontGeneralSans,
                  fontSize: 14,
                  color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: SizedBox(
                  height: size.height * 0.58,
                  child: AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, _) {
                      final page = _pageController.hasClients &&
                              _pageController.page != null
                          ? _pageController.page!
                          : _pageController.initialPage.toDouble();

                      return PageView.builder(
                        controller: _pageController,
                        itemCount: widget.members.length,
                        onPageChanged: (i) => setState(() => _currentIndex = i),
                        itemBuilder: (context, i) {
                          final delta = (i - page).abs().clamp(0.0, 1.0);
                          final double scale = 1.0 - (delta * 0.12);
                          final double opacity = 1.0 - (delta * 0.3);

                          final m = widget.members[i];

                          return Opacity(
                            opacity: opacity,
                            child: Transform.scale(
                              scale: scale,
                              child: GestureDetector(
                                onTap: () {
                                  _pauseAutoPlay();
                                  _openMemberDialog(m, isDark);
                                  _resumeAutoPlay();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF0F172A)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: i == _currentIndex
                                            ? const Color(0xFF3B82F6)
                                            : (isDark
                                                ? const Color(0xFF1E293B)
                                                : const Color(0xFFE2E8F0)),
                                        width: i == _currentIndex ? 2 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isDark
                                              ? Colors.black54
                                              : Colors.black.withOpacity(0.06),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: i == _currentIndex
                                                ? const Color(0xFF3B82F6).withOpacity(0.2)
                                                : (isDark ? const Color(0xFF1E293B) : Colors.grey[100]),
                                            shape: BoxShape.circle,
                                          ),
                                          child: ClipOval(
                                            child: m.imageUrl.startsWith('http')
                                                ? Image.network(
                                                    m.imageUrl,
                                                    width: 140,
                                                    height: 140,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) =>
                                                        Container(
                                                      width: 140,
                                                      height: 140,
                                                      color: Colors.white10,
                                                      child: const Icon(
                                                        Icons.person,
                                                        size: 60,
                                                        color: Color(0xFF6D7985),
                                                      ),
                                                    ),
                                                  )
                                                : Image.asset(
                                                    m.imageUrl,
                                                    width: 140,
                                                    height: 140,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) =>
                                                        Container(
                                                      width: 140,
                                                      height: 140,
                                                      color: Colors.white10,
                                                      child: const Icon(
                                                        Icons.person,
                                                        size: 60,
                                                        color: Color(0xFF6D7985),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          m.name,
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0XFF232930),
                                            fontSize: 22,
                                            fontFamily: AppTheme.fontUnivers,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF3B82F6)
                                                .withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            m.role,
                                            style: const TextStyle(
                                              color: Color(0xFF3B82F6),
                                              fontFamily:
                                                  AppTheme.fontGeneralSans,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.members.length, (i) {
                final selected = i == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: selected ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF3B82F6)
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFD1D1D1)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
