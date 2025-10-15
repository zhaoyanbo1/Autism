// lib/generated_practice_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class GeneratedPracticePage extends StatefulWidget {
  const GeneratedPracticePage({
    super.key,
    required this.imagePath,
    this.title = 'Big vs Small Match', // 可自定义练习名称
  });

  final String imagePath;
  final String title;

  @override
  State<GeneratedPracticePage> createState() => _GeneratedPracticePageState();
}

class _GeneratedPracticePageState extends State<GeneratedPracticePage> {
  final _pageCtrl = PageController();
  int _index = 0;

  // 道具清单（可按需替换/扩展）
  final List<String> _props = const [
    'Two balls (big & small)',
    'Two cups (big & small)',
    'A soft toy (any size)',
    'Paper towel roll',
  ];

  // 步骤与道具呼应
  // 步骤与道具呼应 (7步流程)
  late final List<_StepItem> _steps = [
    _StepItem(
      title: 'Set up',
      text:
          'Place all props (balls, cups, toy, paper roll) on the table in mixed order. Keep one big/small pair visible.',
      tip: 'Say: “We will find BIG and SMALL today!”',
    ),
    _StepItem(
      title: 'Introduce',
      text:
          'Show each object briefly. Point to one ball and say: “This is BIG.” Point to the other: “This is SMALL.”',
      tip:
          'Use clear hand gestures: wide arms for BIG, pinch fingers for SMALL.',
    ),
    _StepItem(
      title: 'Model & label',
      text:
          'Pick up the big ball and say “big ball”. Then the small ball: “small ball”. Repeat with cups or toys.',
      tip: 'Encourage your child to echo your words.',
    ),
    _StepItem(
      title: 'Match pairs',
      text:
          'Place the big ball and small ball together. Ask: “Which is BIG? Which is SMALL?” Do the same for cups.',
      tip: 'Wait for your child’s response before confirming.',
    ),
    _StepItem(
      title: 'Sort items',
      text:
          'Ask your child to sort all props into two groups: BIG vs SMALL. Help only if needed.',
      tip: 'Say: “Put all BIG things here, SMALL things there.”',
    ),
    _StepItem(
      title: 'Practice turn-taking',
      text:
          'Take turns with your child: you pick one item and label it, then let them choose the next.',
      tip: 'Cheer them on after each correct response.',
    ),
    _StepItem(
      title: 'Review & praise',
      text:
          'Go over each group again, repeating the labels. End with clapping or high-fives to celebrate success.',
      tip: 'Say: “Great job! You found BIG and SMALL!”',
    ),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final next = (_index + delta).clamp(0, _steps.length - 1);
    if (next != _index) {
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // 任务简介（含可选照片）
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBlue.withOpacity(.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(.15)),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _iconBadge(Icons.straighten),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Practice Goal',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Help the child label and compare sizes using real objects '
                        '(“big” vs “small”). Build comparative vocabulary and clear requests.',
                        style: TextStyle(
                          color: Colors.black.withOpacity(.80),
                          height: 1.3,
                        ),
                      ),
                      // if (widget.imagePath.isNotEmpty) ...[
                      //   const SizedBox(height: 12),
                      //   ClipRRect(
                      //     borderRadius: BorderRadius.circular(12),
                      //     child: Image.file(
                      //       File(widget.imagePath),
                      //       height: 140,
                      //       width: double.infinity,
                      //       fit: BoxFit.cover,
                      //     ),
                      //   ),
                      // ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 步骤标题 + 进度
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Game steps',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              Text(
                'Step ${_index + 1}/${_steps.length}',
                style: TextStyle(color: Colors.black.withOpacity(.6)),
              ),
            ],
          ),

          // —— Game steps —— //
          const SizedBox(height: 8),
          _progressBar(_index, _steps.length, cs.primary), // 进度条更厚在函数里改
          const SizedBox(height: 12),

          SizedBox(
            height: 240, // 从 180 提升到 240，留更多阅读空间
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageCtrl,
                  itemCount: _steps.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => _StepCard(
                    item: _steps[i],
                    index: i,
                    total: _steps.length,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _arrowButton(
                    Icons.chevron_left,
                    onTap: () => _go(-1),
                    enabled: _index > 0,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: _arrowButton(
                    Icons.chevron_right,
                    onTap: () => _go(1),
                    enabled: _index < _steps.length - 1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 道具清单
          const Text(
            'Props you’ll need',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(.12)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: _props.map((p) => _propTile(p)).toList(growable: false),
            ),
          ),

          const SizedBox(height: 18),
        ],
      ),
    );
  }

  // —— UI helpers ——

  Widget _iconBadge(IconData icon) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        color: AppColors.cardBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(.25)),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: AppColors.primary),
    );
  }

  Widget _propTile(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.primary.withOpacity(.9),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressBar(int index, int total, Color color) {
    final ratio = (index + 1) / total;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          Container(height: 8, color: color.withOpacity(.12)),
          FractionallySizedBox(
            widthFactor: ratio,
            child: Container(height: 8, color: color),
          ),
        ],
      ),
    );
  }

  Widget _arrowButton(
    IconData icon, {
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: enabled ? Colors.white : Colors.white.withOpacity(.7),
        shape: const CircleBorder(),
        elevation: enabled ? 2 : 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              icon,
              size: 24,
              color: enabled ? AppColors.primary : Colors.black26,
            ),
          ),
        ),
      ),
    );
  }
}

// —— Model + Step card —— //

class _StepItem {
  final String title;
  final String text;
  final String tip;
  _StepItem({required this.title, required this.text, required this.tip});
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.item,
    required this.index,
    required this.total,
  });

  final _StepItem item;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16), // 由 14 → 16
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // 稍大一点
        border: Border.all(color: AppColors.primary.withOpacity(.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部：Step x/y 的小标签
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Step ${index + 1}/$total',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 标题更醒目
          Text(
            item.title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17, // 由 15 → 17
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          // 正文更舒适的行距
          Text(
            item.text,
            style: TextStyle(
              height: 1.45, // 由 1.3 → 1.45
              color: Colors.black.withOpacity(.86),
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),

          // Tip 气泡（更明显但不刺眼）
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(.18)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.tips_and_updates_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.tip,
                    style: TextStyle(
                      color: AppColors.primary,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
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
