import 'package:flutter/material.dart';
import '../../../constant/appTheme.dart';
import '../../../model/events_data.dart';
import '../domain/event_reminder.dart';
import '../domain/reminder_manager.dart';

class ReminderPickerSheet extends StatefulWidget {
  final dynamic event;
  final VoidCallback? onReminderUpdated;

  const ReminderPickerSheet({
    super.key,
    required this.event,
    this.onReminderUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required dynamic event,
    VoidCallback? onReminderUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ReminderPickerSheet(
        event: event,
        onReminderUpdated: onReminderUpdated,
      ),
    );
  }

  @override
  State<ReminderPickerSheet> createState() => _ReminderPickerSheetState();
}

class _ReminderPickerSheetState extends State<ReminderPickerSheet> {
  final ReminderManager _manager = ReminderManager();
  EventReminder? _existingReminder;
  bool _isLoading = true;
  int _selectedOffset = 15; // Recommended default 15 minutes

  static const List<Map<String, dynamic>> _options = [
    {'minutes': 5, 'label': '5 minutes', 'subtitle': 'Just before start'},
    {'minutes': 10, 'label': '10 minutes', 'subtitle': 'Quick heads-up'},
    {
      'minutes': 15,
      'label': '15 minutes',
      'subtitle': 'Recommended',
      'isDefault': true
    },
    {'minutes': 30, 'label': '30 minutes', 'subtitle': 'Time to get ready'},
    {'minutes': 60, 'label': '1 hour', 'subtitle': 'Plan ahead'},
  ];

  @override
  void initStatesuper() {
    super.initState();
    _loadExistingReminder();
  }

  @override
  void initState() {
    super.initState();
    _loadExistingReminder();
  }

  Future<void> _loadExistingReminder() async {
    final eventId = _manager.extractEventId(widget.event);
    final reminder = await _manager.getReminder(eventId);
    if (mounted) {
      setState(() {
        _existingReminder = reminder;
        if (reminder != null) {
          _selectedOffset = reminder.offsetMinutes;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _setReminder(int offsetMinutes) async {
    setState(() => _isLoading = true);
    final title = _manager.extractEventTitle(widget.event);

    DateTime? startTime = _manager.extractEventStartTime(widget.event);
    final now = DateTime.now();

    // If event startTime is not set or its reminder time is already in the past,
    // ensure a valid future reminder test time
    if (startTime == null ||
        !startTime.subtract(Duration(minutes: offsetMinutes)).isAfter(now)) {
      startTime = now.add(Duration(minutes: offsetMinutes + 5));
    }

    final success = await _manager.createReminder(
      event: widget.event,
      offsetMinutes: offsetMinutes,
      explicitStartTime: startTime,
    );

    if (mounted) {
      Navigator.pop(context);
      widget.onReminderUpdated?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.notifications_active_rounded : Icons.info_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  success
                      ? 'Reminder set for $title ($offsetMinutes min before)!'
                      : 'Could not set reminder. Please check permissions.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor:
              success ? const Color(0xFF175BCC) : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _cancelReminder() async {
    setState(() => _isLoading = true);
    final eventId = _manager.extractEventId(widget.event);
    final title = _manager.extractEventTitle(widget.event);

    await _manager.removeReminder(eventId: eventId);

    if (mounted) {
      Navigator.pop(context);
      widget.onReminderUpdated?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications_off_outlined,
                  color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Reminder cancelled for $title',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF475569),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = _manager.extractEventTitle(widget.event);

    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardBorder =
        isDark ? const Color(0xFF1E294A) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final primaryBlue = const Color(0xFF175BCC);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: cardBorder, width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header & Event Title
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E294B)
                      : const Color(0xFFE4F0FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remind me before',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppTheme.fontUnivers,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                        fontFamily: AppTheme.fontGeneralSans,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_existingReminder != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: primaryBlue, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Active Reminder: ${_existingReminder!.offsetMinutes} min before',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                        fontFamily: AppTheme.fontGeneralSans,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Options List
          ..._options.map((opt) {
            final minutes = opt['minutes'] as int;
            final label = opt['label'] as String;
            final subtitle = opt['subtitle'] as String;
            final isSelected = _selectedOffset == minutes;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _setReminder(minutes),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryBlue.withOpacity(isDark ? 0.25 : 0.08)
                        : (isDark
                            ? const Color(0xFF131C31)
                            : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? primaryBlue
                          : (isDark
                              ? const Color(0xFF1E294A)
                              : const Color(0xFFE2E8F0)),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: isSelected ? primaryBlue : textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontFamily: AppTheme.fontGeneralSans,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          fontFamily: AppTheme.fontGeneralSans,
                          color: isSelected ? primaryBlue : textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Cancel Reminder Button if already set
          if (_existingReminder != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _isLoading ? null : _cancelReminder,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent, size: 18),
                label: const Text(
                  'Remove Reminder',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: Colors.redAccent.withOpacity(0.3)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
