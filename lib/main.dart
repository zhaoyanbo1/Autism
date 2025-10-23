import 'package:flutter/material.dart';

// ==== Firebase ====
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'daily.dart';
import 'practice/domain_ai_upload_page.dart';
import 'firebase_options.dart';

// ==== 你的登录页（纯 Flutter 版）====
import 'features/auth/login_page.dart';

// ==== 登出封装（Email + Google 一起登出）====
import 'auth/firebase_auth/auth_util.dart';

// ==== 你原有的页面 & 资源 ====
import 'app_colors.dart';
import 'speak_page.dart';
import 'practice/category_page.dart';
import 'personalized_upload_page.dart';
import 'practice/domain_ai_upload_page.dart';
import 'practice/personalized_practice_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AutismDemoApp());
}

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
      // 登录态网关：未登录 -> LoginPage；已登录 -> HomeScreen
      home: const _AuthGate(child: HomeScreen()),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = snap.data;
        return user == null ? const LoginPage() : child;
      },
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

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will be returned to the login page.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sign out')),
        ],
      ),
    ) ??
        false;
    if (!ok) return;

    await authService.signOut(); // 同时登出 Google/Email
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final displayName =
        FirebaseAuth.instance.currentUser?.displayName ??
            FirebaseAuth.instance.currentUser?.email ??
            'User';

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top bar (avatar + username 可点击登出)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: _logout, // 点击头像/用户名 -> 登出
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: cs.primary.withOpacity(.12),
                            child: Icon(Icons.emoji_emotions, color: AppColors.primary),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            displayName, // 动态显示当前用户
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),
                    Icon(Icons.people_alt_outlined,
                        color: Colors.black.withOpacity(.6)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'All Practices',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 10),
                      _DomainGrid(),
                      SizedBox(height: 8),
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
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PersonalizedPracticePage(),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Personalized Practice',
                            style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
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

            // Practice Stats
            const SliverToBoxAdapter(
              child: _ListCard(
                title: 'Practice Stats',
                subtitle: 'Tailored plans for your child',
                trailing: Icon(Icons.note_add_outlined, size: 28),
              ),
            ),
          ],
        ),
      ),

      // Bottom navigation (Home / Cube / Profile)
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) {
          if (i == 1) {
            // 点击 category 时跳转到 DailyCheckInPage
            // 如果 DailyCheckInPage 在同一个文件，直接用类名；若在其它文件，请在文件头 import 对应路径。
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DailyPracticePage()),
            );
            // 可选：如果你想在页面返回后把底部栏高亮恢复为首页（index 0），取消注释下面一行：
            // setState(() => currentIndex = 0);
          } else {
            setState(() => currentIndex = i);
          }
        },

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
  const _DomainGrid({super.key});

  final List<_Domain> domains = const [
    _Domain('Leisure', Icons.toys),
    _Domain('Listen', Icons.psychology_alt_outlined),
    _Domain('Speak', Icons.chat_bubble_outline),
    _Domain('Emotion', Icons.emoji_emotions_outlined),
    _Domain('Social', Icons.group_outlined),
    _Domain('Learn', Icons.menu_book_outlined),
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
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.1,
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
        if (domain.title == 'Speak') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CategoryPage(category: 'Speak')));
        } else if (domain.title == 'Gross\nMotor') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CategoryPage(category: 'GrossMotor')));
        } else if (domain.title == 'Fine\nMotor') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CategoryPage(category: 'FineMotor')));
        } else if (domain.title == 'Leisure') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CategoryPage(category: 'Leisure')));
        } else if (domain.title == 'Listen') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CategoryPage(category: 'Listen')));
        } else if (domain.title == 'Social') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CategoryPage(category: 'Social')));
        } else if (domain.title == 'Emotion') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CategoryPage(category: 'Emotion')));
        } else if (domain.title == 'Learn') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CategoryPage(category: 'Learn')));
        } else if (domain.title == 'Behavior') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CategoryPage(category: 'Behavior')));
        }
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (_) => const SpeakPage()),
        // );
      },
      child: Stack(
        children: [
          // Card body (single active style)
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBlue,
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
                const SizedBox(height: 34, child: Center(child: _DomainTitle())),
              ],
            ),
          ),

          // Arrow at top-right
          Positioned(
            top: 8,
            right: 8,
            child: Icon(Icons.north_east, size: 16, color: cs.primary.withOpacity(.8)),
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
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                        color: AppColors.subtitleBlue,
                        fontWeight: FontWeight.w600,
                      )),
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
