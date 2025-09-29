import 'package:flutter/material.dart';
import 'app_colors.dart';

enum Difficulty { beginner, middle, advanced }

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  Difficulty selected = Difficulty.beginner;

  final List<Activity> all = [
    Activity(
      title: 'Match Picture to Picture',
      type: 'Matching',
      age: '1–2 yrs',
      description:
      'Lay out two identical picture cards. Help the child place the same picture on top to build early visual discrimination.',
      icon: Icons.image_outlined,
      difficulty: Difficulty.beginner,
    ),
    Activity(
      title: 'Sort by Color',
      type: 'Sorting',
      age: '2–3 yrs',
      description:
      'Provide red and blue objects. Model how to place each color in its own bowl, then let the child try independently.',
      icon: Icons.palette_outlined,
      difficulty: Difficulty.beginner,
    ),
    Activity(
      title: 'Copy Simple Patterns',
      type: 'Pre-academic',
      age: '2–3 yrs',
      description:
      'Use blocks or beads to create AB patterns (red-blue-red). Encourage the child to copy and say the sequence aloud.',
      icon: Icons.view_week_outlined,
      difficulty: Difficulty.beginner,
    ),
    Activity(
      title: 'Follow 2-Step Directions',
      type: 'Comprehension',
      age: '3–4 yrs',
      description:
      'Give clear instructions (“Touch your head, then clap”). Use gestures/visuals if needed and celebrate success.',
      icon: Icons.format_list_numbered,
      difficulty: Difficulty.middle,
    ),
    Activity(
      title: 'Sort by Size',
      type: 'Sorting',
      age: '3–4 yrs',
      description:
      'Provide small, medium, large containers. Guide the child to compare and place objects by size vocabulary.',
      icon: Icons.straighten,
      difficulty: Difficulty.middle,
    ),
    Activity(
      title: 'Count Everyday Items',
      type: 'Math Concepts',
      age: '3–5 yrs',
      description:
      'Count snack pieces or toys together. Emphasize touching each item once and saying numbers slowly (1–5).',
      icon: Icons.exposure_plus_1,
      difficulty: Difficulty.middle,
    ),
    Activity(
      title: 'Sequence My Morning',
      type: 'Executive Skills',
      age: '4–6 yrs',
      description:
      'Use picture cards for wake up, brush teeth, eat breakfast. Ask the child to order them and explain “first/next/last.”',
      icon: Icons.timeline_outlined,
      difficulty: Difficulty.advanced,
    ),
    Activity(
      title: 'Compare Quantities',
      type: 'Math Concepts',
      age: '4–6 yrs',
      description:
      'Place two sets of objects. Prompt the child to decide which has more/less and justify the choice with counting.',
      icon: Icons.balance_outlined,
      difficulty: Difficulty.advanced,
    ),
    Activity(
      title: 'Story Comprehension Questions',
      type: 'Reading',
      age: '5–6 yrs',
      description:
      'After a short story, ask “Who?”, “Where?”, “Why?” Encourage the child to look back at pictures for clues.',
      icon: Icons.question_answer_outlined,
      difficulty: Difficulty.advanced,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = all.where((a) => a.difficulty == selected).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
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
    return Container(
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
    );
  }
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