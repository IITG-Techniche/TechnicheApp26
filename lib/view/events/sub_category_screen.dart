import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/events_data.dart';
import '../../constant/appTheme.dart';
import '../../providers/theme_provider.dart';
import '../eventdetailpage.dart';
import 'event_detail_sheet.dart';

class SubCategoryScreen extends StatefulWidget {
  static const String routeName = '/sub-category';
  final String categoryTitle;
  final List<SubCategory> subCategories;

  const SubCategoryScreen({
    super.key,
    required this.categoryTitle,
    required this.subCategories,
  });

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? AppTheme.darkPageBg : AppTheme.lightPageBg;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, textPrimary: textPrimary),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: _buildStaggeredSubCategoryGrid(context, isDark: isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {required Color textPrimary}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 12.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Icon(
              Icons.chevron_left_rounded,
              color: textPrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              widget.categoryTitle,
              style: TextStyle(
                color: textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                fontFamily: AppTheme.fontUnivers,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaggeredSubCategoryGrid(BuildContext context, {required bool isDark}) {
    if (widget.subCategories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'No sub-categories available',
            style: TextStyle(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              fontFamily: AppTheme.fontGeneralSans,
            ),
          ),
        ),
      );
    }

    final leftCol = <int>[];
    final rightCol = <int>[];

    for (int i = 0; i < widget.subCategories.length; i++) {
      if (i % 2 == 0) {
        leftCol.add(i);
      } else {
        rightCol.add(i);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: leftCol.map((index) {
              final subCat = widget.subCategories[index];
              final double height = _getSubCardHeight(index, isLeft: true);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _SubCategoryCard(
                  subCategory: subCat,
                  height: height,
                  isDark: isDark,
                  onTap: () => _onSubCategoryTap(context, subCat),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            children: rightCol.map((index) {
              final subCat = widget.subCategories[index];
              final double height = _getSubCardHeight(index, isLeft: false);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _SubCategoryCard(
                  subCategory: subCat,
                  height: height,
                  isDark: isDark,
                  onTap: () => _onSubCategoryTap(context, subCat),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  double _getSubCardHeight(int index, {required bool isLeft}) {
    final heightsLeft = [180.0, 260.0, 140.0, 220.0, 190.0];
    final heightsRight = [280.0, 170.0, 220.0, 160.0, 240.0];

    if (isLeft) {
      return heightsLeft[index ~/ 2 % heightsLeft.length];
    } else {
      return heightsRight[index ~/ 2 % heightsRight.length];
    }
  }

  void _onSubCategoryTap(BuildContext context, SubCategory subCategory) {
    if (subCategory.events.length == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailPage(
            eventTitle: subCategory.events.first.title,
            event: subCategory.events.first,
          ),
        ),
      );
    } else {
      showEventDetail(context, subCategory);
    }
  }
}

class _SubCategoryCard extends StatelessWidget {
  final SubCategory subCategory;
  final double height;
  final bool isDark;
  final VoidCallback onTap;

  const _SubCategoryCard({
    required this.subCategory,
    required this.height,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = AppTheme.darkCardsBg;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: cardBg.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _SubCategoryArchedPainter(
                  color: const Color(0xFF4C7AAB).withOpacity(0.25),
                ),
              ),
            ),
            if (subCategory.imageAsset.isNotEmpty)
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                top: 54,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    subCategory.imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF232542),
                      child: const Icon(
                        Icons.event,
                        color: Colors.white54,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Text(
                subCategory.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppTheme.fontGeneralSans,
                  letterSpacing: -0.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubCategoryArchedPainter extends CustomPainter {
  final Color color;

  _SubCategoryArchedPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (int i = 0; i < 4; i++) {
      final rect = Rect.fromLTWH(
        10.0 + (i * 14),
        35.0 + (i * 12),
        size.width * 0.8,
        size.height * 0.8,
      );
      canvas.drawArc(rect, 3.14, 3.14, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
