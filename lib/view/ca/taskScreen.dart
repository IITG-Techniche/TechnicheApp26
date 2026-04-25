/// CA (Campus Ambassador) Tasks Screen
library;
import 'package:techniche26/services/ca_api_service.dart';
import 'package:techniche26/controller/riverpod_controller/ca_user_provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:url_launcher/url_launcher.dart';
import 'ca_header.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final Map<String, TextEditingController> linkControllers = {};

  List pendingTasks = [];
  List rejectedTasks = [];
  List acceptedTasks = [];
  List nonsubmittedTasks = [];
  bool isLoading = false;
  String selectedFilter = 'all';
  String? errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchTasks();
  }

  @override
  void dispose() {
    linkControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> fetchTasks() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = ref.read(caUserProvider);
      final response = await CaApiService.fetchTasks(user.email);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          pendingTasks = data['pendingTasks'];
          rejectedTasks = data['rejectedTasks'];
          acceptedTasks = data['acceptedTasks'];
          nonsubmittedTasks = data['nonsubmittedtask'];
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load tasks. Please try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error loading tasks. Please check your connection.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> submitTask(
      String taskId, String link, bool isResubmission) async {
    try {
      final user = ref.read(caUserProvider);

      if (isResubmission) {
        final response =
            await CaApiService.resubmitTask(user.email, taskId, link);

        if (response.statusCode != 200) {
          throw Exception('Failed to resubmit task');
        }

        setState(() {
          final taskIndex =
              rejectedTasks.indexWhere((t) => t['id'].toString() == taskId);
          if (taskIndex != -1) {
            final task = rejectedTasks.removeAt(taskIndex);
            pendingTasks.add(task);
          }
        });
      } else {
        final submitResponse =
            await CaApiService.submitTask(user.email, taskId, link);

        if (submitResponse.statusCode != 200) {
          throw Exception('Failed to submit task');
        }

        final updateResponse =
            await CaApiService.updateTaskStatus(user.email, taskId);

        if (updateResponse.statusCode != 200) {
          throw Exception('Failed to update task status');
        }

        setState(() {
          final taskIndex =
              nonsubmittedTasks.indexWhere((t) => t['id'].toString() == taskId);
          if (taskIndex != -1) {
            final task = nonsubmittedTasks.removeAt(taskIndex);
            pendingTasks.add(task);
          }
        });
      }

      linkControllers[taskId]?.clear();

      if (mounted) {
        showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar('Error submitting task. Please try again.');
      }
    }
  }

  List get filteredTasks {
    switch (selectedFilter) {
      case 'success':
        return List.from(acceptedTasks);
      case 'failed':
        return List.from(rejectedTasks);
      case 'pending':
        return List.from(pendingTasks);
      default:
        return [
          ...List.from(nonsubmittedTasks),
          ...List.from(rejectedTasks),
          ...List.from(pendingTasks),
          ...List.from(acceptedTasks)
        ];
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return const Color(0xFF002B5B);
      default:
        return const Color(0xFF6D7985);
    }
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Success!',
            style: TextStyle(
                fontFamily: 'Univers',
                fontWeight: FontWeight.bold,
                color: Color(0XFF232930))),
        content: const Text(
            'Your task has been submitted and will be verified shortly.',
            style: TextStyle(
                fontFamily: 'General Sans', color: Color(0xFF6D7985))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it',
                style: TextStyle(
                    fontFamily: 'General Sans',
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002B5B))),
          ),
        ],
      ),
    );
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: const TextStyle(fontFamily: 'General Sans')),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget buildFilterChip(String label, String value) {
    final isSelected = selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => setState(() => selectedFilter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF002B5B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isSelected
                    ? const Color(0xFF002B5B)
                    : const Color(0xFFE8E8E8)),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: const Color(0xFF002B5B).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF6D7985),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              fontFamily: 'General Sans',
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTaskCard(dynamic task, String status) {
    final taskId = task['id'].toString();
    linkControllers.putIfAbsent(taskId, () => TextEditingController());

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task['task'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'Univers',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0XFF232930),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TaskPointsBadge(
                points: task['points']?.toString() ?? '0',
                status: status,
                color: _getStatusColor(status),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if ((task['descriptions'] ?? '').isNotEmpty)
            _ExpandableHtmlDescription(htmlData: task['descriptions']),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 14, color: Color(0xFF6D7985)),
              const SizedBox(width: 8),
              Text(
                'Due: ${task['dateOfSub'] ?? 'N/A'}',
                style: const TextStyle(
                  fontFamily: 'General Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF6D7985),
                ),
              ),
            ],
          ),
          const Divider(height: 32, color: Color(0xFFF5F5F5)),
          if (status == 'nonsubmitted' || status == 'rejected')
            TaskSubmissionForm(
              controller: linkControllers[taskId]!,
              onSubmit: () {
                final link = linkControllers[taskId]?.text.trim();
                if (link?.isEmpty ?? true) {
                  showErrorSnackbar('Please enter a link');
                  return;
                }
                submitTask(taskId, link!, status == 'rejected');
              },
              isResubmission: status == 'rejected',
            )
          else if (status == 'pending')
            const TaskStatusView(
              status: 'pending',
              message: 'Submission under review',
              statusText: 'Under Review',
              statusColor: Color(0xFF002B5B),
            )
          else if (status == 'accepted')
            const TaskStatusView(
              status: 'accepted',
              message: 'Great work! Task validated.',
              statusText: 'Verified',
              statusColor: Colors.green,
            )
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                )
              ],
            ),
            child: const Icon(
              Icons.assignment_turned_in_rounded,
              size: 48,
              color: Color(0xFFE8E8E8),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No tasks found here',
            style: TextStyle(
              fontFamily: 'Univers',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0XFF232930),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check other categories or wait for updates',
            style: TextStyle(
              fontFamily: 'General Sans',
              fontSize: 14,
              color: const Color(0XFF232930).withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF1F5),
      body: Column(
        children: [
          const CAHeader(title: 'TASKS'),
          _buildFilterBar(),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                    color: Color(0xFF002B5B),
                    strokeWidth: 3,
                  ))
                : errorMessage != null
                    ? _buildErrorState()
                    : RefreshIndicator(
                        onRefresh: fetchTasks,
                        color: const Color(0xFF002B5B),
                        child: filteredTasks.isEmpty
                            ? buildEmptyState()
                            : ListView.builder(
                                itemCount: filteredTasks.length,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final task = filteredTasks[index];
                                  String status;

                                  if (acceptedTasks.contains(task)) {
                                    status = 'accepted';
                                  } else if (rejectedTasks.contains(task)) {
                                    status = 'rejected';
                                  } else if (pendingTasks.contains(task)) {
                                    status = 'pending';
                                  } else {
                                    status = 'nonsubmitted';
                                  }

                                  return buildTaskCard(task, status);
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFAFAFAF)),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Center(
            child: Text(
              'CA TASKS',
              style: TextStyle(
                color: Color(0XFF232930),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Univers',
                height: 1.2,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            buildFilterChip('ALL TASKS', 'all'),
            buildFilterChip('COMPLETED', 'success'),
            buildFilterChip('PENDING', 'pending'),
            buildFilterChip('FAILED', 'failed'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 48, color: Colors.redAccent),
            const SizedBox(height: 24),
            Text(
              errorMessage ?? 'Connection lost',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Univers',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0XFF232930),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: fetchTasks,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002B5B),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('TRY AGAIN',
                  style: TextStyle(fontFamily: 'Univers')),
            ),
          ],
        ),
      ),
    );
  }
}

