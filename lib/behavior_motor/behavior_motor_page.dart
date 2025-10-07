import 'package:flutter/material.dart';
import '../app_colors.dart';
import 'describe_size_page.dart';

enum Difficulty { beginner, middle, advanced }

class BehaviorPage extends StatefulWidget {
  const BehaviorPage({super.key});

  @override
  State<BehaviorPage> createState() => _BehaviorPageState();
}

class _BehaviorPageState extends State<BehaviorPage> {
  Difficulty selected = Difficulty.beginner;

  final List<Activity> all = [
    Activity(
      title: 'Calming Corner Routine',
      type: 'Self-Regulation',
      age: '1–2 yrs',
      description:
      'Create a cozy spot with sensory toys. Practice going there together, taking deep breaths, and squeezing a fidget.',
      icon: Icons.weekend_outlined,
      difficulty: Difficulty.beginner,
      builder: (_) => const DescribeSizePage(),
    ),
    Activity(
      title: 'Hands to Myself',
      type: 'Safety',
      age: '2–3 yrs',
      description:
      'Use a simple social story and role play keeping hands to self when excited. Reinforce with praise stickers.',
      icon: Icons.pan_tool_alt,
      difficulty: Difficulty.beginner,
    ),
    Activity(
      title: 'First/Then Board',
      type: 'Visual Support',
      age: '2–3 yrs',
      description:
      'Show “First clean up, then play outside.” Use pictures and remove them once complete to build predictability.',
      icon: Icons.view_agenda_outlined,
      difficulty: Difficulty.beginner,
    ),
    Activity(
      title: 'Choice Charts',
      type: 'Positive Behavior',
      age: '3–4 yrs',
      description:
      'Offer two positive options (read book or build blocks). Encourage the child to point/say the choice before starting.',
      icon: Icons.checklist_rtl,
      difficulty: Difficulty.middle,
    ),
    Activity(
      title: 'Schedule Walkthrough',
      type: 'Transition',
      age: '3–4 yrs',
      description:
      'Review the day’s schedule with icons each morning. Rehearse what happens when plans change using flexible thinking.',
      icon: Icons.calendar_today_outlined,
      difficulty: Difficulty.middle,
    ),
    Activity(
      title: 'Token Reward Game',
      type: 'Motivation',
      age: '4–5 yrs',
      description:
      'Set a simple rule (“Sit during meal”). Give a token for each success; trade five tokens for a preferred activity.',
      icon: Icons.star_border,
      difficulty: Difficulty.middle,
    ),
    Activity(
      title: 'Problem-Solving Script',
      type: 'Coping Skills',
      age: '4–6 yrs',
      description:
      'Teach “Stop, take breaths, tell what I need.” Practice with pretend scenarios and celebrate using the script.',
      icon: Icons.psychology_alt_outlined,
      difficulty: Difficulty.advanced,
    ),
    Activity(
      title: 'Perspective Taking',
      type: 'Social Thinking',
      age: '5–6 yrs',
      description:
      'Use story cards to discuss what others feel/need. Prompt the child to suggest kind responses or compromises.',
      icon: Icons.groups_2_outlined,
      difficulty: Difficulty.advanced,
    ),
    Activity(
      title: 'Calm-Down Toolbox Plan',
      type: 'Self-Regulation',
      age: '5–7 yrs',
      description:
      'Build a personalized list of calming tools. Role play noticing signs of stress and choosing a matching strategy.',
      icon: Icons.build_circle_outlined,
      difficulty: Difficulty.advanced,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = all.where((a) => a.difficulty == selected).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Behavior'),
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
    final card = Container(
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
    if (activity.builder == null) {
      return card;
    }

    return GestureDetector(
      onTap: () {
        final builder = activity.builder!;
        Navigator.push(
          context,
          MaterialPageRoute(builder: builder),
        );
      },
      child: card,
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
  final WidgetBuilder? builder;

  Activity({
    required this.title,
    required this.type,
    required this.age,
    required this.description,
    required this.icon,
    required this.difficulty,
    this.builder,
  });
}