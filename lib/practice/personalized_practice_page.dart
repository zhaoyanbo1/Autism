import 'package:flutter/material.dart';
import '../app_colors.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';



class PersonalizedPracticePage extends StatefulWidget {
  const PersonalizedPracticePage({super.key});

  @override
  State<PersonalizedPracticePage> createState() =>
      _PersonalizedPracticePageState();
}

class _PersonalizedPracticePageState extends State<PersonalizedPracticePage> {
  final List<String> scenes = const ['Any', 'Living Room', 'Bedroom', 'Bathroom', 'Kitchen', 'Balcony', 'Garden', 'Custom'];
  final List<String> toys = const ['No Props', 'Building Blocks', 'Toy Car', 'Picture Book', 'Ball', 'Custom'];
  final List<String> fields = const ['Any', 'Language Expression', 'Social Interaction', 'Emotion Recognition', 'Hand-Eye Coordination', 'Daily Skills', 'Custom'];

  String? scene;
  String? toy;
  String? field;

  Difficulty difficulty = Difficulty.intermediate;

  @override
  void initState() {
    super.initState();
    scene = scenes.first;
    toy = toys.first;
    field = fields.first;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final maxW = _responsiveMaxWidth(size.width);
    final horizontalPad = _responsiveHorizontalPadding(size.width);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Personalized Practice'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      // 替换 Scaffold 的 body:
      body: LayoutBuilder(
        builder: (context, viewport) {
          final size = MediaQuery.of(context).size;
          final hPad = _responsiveHorizontalPadding(size.width);
          final maxW = _responsiveMaxWidth(size.width);

          return CustomScrollView(
            slivers: [
              // 顶部内容
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 12),
                sliver: SliverToBoxAdapter(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: const _TopBanner(),
                  ),
                ),
              ),

              // 表单卡片
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                sliver: SliverToBoxAdapter(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: _CardContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _DropdownField(
                            label: 'Scene',
                            value: scene,
                            items: scenes,
                            onChanged: (v) => setState(() => scene = v),
                          ),
                          const SizedBox(height: 12),
                          _DropdownField(
                            label: 'Toy Materials',
                            value: toy,
                            items: toys,
                            onChanged: (v) => setState(() => toy = v),
                          ),
                          const SizedBox(height: 12),
                          _DropdownField(
                            label: 'Training Field',
                            value: field,
                            items: fields,
                            onChanged: (v) => setState(() => field = v),
                          ),
                          const SizedBox(height: 20),
                          const _SectionTitle('Difficulty Selection'),
                          const SizedBox(height: 10),
                          _DifficultySegmented(
                            value: difficulty,
                            onChanged: (d) => setState(() => difficulty = d),
                          ),
                          const SizedBox(height: 20),
                          const _SectionTitle('Add Photo (Optional)'),
                          const SizedBox(height: 10),
                          const _DashedUploadBox(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 关键：占满剩余高度，把按钮推到可视区底部（无 ScrollBody）
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 你可以按需调这个间距，让按钮离卡片远/近一些
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Generating • $scene / $toy / $field • '
                                        '${difficulty.name[0].toUpperCase()}${difficulty.name.substring(1)}',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Generate Practice'),
                          ),
                        ),
                        const SafeArea(top: false, child: SizedBox(height: 8)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// —— 自适应断点与留白 —— ///

double _responsiveMaxWidth(double screenWidth) {
  // 断点：<=480（小手机）、<=800（大手机/小平板）、<=1200（平板）、>1200（桌面）
  if (screenWidth <= 480) return screenWidth;
  if (screenWidth <= 800) return 680;
  if (screenWidth <= 1200) return 820;
  return 960;
}

double _responsiveHorizontalPadding(double screenWidth) {
  if (screenWidth <= 480) return 12;
  if (screenWidth <= 800) return 16;
  if (screenWidth <= 1200) return 24;
  return 32;
}

class _TopBanner extends StatelessWidget {
  const _TopBanner();

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;
    final w = MediaQuery.of(context).size.width;
    final radius = w <= 480 ? 12.0 : 16.0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 0, bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.08), primary.withOpacity(0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // color: primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, color: primary, size: 20),
                  const SizedBox(width: 10),
                  // Expanded(
                  //   child: Text(
                  //     'Set training goals and let AI generate personalized activities for you',
                  //     style: TextStyle(
                  //       color: Colors.black.withOpacity(0.85),
                  //       fontSize: 18,
                  //       fontWeight: FontWeight.w700,
                  //       height: 1.5,
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                    child: RichText(
                      textAlign: TextAlign.justify, // 两端对齐
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.85),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                        children: const [
                          TextSpan(
                            text:
                            'Set your training goals and let AI generate personalized activities for your child’s growth',
                          ),
                        ],
                      ),
                      strutStyle: const StrutStyle(forceStrutHeight: true, height: 1.5, leading: .3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Text(
              //   'Based on your choices, AI will generate personalized practice content for your child',
              //   style: TextStyle(
              //     color: Colors.black.withOpacity(0.65),
              //     // ✅ 副标题字体略大 + 行距微调
              //     fontSize: 18,
              //     height: 1.5,
              //   ),
              // ),
              // RichText(
              //   textAlign: TextAlign.justify,
              //   text: TextSpan(
              //     style: TextStyle(
              //       color: Colors.black.withOpacity(0.65),
              //       fontSize: 15,
              //       height: 1.5,
              //     ),
              //     children: const [
              //       TextSpan(
              //         text:
              //         'Based on your choices, AI will generate personalized practice content for your child',
              //       ),
              //       TextSpan(text: ' '),
              //       TextSpan(
              //         text: '\u200A\u200A\u200A\u200A\u200A\u200A\u200A\u200A',
              //         style: TextStyle(fontSize: 0.1, color: Colors.transparent),
              //       ),
              //     ],
              //   ),
              //   strutStyle: const StrutStyle(forceStrutHeight: true, height: 1.5, leading: .3),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

/// —— 浅蓝底内容卡片（边框 + 圆角） —— ///
class _CardContainer extends StatelessWidget {
  const _CardContainer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final radius = w <= 480 ? 14.0 : 18.0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FF),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFD9E6FF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        14,
        w <= 480 ? 12 : 16,
        14,
        w <= 480 ? 12 : 16,
      ),
      child: child,
    );
  }
}

/// —— 下拉选择（浅灰输入框风格） —— ///
class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final borderColor = const Color(0xFFE6ECF7);
    final radius = w <= 480 ? 10.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black.withOpacity(0.70),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                items: items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// —— 标题 —— ///
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.black.withOpacity(0.75),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// —— 难度分段按钮（3 选 1） —— ///
enum Difficulty { beginner, intermediate, advanced }

class _DifficultySegmented extends StatelessWidget {
  const _DifficultySegmented({required this.value, required this.onChanged});

  final Difficulty value;
  final ValueChanged<Difficulty> onChanged;

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;
    final w = MediaQuery.of(context).size.width;
    final radius = w <= 480 ? 8.0 : 10.0;

    const items = [
      (Difficulty.beginner, 'Beginner'),
      (Difficulty.intermediate, 'Intermediate'),
      (Difficulty.advanced, 'Advanced'),
    ];

    return Row(
      children: items.map((pair) {
        final d = pair.$1;
        final label = pair.$2;
        final selected = d == value;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onChanged(d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? primary : Colors.white,
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: const Color(0xFFDFE8F5)),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : Colors.black.withOpacity(0.75),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// —— 虚线上传框（支持相册/相机 + 预览 + 清除 + 回调） —— ///
class _DashedUploadBox extends StatefulWidget {
  const _DashedUploadBox({this.onImageChanged});

  /// ✅ 新增：图片变化时回调（可选，不传也可正常运行）
  final void Function(Uint8List? bytes)? onImageChanged;

  @override
  State<_DashedUploadBox> createState() => _DashedUploadBoxState();
}

class _DashedUploadBoxState extends State<_DashedUploadBox> {
  final ImagePicker _picker = ImagePicker();

  XFile? _file;
  Uint8List? _bytes; // 用 bytes 显示以兼容 Web & 移动端

  Future<void> _pick(ImageSource source) async {
    try {
      final x = await _picker.pickImage(
        source: source,
        imageQuality: 85,  // 压缩质量（0-100）
        maxWidth: 1600,    // 最大宽度，等比缩放
      );
      if (x == null) return;

      final data = await x.readAsBytes();
      setState(() {
        _file = x;
        _bytes = data;
      });
      widget.onImageChanged?.call(_bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _clear() {
    setState(() {
      _file = null;
      _bytes = null;
    });
    widget.onImageChanged?.call(null);
  }

  void _showPickSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pick(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pick(ImageSource.camera);
                },
              ),
              if (_file != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Remove'),
                  onTap: () {
                    Navigator.pop(context);
                    _clear();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hintMain = Colors.black.withOpacity(0.65);
    final hintSub = Colors.black.withOpacity(0.55);

    return CustomPaint(
      painter: _DashedBorderPainter(color: const Color(0xFFCCD9EE)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            // 预览区域（点它也能选择图片）
            GestureDetector(
              onTap: _showPickSheet,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 360, minHeight: 120),
                      width: double.infinity,
                      height: 160,
                      color: const Color(0xFFE8F0FF),
                      alignment: Alignment.center,
                      child: _bytes == null
                          ? Icon(Icons.image, size: 40, color: AppColors.primary)
                          : Image.memory(_bytes!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                    ),
                    // 清除按钮（仅在有图时显示）
                    if (_bytes != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap: _clear,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Color(0x22000000), blurRadius: 8),
                              ],
                            ),
                            child: const Icon(Icons.close_rounded, size: 18),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 圆形拍照/选择按钮（长按清除）
            GestureDetector(
              onTap: _showPickSheet,
              onLongPress: _file != null ? _clear : null,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  _file == null ? Icons.photo_camera_outlined : Icons.edit_outlined,
                  color: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 10),
            Text(
              _file == null
                  ? 'Click to upload photo or take picture'
                  : 'Tap to change • Long press to remove',
              style: TextStyle(color: hintMain, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Take or upload a photo to provide current child or\n'
                  'scene information, AI will generate better practices\n'
                  'based on the image.',
              textAlign: TextAlign.center,
              style: TextStyle(color: hintSub, height: 1.25),
            ),
          ],
        ),
      ),
    );
  }
}


/// —— 虚线边框绘制 —— ///
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(14),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = 1.5;

    const dash = 6.0;
    const gap = 4.0;

    final path = Path()..addRRect(r);
    final metrics = path.computeMetrics();
    for (final m in metrics) {
      double dist = 0;
      while (dist < m.length) {
        final next = dist + dash;
        final extract = m.extractPath(dist, next.clamp(0, m.length));
        canvas.drawPath(extract, paint);
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}
