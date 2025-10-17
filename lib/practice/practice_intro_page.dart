import 'dart:io';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../app_colors.dart';

import '../backend_config.dart';
import 'generated_practice_page.dart';

class PracticeIntroPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String docId;
  const PracticeIntroPage({super.key, required this.data, required this.docId});

  @override
  State<PracticeIntroPage> createState() => _PracticeIntroPageState();
}

class _PracticeIntroPageState extends State<PracticeIntroPage> {
  XFile? _image;
  bool _sending = false;

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (!mounted) return;
      setState(() => _image = img);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  String _buildInstruction() {
    final data = widget.data;
    final buffer = StringBuffer();

    void writeLine(String label, dynamic value) {
      if (value == null) return;
      final text = value is String ? value.trim() : value.toString().trim();
      if (text.isEmpty) return;
      buffer.writeln('$label: $text');
    }

    writeLine('Practice title', data['title']);
    writeLine('Category', data['category']);
    writeLine('Practice goal', data['practiceGoal']);
    writeLine('Overview', data['description']);
    writeLine('Type', data['type']);
    writeLine('Age range', data['age']);
    writeLine('Template guidance', data['templateDescription'] ?? data['template'] ?? data['templateSummary']);
    writeLine('Key skills', data['skills']);
    writeLine('Additional notes', data['additionalNotes']);

    final prompt = data['aiPrompt'] ?? data['prompt'];
    if (prompt is String && prompt.trim().isNotEmpty) {
      buffer.writeln(prompt.trim());
    }

    final result = buffer.toString().trim();
    return result.isEmpty ? 'Generate a caregiver friendly practice routine for ${data['title'] ?? 'this activity'}.' : result;
  }

