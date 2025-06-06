import 'package:amazon_clone/constant/global.dart';
import 'package:amazon_clone/controller/provider_controller/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

// Main screen widget
class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final String baseUrl = GlobalVariables.baseUrl;
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

  // API Service Methods
  Future<void> fetchTasks() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      final response = await http.post(
        Uri.parse('$baseUrl/catasksupload/showusertasksupdated'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'params': {'email': user.email}
        }),
      );

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
      final user = Provider.of<UserProvider>(context, listen: false).user;

      if (isResubmission) {
        // Handle resubmission for rejected tasks
        final response = await http.put(
          Uri.parse('$baseUrl/catasksupload/submitCorrectLinkByUser'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'taskId': taskId,
            'link': link,
            'email': user.email,
          }),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to resubmit task');
        }

        // Move task from rejected to pending state
        setState(() {
          final taskIndex =
              rejectedTasks.indexWhere((t) => t['id'].toString() == taskId);
          if (taskIndex != -1) {
            final task = rejectedTasks.removeAt(taskIndex);
            pendingTasks.add(task);
          }
        });
      } else {
        // Handle initial submission
        final submitResponse = await http.post(
          Uri.parse('$baseUrl/catasksupload/submitTaskByUser'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'taskId': taskId,
            'link': link,
            'params': {
              'email': user.email,
            }
          }),
        );

        if (submitResponse.statusCode != 200) {
          throw Exception('Failed to submit task');
        }

        // Update task status
        final updateResponse = await http.put(
          Uri.parse('$baseUrl/catasksupload/updateDoneInCATask'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'taskId': taskId,
            'params': {
              'email': user.email,
            }
          }),
        );

        if (updateResponse.statusCode != 200) {
          throw Exception('Failed to update task status');
        }

        // Move task from nonsubmitted to pending state
        setState(() {
          final taskIndex =
              nonsubmittedTasks.indexWhere((t) => t['id'].toString() == taskId);
          if (taskIndex != -1) {
            final task = nonsubmittedTasks.removeAt(taskIndex);
            pendingTasks.add(task);
          }
        });
      }

      // Clear the input field
      linkControllers[taskId]?.clear();

      // Show success dialog
      if (mounted) {
        showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar('Error submitting task. Please try again.');
      }
    }
  }

  // Helper Methods
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
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  // UI Components
  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submitted!'),
        content: const Text(
            'Your task has been submitted and will be verified shortly'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget buildFilterChip(String label, String value) {
    final isSelected = selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() => selectedFilter = value);
        },
        backgroundColor: Colors.grey.shade200,
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget buildTaskCard(dynamic task, String status) {
    final taskId = task['id'].toString();
    linkControllers.putIfAbsent(taskId, () => TextEditingController());

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task['task'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TaskPointsBadge(
                  points: task['points']?.toString() ?? '0',
                  status: status,
                  color: _getStatusColor(status),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              task['descriptions'] ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last Date For Submission: ${task['dateOfSub'] ?? ''}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey.shade800,
              ),
            ),
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
              TaskStatusView(
                status: 'pending',
                message: 'Submission under review',
                statusText: 'Pending Review',
                statusColor: Colors.orange,
              )
            else if (status == 'accepted')
              TaskStatusView(
                status: 'accepted',
                message: 'Task completed',
                statusText: 'Verified',
                statusColor: Colors.green,
              )
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 70,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Tasks Available In This Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check other categories or come back later',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: fetchTasks,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tasks',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  buildFilterChip('ALL TASKS', 'all'),
                  buildFilterChip('SUCCESS', 'success'),
                  buildFilterChip('FAILED', 'failed'),
                  buildFilterChip('PENDING', 'pending'),
                ],
              ),
            ),
          ),

          // Main content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? buildErrorState()
                    : RefreshIndicator(
                        onRefresh: fetchTasks,
                        child: filteredTasks.isEmpty
                            ? buildEmptyState()
                            : ListView.builder(
                                itemCount: filteredTasks.length,
                                padding: const EdgeInsets.all(16),
                                itemBuilder: (context, index) {
                                  final task = filteredTasks[index];
                                  String status;

                                  if (acceptedTasks.contains(task))
                                    status = 'accepted';
                                  else if (rejectedTasks.contains(task))
                                    status = 'rejected';
                                  else if (pendingTasks.contains(task))
                                    status = 'pending';
                                  else
                                    status = 'nonsubmitted';

                                  return buildTaskCard(task, status);
                                },
                              ),
                      ),
          ),
        ],
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
    Key? key,
    required this.points,
    required this.status,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$points PTs',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

class TaskSubmissionForm extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final bool isResubmission;

  const TaskSubmissionForm({
    Key? key,
    required this.controller,
    required this.onSubmit,
    this.isResubmission = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter submission link',
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onSubmit,
              icon: Icon(isResubmission ? Icons.refresh : Icons.send),
              label: Text(isResubmission ? 'Resubmit' : 'Submit'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskStatusView extends StatelessWidget {
  final String status;
  final String message;
  final String statusText;
  final Color statusColor;

  const TaskStatusView({
    Key? key,
    required this.status,
    required this.message,
    required this.statusText,
    required this.statusColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                message,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  status == 'pending'
                      ? Icons.hourglass_top
                      : Icons.check_circle,
                  size: 16,
                  color: statusColor,
                ),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: TextStyle(
                      color: statusColor, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
