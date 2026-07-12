import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../model/events_data.dart';
import '../../constant/appTheme.dart';

/// Shows the appropriate event detail UI based on event data in a clean light theme
void showEventDetail(BuildContext context, SubCategory subCategory) {
  if (subCategory.events.isEmpty) {
    _showComingSoonSheet(context, subCategory);
  } else if (subCategory.events.length == 1 &&
      subCategory.events.first.redirectUrl != null) {
    _showRedirectSheet(context, subCategory);
  } else {
    _showEventsListSheet(context, subCategory);
  }
}

void _showEventsListSheet(BuildContext context, SubCategory subCategory) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _EventsListSheet(subCategory: subCategory),
  );
}

void _showRedirectSheet(BuildContext context, SubCategory subCategory) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _RedirectSheet(subCategory: subCategory),
  );
}

void _showComingSoonSheet(BuildContext context, SubCategory subCategory) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ComingSoonSheet(subCategory: subCategory),
  );
}

class _EventsListSheet extends StatelessWidget {
  final SubCategory subCategory;

  const _EventsListSheet({required this.subCategory});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Stack(
            children: [
              // Background dismissal area
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
              // The Card Content
              GestureDetector(
                onTap: () {}, // Prevent dismissal when clicking the card itself
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8E8E8),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                subCategory.imageAsset,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                subCategory.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: AppTheme.fontUnivers,
                                  color: AppTheme.textMain,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Color(0xFFE8E8E8)),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: subCategory.events.length,
                          itemBuilder: (context, index) {
                            final event = subCategory.events[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE8E8E8)),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFFE1EBFF),
                                  radius: 18,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: AppTheme.fontGeneralSans,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  event.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: AppTheme.fontGeneralSans,
                                    color: AppTheme.textMain,
                                    height: 1.2,
                                  ),
                                ),
                                trailing: event.redirectUrl != null
                                    ? const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF6D7985))
                                    : null,
                                onTap: () {
                                  if (event.redirectUrl != null) {
                                    _launchUrl(context, event.redirectUrl!);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RedirectSheet extends StatelessWidget {
  final SubCategory subCategory;

  const _RedirectSheet({required this.subCategory});

  @override
  Widget build(BuildContext context) {
    final event = subCategory.events.first;

    return Stack(
      children: [
        // Background dismissal area
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          behavior: HitTestBehavior.opaque,
          child: const SizedBox.expand(),
        ),
        // The Card Content
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {}, // Prevent dismissal on card
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.only(bottom: 40, top: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E8E8),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        subCategory.imageAsset,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        subCategory.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppTheme.fontUnivers,
                          color: AppTheme.textMain,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002B5B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: () => _launchUrl(context, event.redirectUrl!),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'REGISTER ON UNSTOP',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: AppTheme.fontGeneralSans,
                                    letterSpacing: 0.5),
                              ),
                              SizedBox(width: 12),
                              Icon(Icons.launch_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ComingSoonSheet extends StatelessWidget {
  final SubCategory subCategory;

  const _ComingSoonSheet({required this.subCategory});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background dismissal area
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          behavior: HitTestBehavior.opaque,
          child: const SizedBox.expand(),
        ),
        // The Card Content
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {}, // Prevent dismissal on card
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.only(bottom: 60, top: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E8E8),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        subCategory.imageAsset,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      subCategory.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppTheme.fontUnivers,
                        color: AppTheme.textMain,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFFE8E8E8)),
                      ),
                      child: const Text(
                        'COMING SOON',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppTheme.fontGeneralSans,
                          color: AppTheme.textSecondary,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> _launchUrl(BuildContext context, String urlString) async {
  final url = Uri.parse(urlString);
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot open link')),
      );
    }
  }
}