  Future<void> _generate() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a photo first')),
      );
      return;
    }
    if (_sending) return;

    setState(() => _sending = true);

    final instruction = _buildInstruction();

    bool dialogShown = false;


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text(
                    "Preparing practice…",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
    );

    dialogShown = true;

    try {
      final request = http.MultipartRequest('POST', Uri.parse(backendEndpoint))
        ..fields['instruction'] = instruction
        ..files.add(await http.MultipartFile.fromPath('image', _image!.path));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200) {
        throw HttpException('Backend error: ${response.statusCode}');
      }

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final resultText = (payload['result'] as String?)?.trim();
      if (resultText == null || resultText.isEmpty) {
        throw const FormatException('Empty response from AI');
      }

      if (!mounted) return;

      if (dialogShown) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogShown = false;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              GeneratedPracticePage(
                imagePath: _image!.path,
                practiceTitle: widget.data['title'] as String? ??
                    'Generated Practice',
                practiceGoal: widget.data['practiceGoal'] as String?,
                rawResult: resultText,
              ),
        ),
      );
    } catch (err) {
      if (!mounted) return;
      if (dialogShown) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogShown = false;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate practice: $err')),
      );
    } finally {
      if (mounted) {
        if (dialogShown) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        setState(() => _sending = false);
      }
    }
  }

  IconData _parseIcon(String? name) {
    const iconMap = {
      'front_hand_outlined'      : Icons.front_hand_outlined,
      'add_circle_outline'       : Icons.add_circle_outline,
      'label_outline'            : Icons.label_outline,
      'chat_bubble_outline'      : Icons.chat_bubble_outline,
      'switch_left_outlined'     : Icons.switch_left_outlined,
      'straighten'               : Icons.straighten,
      'auto_stories_outlined'    : Icons.auto_stories_outlined,
      'mood_outlined'            : Icons.mood_outlined,
      'menu_book_outlined'       : Icons.menu_book_outlined,

      'hearing_outlined'         : Icons.hearing_outlined,
      'pets_outlined'            : Icons.pets_outlined,
      'music_note_outlined'      : Icons.music_note_outlined,
      'circle_outlined'          : Icons.circle_outlined,
      'rule_folder_outlined'     : Icons.rule_folder_outlined,
      'auto_fix_high_outlined'   : Icons.auto_fix_high_outlined,
      'timeline_outlined'        : Icons.timeline_outlined,

      'image_outlined'           : Icons.image_outlined,
      'palette_outlined'         : Icons.palette_outlined,
      'view_week_outlined'       : Icons.view_week_outlined,
      'format_list_numbered'     : Icons.format_list_numbered,
      'exposure_plus_1'          : Icons.exposure_plus_1,
      'balance_outlined'         : Icons.balance_outlined,
      'question_answer_outlined' : Icons.question_answer_outlined,

      'weekend_outlined'         : Icons.weekend_outlined,
      'pan_tool_alt'             : Icons.pan_tool_alt,
      'view_agenda_outlined'     : Icons.view_agenda_outlined,
      'checklist_rtl'            : Icons.checklist_rtl,
      'calendar_today_outlined'  : Icons.calendar_today_outlined,
      'star_border'              : Icons.star_border,
      'psychology_alt_outlined'  : Icons.psychology_alt_outlined,
      'groups_2_outlined'        : Icons.groups_2_outlined,
      'build_circle_outlined'    : Icons.build_circle_outlined,

      'lightbulb_outline'        : Icons.lightbulb_outline,
      'tune'                     : Icons.tune,
      'auto_awesome'             : Icons.auto_awesome,

      'pan_tool_outlined'        : Icons.pan_tool_outlined,
      'handshake_outlined'       : Icons.handshake_outlined,
      'construction_outlined'    : Icons.construction_outlined,

      // Leisure 里
      'toys_outlined'            : Icons.toys_outlined,
      'search'                   : Icons.search,
      'sports_esports_outlined'  : Icons.sports_esports_outlined,
      'restaurant_menu_outlined' : Icons.restaurant_menu_outlined,
      'bubble_chart_outlined'    : Icons.bubble_chart_outlined,

    };

    return iconMap[name] ?? Icons.extension_outlined;
  }

  @override
  Widget build(BuildContext context) {

    final data = widget.data;
    final practiceGoal = data['practiceGoal'] ?? 'No goal provided.';
    final icon = _parseIcon(data['icon']);
    final title = data['title'] ?? 'Practice Intro';
    final category = data['category'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // 顶部 Practice Goal 模块
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: AppColors.cardBlue,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(.25)),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Practice Goal",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      practiceGoal,
                      style: const TextStyle(fontSize: 14, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 上传与生成模块
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBlue.withOpacity(.45),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(.15)),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 蓝色提示条
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.smart_toy_outlined, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Generate practice with a photo",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 上传区块
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withOpacity(.15)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      if (_image == null) ...[
                        Icon(Icons.image_outlined, color: AppColors.primary, size: 40),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickFromGallery,
                                icon: const Icon(Icons.photo_camera_outlined),
                                label: const Text("Camera"),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  side: BorderSide(
                                    color: AppColors.primary.withOpacity(.35),
                                  ),
                                  foregroundColor: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickFromGallery,
                                icon: const Icon(Icons.photo_library_outlined),
                                label: const Text("Gallery"),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  side: BorderSide(
                                    color: AppColors.primary.withOpacity(.35),
                                  ),
                                  foregroundColor: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(File(_image!.path),
                              height: 140, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _pickFromGallery,
                          icon: const Icon(Icons.swap_horiz),
                          label: const Text("Choose another"),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: _sending ? null : _generate,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Generate Practice",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          const Text(
            "Practice Examples",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),


          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('examples')
                .where('practiceId', isEqualTo: widget.docId)
                .where('category', isEqualTo: category)
                .snapshots(),

            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('No examples found.');
              }

              final examples = snapshot.data!.docs;
              return Column(
                children: examples.map((doc) {
                  final ex = doc.data() as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border:
                      Border.all(color: AppColors.primary.withOpacity(.15)),
                    ),
                    child: ListTile(
                      title: Text(
                        ex['exampleTitle'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(ex['description'] ?? ''),
                      trailing:
                      const Icon(Icons.chevron_right, color: Colors.black45),
                      onTap: () {},
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
