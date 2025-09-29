import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'speak_page.dart';

void main() => runApp(const AutismDemoApp());

class AutismDemoApp extends StatelessWidget {
  const AutismDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Practice Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.checkinBg,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      themeMode: ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top bar (avatar + people icon)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    // 左边：头像 + 用户名
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: cs.primary.withOpacity(.12),
                          child: Icon(
                            Icons.emoji_emotions,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8), // 头像和名字间距
                        const Text(
                          'Kefan Chen',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    // 右边：people 图标
                    Icon(
                      Icons.people_alt_outlined,
                      color: Colors.black.withOpacity(.6),
                    ),
                  ],
                ),
              ),
            ),

            // Child chip + grid cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'All Practices',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _DomainGrid(),
                      const SizedBox(height: 8),
                      // Container(
                      //   height: 44,
                      //   decoration: BoxDecoration(
                      //     color: AppColors.checkinBg,
                      //     borderRadius: BorderRadius.circular(12),
                      //   ),
                      //   alignment: Alignment.center,
                      //   child: Text(
                      //     'No practice check-ins today',
                      //     style: TextStyle(
                      //       color: Colors.black.withOpacity(.45),
                      //       fontWeight: FontWeight.w600,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),

            // Big CTA button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                child: SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary, // 亮蓝底
                      foregroundColor: Colors.white, // 白字
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Personalized Practice',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Assessments & Reports
            const SliverToBoxAdapter(
              child: _ListCard(
                title: 'Assessments & Reports',
                subtitle: 'Quick screening & tracking',
                trailing: Icon(Icons.assignment_turned_in_outlined, size: 28),
              ),
            ),

            // Personalized Practice
            const SliverToBoxAdapter(
              child: _ListCard(
                title: 'Practice Stats',
                subtitle: 'Tailored plans for your child',
                trailing: Icon(Icons.note_add_outlined, size: 28),
              ),
            ),

            // const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),

      // Bottom navigation (Home / Cube / Profile)
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => setState(() => currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: ''),
          NavigationDestination(icon: Icon(Icons.category_outlined), label: ''),
          NavigationDestination(icon: Icon(Icons.person_outline), label: ''),
        ],
        height: 64,
        backgroundColor: Colors.white,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.white,
      ),
    );
  }
}

class _ChildChip extends StatelessWidget {
  const _ChildChip({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person, size: 16),
          const SizedBox(width: 6),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DomainGrid extends StatelessWidget {
  _DomainGrid({super.key});

  final List<_Domain> domains = [
    _Domain('Leisure', Icons.toys),
    _Domain('Listen', Icons.psychology_alt_outlined), // 原 Receptive Language
    _Domain('Speak', Icons.chat_bubble_outline), // 原 Expressive Language
    _Domain('Emotion', Icons.emoji_emotions_outlined),
    _Domain('Social', Icons.group_outlined),
    _Domain('Learn', Icons.menu_book_outlined), // 原 Learning Skills
    _Domain('Behavior', Icons.account_box_outlined),
    _Domain('Gross\nMotor', Icons.directions_run),
    _Domain('Fine\nMotor', Icons.keyboard_alt_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: domains.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8, // 12 -> 8  更紧
        mainAxisSpacing: 8, // 12 -> 8
        childAspectRatio: 1.1, // 1.0 -> 1.15~1.25
      ),
      itemBuilder: (context, i) => _DomainTile(domain: domains[i]),
    );
  }
}

class _DomainTile extends StatelessWidget {
  const _DomainTile({required this.domain, super.key});
  final _Domain domain;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SpeakPage()),
        );
      },
      child: Stack(
        children: [
          // Card body (single active style)
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBlue, // 更亮的浅蓝
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primary.withOpacity(.25)),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Fixed icon height
                SizedBox(
                  height: 28,
                  child: Icon(domain.icon, size: 28, color: AppColors.primary),
                ),
                const SizedBox(height: 8),

                // Fixed text height
                const SizedBox(
                  height: 34,
                  child: Center(child: _DomainTitle()),
                ),
              ],
            ),
          ),

          // Arrow at top-right
          Positioned(
            top: 8,
            right: 8,
            child: Icon(
              Icons.north_east,
              size: 16,
              color: cs.primary.withOpacity(.8),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper to keep text style tidy
class _DomainTitle extends StatelessWidget {
  const _DomainTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final widget = context.findAncestorWidgetOfExactType<_DomainTile>()!;
    return Text(
      widget.domain.title,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 15,
        height: 1.15,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }
}

class _Domain {
  final String title;
  final IconData icon;
  const _Domain(this.title, this.icon);
}

class _ListCard extends StatelessWidget {
  const _ListCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      // 用全局亮蓝
                      color: AppColors.subtitleBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(.08),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: IconTheme(
                data: IconThemeData(color: cs.primary),
                child: trailing,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