// Modular Widgets
class TaskPointsBadge extends StatelessWidget {
  final String points;
  final String status;
  final Color color;

  const TaskPointsBadge({
    super.key,
    required this.points,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars_rounded, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            '$points PTs',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontFamily: 'Univers',
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class TaskSubmissionForm extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final bool isResubmission;

  const TaskSubmissionForm({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.isResubmission = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          style: const TextStyle(fontFamily: 'General Sans', fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Paste submission link here',
            hintStyle: TextStyle(
                color: const Color(0xFF6D7985).withOpacity(0.5), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF002B5B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isResubmission ? Icons.refresh_rounded : Icons.send_rounded,
                  size: 18),
              const SizedBox(width: 12),
              Text(
                isResubmission ? 'RESUBMIT TASK' : 'SUBMIT TASK',
                style: const TextStyle(
                    fontFamily: 'Univers',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TaskStatusView extends StatelessWidget {
  final String status;
  final String message;
  final String statusText;
  final Color statusColor;

  const TaskStatusView({
    super.key,
    required this.status,
    required this.message,
    required this.statusText,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              status == 'pending'
                  ? Icons.hourglass_empty_rounded
                  : Icons.verified_rounded,
              size: 20,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Univers',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 13,
                    color: statusColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableHtmlDescription extends StatefulWidget {
  final String htmlData;
  const _ExpandableHtmlDescription({required this.htmlData});

  @override
  State<_ExpandableHtmlDescription> createState() =>
      _ExpandableHtmlDescriptionState();
}

class _ExpandableHtmlDescriptionState
    extends State<_ExpandableHtmlDescription> {
  bool expanded = false;
  static const int previewCharLimit = 120;

  String get _plainTextPreview {
    final document = html_parser.parse(widget.htmlData);
    final text = document.body?.text ?? '';
    if (text.length <= previewCharLimit) return text;
    return '${text.substring(0, previewCharLimit)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!expanded)
          Text(
            _plainTextPreview,
            style: TextStyle(
              fontFamily: 'General Sans',
              color: const Color(0XFF232930).withOpacity(0.7),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        if (expanded)
          Html(
            data: widget.htmlData,
            style: {
              "body": Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                color: const Color(0XFF232930).withOpacity(0.8),
                fontSize: FontSize(14),
                fontFamily: 'General Sans',
                lineHeight: LineHeight.number(1.5),
              ),
              "a": Style(
                color: const Color(0xFF002B5B),
                textDecoration: TextDecoration.underline,
                fontWeight: FontWeight.bold,
              ),
            },
            onAnchorTap: (url, attributes, element) {
              if (url != null) {
                final uri = Uri.tryParse(url);
                if (uri != null) {
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
          ),
        const SizedBox(height: 8),
        if ((html_parser.parse(widget.htmlData).body?.text.length ?? 0) >
            previewCharLimit)
          InkWell(
            onTap: () => setState(() => expanded = !expanded),
            child: Text(
              expanded ? 'Show Less ↑' : 'Read More ↓',
              style: const TextStyle(
                fontFamily: 'General Sans',
                color: Color(0xFF002B5B),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }
}
