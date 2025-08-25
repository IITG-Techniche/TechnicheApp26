// lib/view/workshops_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkshopsScreen extends StatefulWidget {
  static const String routeName = '/workshops';

  const WorkshopsScreen({super.key});

  @override
  State<WorkshopsScreen> createState() => _WorkshopsScreenState();
}

class _WorkshopsScreenState extends State<WorkshopsScreen> {
  static const String _discountCode = 'TECHNICHEAPP';
  static const int _twoMinutesMs = 2 * 60 * 1000;
  static const String _prefsKey = 'lastDiscountShownMs';

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

  // stores intrinsic aspect ratios (width / height) for each workshop image
  late final List<double?> _aspectRatios;

  @override
  void initState() {
    super.initState();
    _aspectRatios =
        List<double?>.filled(_workshops.length, null, growable: false);

    // show discount popup after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowDiscount();
    });

    // start resolving image sizes (non-blocking)
    for (var i = 0; i < _workshops.length; i++) {
      _resolveImageAspectRatio(i, _workshops[i]['img']!);
    }
  }

  /// Resolve intrinsic image aspect ratio (width/height) and store it.
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

      // don't hang forever
      await completer.future.timeout(const Duration(seconds: 6), onTimeout: () {
        try {
          stream.removeListener(listener);
        } catch (_) {}
      });
    } catch (_) {
      // ignore, fallback will be used
    }
  }

  Future<void> _checkAndShowDiscount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastShown = prefs.getInt(_prefsKey);
      final now = DateTime.now().millisecondsSinceEpoch;

      if (lastShown == null || (now - lastShown) >= _twoMinutesMs) {
        await prefs.setInt(_prefsKey, now);
        if (!mounted) return;
        _showDiscountDialog();
      }
    } catch (e) {
      debugPrint('SharedPreferences error: $e');
    }
  }

  void _showDiscountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Special Discount — 30% OFF'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Use the code below during registration for 30% discount:'),
            const SizedBox(height: 12),
            SelectableText(
              _discountCode,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.5),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('Copy code'),
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: _discountCode));
                Navigator.of(ctx).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Discount code copied to clipboard')),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
    final placeholder = Container(
      width: w,
      height: h,
      color: Colors.grey[200],
      child:
          const Center(child: Icon(Icons.image, size: 36, color: Colors.grey)),
    );

    if (url.startsWith('http') || url.startsWith('https')) {
      return Image.network(
        url,
        width: w,
        height: h,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => placeholder,
      );
    } else {
      return Image.asset(
        url,
        width: w,
        height: h,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }
  }

  /// Workshop card built to exact width and image-height so no whitespace remains
  Widget _buildWorkshopCardByIndex(int index, double cardWidth) {
    final item = _workshops[index];
    final title = item['title']!;
    final imageUrl = item['img']!;
    final registerUrl = item['url']!;

    // fallback aspect ratio if not available
    final aspect = _aspectRatios[index] ?? (4.0 / 3.0);
    final imageHeight = cardWidth / aspect;

    return SizedBox(
      width: cardWidth,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.min, // natural height
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: cardWidth,
              height: imageHeight,
              child: _imageWidget(imageUrl, cardWidth, imageHeight),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => _openUnstop(registerUrl),
                      child: const Text('Register'),
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

  /// Nexus card full-width below the grid
  Widget _buildNexusFullWidth(double fullWidth) {
    const nexusImageUrl = 'assets/nexus.jpg';
    const nexusAspect = 200.0 / 140.0;
    final imageHeight = fullWidth / nexusAspect;

    return SizedBox(
      width: fullWidth,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Nexus',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 6),
                        Text(
                          'Corpo Management Conference.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => _openUnstop(
                          'https://unstop.com/workshops-webinars/nexus-the-corpo-management-conference-iit-guwahati-1541891'),
                      child: const Text('Register'),
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

  /// Instructions full-width below the grid
  Widget _buildInstructionsFullWidth(double fullWidth) {
    return SizedBox(
      width: fullWidth,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 79, 93, 102),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'How to use the discount:\n'
          '1. Click "Register" on any workshop — Unstop will open.\n'
          '2. When Unstop asks for a promo/discount code, enter: TECHNICHEAPP\n'
          '3. Enjoy 30% off.\n\n'
          'Tip: Copy the code from the discount popup that appears when you open this screen (it shows once every 2 minutes).',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 12.0;
    const spacing = 12.0;
    const columns = 2;

    return Scaffold(
      appBar: AppBar(title: const Text('Workshops & Nexus')),
      body: LayoutBuilder(builder: (context, constraints) {
        // compute width available for content (fullWidth) and card width for 2 columns
        final fullWidth = constraints.maxWidth - (horizontalPadding * 2);
        final cardWidth = (fullWidth - spacing) / columns;

        // build workshop widgets (exact width)
        final workshopCards = List<Widget>.generate(
            _workshops.length, (i) => _buildWorkshopCardByIndex(i, cardWidth));

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 2x grid using Wrap with fixed child widths -> stays 2 columns
                Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: workshopCards,
                ),

                const SizedBox(height: 16),

                // Nexus full-width (uses fullWidth)
                _buildNexusFullWidth(fullWidth),

                const SizedBox(height: 12),

                // Instructions full-width
                _buildInstructionsFullWidth(fullWidth),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }
}
