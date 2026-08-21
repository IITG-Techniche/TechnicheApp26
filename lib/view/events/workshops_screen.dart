import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constant/appTheme.dart';
import '../../providers/theme_provider.dart';

class WorkshopsScreen extends StatefulWidget {
  static const String routeName = '/workshops';

  const WorkshopsScreen({super.key});

  @override
  State<WorkshopsScreen> createState() => _WorkshopsScreenState();
}

class _WorkshopsScreenState extends State<WorkshopsScreen> {
  final List<Map<String, String>> _workshops = [
    {
      'title': 'Full Stack Web Development',
      'img': 'assets/webdev.jpg',
      'url':
          'https://unstop.com/workshops-webinars/full-stack-web-development-bootcamp-iit-guwahati-1541887',
    },
    {
      'title': 'Arduino Project Development',
      'img': 'assets/arduino.jpg',
      'url':
          'https://unstop.com/workshops-webinars/arduino-project-development-workshop-iit-guwahati-1541858',
    },
    {
      'title': 'Generative AI',
      'img': 'assets/genai.jpg',
      'url':
          'https://unstop.com/workshops-webinars/generative-ai-agentic-ai-workshop-iit-guwahati-1541805',
    },
    {
      'title': 'Cybersecurity',
      'img': 'assets/cybersec.jpg',
      'url':
          'https://unstop.com/workshops-webinars/cybersecurity-and-ethical-hacking-workshop-iit-guwahati-1541776',
    },
  ];

  late final List<double?> _aspectRatios;

  @override
  void initState() {
    super.initState();
    _aspectRatios =
        List<double?>.filled(_workshops.length, null, growable: false);

    for (var i = 0; i < _workshops.length; i++) {
      _resolveImageAspectRatio(i, _workshops[i]['img']!);
    }
  }

  Future<void> _resolveImageAspectRatio(int index, String url) async {
    try {
      ImageProvider provider;
      if (url.startsWith('http') || url.startsWith('https')) {
        provider = NetworkImage(url);
      } else {
        provider = AssetImage(url);
      }

      final completer = Completer<void>();
      final stream = provider.resolve(const ImageConfiguration());
      late final ImageStreamListener listener;
      listener = ImageStreamListener((ImageInfo info, bool _) {
        final img = info.image;
        final aspect = img.width / img.height;
        if (mounted) {
          setState(() {
            _aspectRatios[index] =
                (aspect.isFinite && aspect > 0) ? aspect : null;
          });
        }
        stream.removeListener(listener);
        completer.complete();
      }, onError: (_, __) {
        try {
          stream.removeListener(listener);
        } catch (_) {}
        completer.complete();
      });

      stream.addListener(listener);

      await completer.future.timeout(const Duration(seconds: 6), onTimeout: () {
        try {
          stream.removeListener(listener);
        } catch (_) {}
      });
    } catch (_) {}
  }

  Future<void> _openUnstop(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid registration URL.')));
      }
      return;
    }
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open registration link.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open registration link.')));
      }
    }
  }

  Widget _imageWidget(String url, double w, double h) {
    if (url.startsWith('http') || url.startsWith('https')) {
      return Image.network(
        url,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(w, h),
      );
    } else {
      return Image.asset(
        url,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(w, h),
      );
    }
  }

  Widget _placeholder(double w, double h) {
    return Container(
      width: w,
      height: h,
      color: AppTheme.backgroundGray,
      child: const Center(
          child:
              Icon(Icons.image_outlined, size: 30, color: Color(0xFFBDBDBD))),
    );
  }

  Widget _buildWorkshopCardByIndex(int index, double cardWidth) {
    final item = _workshops[index];
    final title = item['title']!;
    final imageUrl = item['img']!;
    final registerUrl = item['url']!;

    final aspect = _aspectRatios[index] ?? (16.0 / 9.0);
    final imageHeight = cardWidth / aspect;

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: cardWidth,
            height: imageHeight,
            child: _imageWidget(imageUrl, cardWidth, imageHeight),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppTheme.fontUnivers,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002B5B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: () => _openUnstop(registerUrl),
                    child: const Text('Register',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppTheme.fontGeneralSans)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNexusFullWidth(double fullWidth) {
    const nexusImageUrl = 'assets/nexus.jpg';
    const nexusAspect = 16.0 / 9.0;
    final imageHeight = fullWidth / nexusAspect;

    return Container(
      width: fullWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: fullWidth,
            height: imageHeight,
            child: _imageWidget(nexusImageUrl, fullWidth, imageHeight),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nexus',
                        style: TextStyle(
                          color: AppTheme.textMain,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppTheme.fontUnivers,
                          height: 1.07,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'The Corpo Management Conference',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          fontFamily: AppTheme.fontGeneralSans,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002B5B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      elevation: 0,
                    ),
                    onPressed: () => _openUnstop(
                        'https://unstop.com/workshops-webinars/nexus-the-corpo-management-conference-iit-guwahati-1541891'),
                    child: const Text('Register',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppTheme.fontGeneralSans)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: LayoutBuilder(builder: (context, constraints) {
        const horizontalPadding = 20.0;
        const spacing = 16.0;
        final fullWidth = constraints.maxWidth - (horizontalPadding * 2);
        final cardWidth = (fullWidth - spacing) / 2;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: List<Widget>.generate(_workshops.length,
                          (i) => _buildWorkshopCardByIndex(i, cardWidth)),
                    ),
                    const SizedBox(height: 20),
                    _buildNexusFullWidth(fullWidth),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF002B5B),
        image: DecorationImage(
          image: AssetImage('assets/ghm/frame3.png'),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFAFAFAF)),
                  borderRadius: BorderRadius.circular(12),
                ),
                shadows: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: Color(0xFFF5F5F5), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Color(0xFF6D7985), size: 20),
                    ),
                  ),
                  const Spacer(flex: 1),
                  const Text(
                    ' PAST WORKSHOPS & NEXUS',
                    style: TextStyle(
                        color: AppTheme.textMain,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppTheme.fontUnivers,
                        height: 1.2,
                        letterSpacing: 1),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
