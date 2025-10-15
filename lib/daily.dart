// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'app_colors.dart';
//张连翰：每日练习界面
void main() {
  runApp(const DailyPracticeApp());
}

class DailyPracticeApp extends StatelessWidget {
  const DailyPracticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Practice',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DailyPracticePage(),
    );
  }
}

enum CheckInButtonState { disabled, enabled, loading, success }

class Task {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  String status; // "not-started" or "completed"

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    this.status = 'not-started',
  });

  Task copyWith({String? status}) {
    return Task(
      id: id,
      title: title,
      description: description,
      difficulty: difficulty,
      status: status ?? this.status,
    );
  }
}

class DailyPracticePage extends StatefulWidget {
  const DailyPracticePage({super.key});

  @override
  State<DailyPracticePage> createState() => _DailyPracticePageState();
}

class _DailyPracticePageState extends State<DailyPracticePage> {
  int consecutiveDays = 7;
  CheckInButtonState checkInButtonState = CheckInButtonState.disabled;
  bool showSuccessDialog = false;

  late List<Task> tasks;

  // Page controller for "carousel"
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void initState() {
    super.initState();
    tasks = [
      Task(
        id: '1',
        title: 'Emotion Matching',
        description: 'Help children recognize different emotions and improve emotional awareness',
        difficulty: 'Beginner',
      ),
      Task(
        id: '2',
        title: 'Color Recognition Game',
        description: 'Learn various colors through fun games and develop observation skills',
        difficulty: 'Beginner',
      ),
      Task(
        id: '3',
        title: 'Number Matching Exercise',
        description: 'Learn the relationship between numbers and quantities, develop mathematical thinking',
        difficulty: 'Intermediate',
      ),
    ];

    _updateButtonState();
  }

  bool get hasCompletedTask => tasks.any((t) => t.status == 'completed');

  void _updateButtonState() {
    if (checkInButtonState == CheckInButtonState.loading ||
        checkInButtonState == CheckInButtonState.success) {
      // don't overwrite loading/success
      return;
    }
    setState(() {
      checkInButtonState = hasCompletedTask ? CheckInButtonState.enabled : CheckInButtonState.disabled;
    });
  }

  void handleTaskStart(String taskId) {
    setState(() {
      tasks = tasks.map((t) {
        if (t.id == taskId) {
          return t.copyWith(status: 'completed');
        }
        return t;
      }).toList();
    });
    _updateButtonState();
  }

  Future<void> handleCheckIn() async {
    if (checkInButtonState != CheckInButtonState.enabled) return;

    setState(() {
      checkInButtonState = CheckInButtonState.loading;
    });

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      checkInButtonState = CheckInButtonState.success;
      consecutiveDays += 1;
      showSuccessDialog = true;
    });

    // Show dialog
    _showSuccessDialog();

    // Reset after 3 seconds (simulating UI feedback and then reset)
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        checkInButtonState = CheckInButtonState.disabled;
        // reset tasks to not-started
        tasks = tasks.map((t) => t.copyWith(status: 'not-started')).toList();
      });
      _updateButtonState();
    });
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉 Check-in Successful!', style: TextStyle(fontSize: 18, color: Colors.green)),
              const SizedBox(height: 12),
              // Network image with fallback using errorBuilder
              SizedBox(
                width: 160,
                height: 160,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1743677077216-00a458eff9e0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjaGlsZCUyMGxlYXJuaW5nJTIwcm9ib3QlMjBjZWxlYnJhdGlvbnxlbnwxfHx8fDE3NTk3NTEyOTJ8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.celebration, size: 48, color: Colors.grey),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Consecutive completion', style: TextStyle(color: Colors.black87)),
              const SizedBox(height: 6),
              Text('$consecutiveDays days', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Persistence is victory, keep going!', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 4),
            ],
          ),
        );
      },
    ).then((_) {
      // dialog closed
      setState(() {
        showSuccessDialog = false;
      });
    });
  }

  ButtonStyle _buttonStyleForState(CheckInButtonState state) {
    switch (state) {
      case CheckInButtonState.disabled:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.grey[500],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size.fromHeight(56),
        );
      case CheckInButtonState.enabled:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size.fromHeight(56),
        );
      case CheckInButtonState.loading:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size.fromHeight(56),
        );
      case CheckInButtonState.success:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size.fromHeight(56),
        );
    }
  }

  String _buttonTextForState(CheckInButtonState state) {
    switch (state) {
      case CheckInButtonState.disabled:
      case CheckInButtonState.enabled:
        return 'Complete Check-in';
      case CheckInButtonState.loading:
        return 'Checking in...';
      case CheckInButtonState.success:
        return 'Check-in Successful';
    }
  }

  @override
  Widget build(BuildContext context) {
    // top-level scaffold similar to your React layout
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA), // bg-gray-50 like
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Text('Daily Practise', style: TextStyle(color: Colors.black87)),
        actions: [
          IconButton(
            onPressed: () {
              // placeholder for statistics action
            },
            icon: const Icon(Icons.bar_chart_rounded, color: Colors.grey),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            children: [
              // Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('All Practices', style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        )),
                      SizedBox(height: 6),
                      Text('Complete any exercise to check in successfully', style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary
                        )),
                    ],
                  ),
                ),
              ),

              // Tasks section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        ],
                      ),
                    ),

                    // Carousel with PageView
                    SizedBox(
                      height: 160,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: tasks.length,
                            padEnds: false,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return Padding(
                                padding: const EdgeInsets.only(left: 12.0, right: 8.0, top: 8, bottom: 8),
                                child: TaskCard(
                                  task: task,
                                  onStart: () => handleTaskStart(task.id),
                                ),
                              );
                            },
                          ),
                          // left/right small floating indicators (visible on small widths in original - here always visible)
                          Positioned(
                            left: 6,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(Icons.chevron_left, color: AppColors.primary, size: 20),
                            ),
                          ),
                          Positioned(
                            right: 6,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(Icons.chevron_right, color: AppColors.primary, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Consecutive days card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Consecutive Days', style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        )),
                      Text('$consecutiveDays days', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),

              // Check-in Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: (checkInButtonState == CheckInButtonState.disabled ||
                              checkInButtonState == CheckInButtonState.loading ||
                              checkInButtonState == CheckInButtonState.success)
                          ? null
                          : handleCheckIn,
                      style: _buttonStyleForState(checkInButtonState),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (checkInButtonState == CheckInButtonState.loading) ...[
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2.2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Text(_buttonTextForState(checkInButtonState), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,)
                          ),
                        ],
                      ),
                    ),
                    if (!hasCompletedTask)
                      const Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                          'Please complete at least one exercise task',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),

              // History Link
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: TextButton(
                    onPressed: () {
                      // placeholder: open history
                    },
                    child: const Text('View Check-in History', style: TextStyle(color: Colors.black54)),
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

/// A small TaskCard widget that mimics the TaskCard component from React version.
/// It shows title, description, difficulty and a "Start"/"Completed" button.
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onStart;

  const TaskCard({
    super.key,
    required this.task,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final bool completed = task.status == 'completed';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // image placeholder / icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.auto_awesome, color: AppColors.primary, size: 34),
          ),
          const SizedBox(width: 12),
          // content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(task.description, style: const TextStyle(color: Colors.black54, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(task.difficulty, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ElevatedButton(
                      onPressed: completed ? null : onStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: completed ? Colors.grey[300] : AppColors.primary,
                        foregroundColor: completed ? Colors.black54 : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(completed ? 'Completed' : 'Start'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
