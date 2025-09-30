// lib/generated_practice_page.dart
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
  int _index = 0;

  // 步骤与道具呼应
  // 步骤与道具呼应 (7步流程)
  late final List<_StepItem> _steps = [
    _StepItem(
      title: 'Set up',
      text:
      'Place all props (cups, toys, paper roll) on the table in mixed order. Keep one big/small pair visible.',
      tip: 'Say: “We will find BIG and SMALL today!”',
    ),
    _StepItem(
      title: 'Introduce',
      text:
      'Show each object briefly. Point to one cup and say: “This is BIG.” Point to the other: “This is SMALL.”',
      tip:
      'Use clear hand gestures: wide arms for BIG, pinch fingers for SMALL.',
    ),
    _StepItem(
      title: 'Model & label',
      text:
      'Pick up the big cup and say “big cup. Then the small cup: “small cup. Repeat with cups or toys.',
      tip: 'Encourage your child to echo your words.',
    ),
    _StepItem(
      title: 'Match pairs',
      text:
      'Place the big cup and small cup together. Ask: “Which is BIG? Which is SMALL?” Do the same for toys.',
      tip: 'Wait for your child’s response before confirming.',
    ),
    _StepItem(
      title: 'Review & praise',
      text:
      'Go over each group again, repeating the labels. End with clapping or high-fives to celebrate success.',
      tip: 'Say: “Great job! You found BIG and SMALL!”',
    ),
  ];

  void _go(int delta) {
    setState(() {
      _index = (_index + delta).clamp(0, _steps.length - 1);
    });
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
          // // 任务简介（含可选照片）
          // Container(
          //   decoration: BoxDecoration(
          //     color: AppColors.cardBlue.withOpacity(.5),
          //     borderRadius: BorderRadius.circular(16),
          //     border: Border.all(color: AppColors.primary.withOpacity(.15)),
          //   ),
          //   padding: const EdgeInsets.all(14),
          //   child: Row(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       _iconBadge(Icons.straighten),
          //       const SizedBox(width: 12),
          //       Expanded(
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             const Text(
          //               'Practice Goal',
          //               style: TextStyle(
          //                 fontWeight: FontWeight.w800,
          //                 fontSize: 16,
          //               ),
          //             ),
          //             const SizedBox(height: 6),
          //             Text(
          //               'Help the child label and compare sizes using real objects '
          //               '(“big” vs “small”). Build comparative vocabulary and clear requests.',
          //               style: TextStyle(
          //                 color: Colors.black.withOpacity(.80),
          //                 height: 1.3,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

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
          _progressBar(_index, _steps.length, AppColors.primary), // 进度条更厚在函数里改
          const SizedBox(height: 12),

          // 替换整块 SizedBox(...) 为：
          AnimatedSize(
            // 高度变化时平滑过渡（可选）
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 当前步骤卡，随内容自适应高度
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: _StepCard(
                    key: ValueKey(_index), // 关键：让 AnimatedSwitcher 正确识别“新卡”
                    item: _steps[_index],
                    index: _index,
                    total: _steps.length,
                  ),
                ),

                // 左右箭头（悬浮在卡片两侧）
                Positioned(
                  left: -6,
                  top: 0,
                  bottom: 0,
                  child: _arrowButton(
                    Icons.chevron_left,
                    onTap: () => _go(-1),
                    enabled: _index > 0,
                  ),
                ),
                Positioned(
                  right: -6,
                  top: 0,
                  bottom: 0,
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
    super.key, // 👈 加上
    required this.item,
    required this.index,
    required this.total,
  }); // 👈 传递给父类

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
          const SizedBox(height: 10),

          // 👉 中间的示例图片
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/steps/step${index + 1}.png',
              width: double.infinity,
              height: 300, // ✅ 限制最大高度
              fit: BoxFit.contain, // ✅ 保持比例，自动缩放
            ),
          ),

          const SizedBox(height: 12),

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
