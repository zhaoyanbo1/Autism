// lib/speak_page.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'describe_size_page.dart';

enum Difficulty { beginner, middle, advanced }

class SpeakPage extends StatefulWidget {
  const SpeakPage({super.key});

  @override
  State<SpeakPage> createState() => _SpeakPageState();
}

class _SpeakPageState extends State<SpeakPage> {
  Difficulty selected = Difficulty.beginner;

  // ---- Demo data ----
  final List<Activity> all = [
    Activity(
      title: 'Ask for Help',
      type: 'Requesting',
      age: '0–1 yr',
      description:
          'Use simple gestures + words to request (e.g., arms up for “pick me up”). Builds early expressive intent.',
      icon: Icons.front_hand_outlined,
      difficulty: Difficulty.beginner,
    ),
    Activity(
      title: '“More”',
      type: 'Requesting',
      age: '1–2 yrs',
      description:
          'Model “more” during snack/play. Child imitates sign/word to continue an activity.',
      icon: Icons.add_circle_outline,
      difficulty: Difficulty.beginner,
    ),
    Activity(
      title: 'I want + Noun',
      type: 'Phrase',
      age: '2–3 yrs',
      description:
          'Prompt short phrases: “I want car / I want bubbles.” Fade prompts as independence grows.',
      icon: Icons.chat_bubble_outline,
      difficulty: Difficulty.middle,
    ),
    Activity(
      title: 'Choice Making',
      type: 'Requesting',
      age: '2–4 yrs',
      description:
          'Offer two visual choices and wait: “juice or water?” Encourage clear, spoken selection.',
      icon: Icons.switch_left_outlined,
      difficulty: Difficulty.middle,
    ),
    Activity(
      title: 'Describe Size',
      type: 'Comparatives',
      age: '2–3 yrs',
      description:
          'Guide the child to label “big” vs “small” with real objects (big ball / small ball).',
      icon: Icons.straighten,
      difficulty: Difficulty.middle,
    ),
    Activity(
      title: 'Tell About My Day',
      type: 'Narrative',
      age: '3–5 yrs',
      description:
          'Use 3-picture sequence to tell what happened: first / then / last. Expand with who/where.',
      icon: Icons.auto_stories_outlined,
      difficulty: Difficulty.advanced,
    ),
    Activity(
      title: 'Explain Feelings',
      type: 'Emotions',
      age: '3–6 yrs',
      description:
          'Label feelings (“I feel sad because…”) and propose a solution (“I need a hug”).',
      icon: Icons.mood_outlined,
      difficulty: Difficulty.advanced,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = all.where((a) => a.difficulty == selected).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Speak'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          const SizedBox(height: 4),
          _DifficultyBar(
            value: selected,
            onChanged: (v) => setState(() => selected = v),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => ActivityCard(activity: items[i]),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- UI pieces ----------------

class _DifficultyBar extends StatelessWidget {
  const _DifficultyBar({required this.value, required this.onChanged});
  final Difficulty value;
  final ValueChanged<Difficulty> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            _Segment(
              label: 'Beginner',
              selected: value == Difficulty.beginner,
              onTap: () => onChanged(Difficulty.beginner),
              position: _SegmentPosition.left,
            ),
            const SizedBox(width: 6),
            _Segment(
              label: 'Middle',
              selected: value == Difficulty.middle,
              onTap: () => onChanged(Difficulty.middle),
              position: _SegmentPosition.middle,
            ),
            const SizedBox(width: 6),
            _Segment(
              label: 'Advanced',
              selected: value == Difficulty.advanced,
              onTap: () => onChanged(Difficulty.advanced),
              position: _SegmentPosition.right,
            ),
          ],
        ),
      ),
    );
  }
}

enum _SegmentPosition { left, middle, right }

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.position,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final _SegmentPosition position;

  @override
  Widget build(BuildContext context) {
    // 等宽：Expanded 平分三段
    return Expanded(
      child: InkWell(
        borderRadius: _radius,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.cardBlue,
            borderRadius: _radius,
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(.25),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  BorderRadius get _radius {
    const r = Radius.circular(12);
    switch (position) {
      case _SegmentPosition.left:
        return const BorderRadius.only(topLeft: r, bottomLeft: r);
      case _SegmentPosition.middle:
        return BorderRadius.zero;
      case _SegmentPosition.right:
        return const BorderRadius.only(topRight: r, bottomRight: r);
    }
  }
}

class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.activity});
  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 判断点击的是哪张卡片
        if (activity.title == "Describe Size") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DescribeSizePage()),
          );
        }
        // 以后你可以在这里加其他跳转
        // else if (activity.title == "Choice Making") { ... }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(.14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconBadge(icon: activity.icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row + chips
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _Tag(activity.type),
                      _Tag(activity.age),
                      // _Tag(_difficultyLabel(activity.difficulty)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    activity.description,
                    style: TextStyle(
                      color: Colors.black.withOpacity(.72),
                      height: 1.25,
                      fontWeight: FontWeight.w500,
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

  // static String _difficultyLabel(Difficulty d) => switch (d) {
  //       Difficulty.beginner => 'Beginner',
  //       Difficulty.middle => 'middle',
  //       Difficulty.advanced => 'Advanced',
  //     };
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
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
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBlue,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withOpacity(.22)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ---------------- model ----------------

class Activity {
  final String title;
  final String type;
  final String age;
  final String description;
  final IconData icon;
  final Difficulty difficulty;

  Activity({
    required this.title,
    required this.type,
    required this.age,
    required this.description,
    required this.icon,
    required this.difficulty,
  });
}
