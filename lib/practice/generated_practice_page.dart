import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../app_colors.dart';

class GeneratedPracticePage extends StatefulWidget {
  final String imagePath; // 从 DescribeSizePage / PracticeIntroPage 传入
  const GeneratedPracticePage({super.key, required this.imagePath});

  @override
  State<GeneratedPracticePage> createState() => _GeneratedPracticePageState();
}

class _GeneratedPracticePageState extends State<GeneratedPracticePage> {
  bool _loading = true;
  String? _error;
  List<dynamic> _steps = [];

  @override
  void initState() {
    super.initState();
    _generateFromAI();
  }

  Future<void> _generateFromAI() async {
    try {
      final uri = Uri.parse("https://your-ai-endpoint.com/api/generate_steps"); // 🔁 改成你的AI接口地址
      final request = http.MultipartRequest("POST", uri)
        ..files.add(await http.MultipartFile.fromPath('image', widget.imagePath));

      // 若接口需要额外字段可在此添加，如 category 或 userId
      request.fields['category'] = 'Leisure';

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        throw Exception("HTTP ${response.statusCode}: $respStr");
      }

      final decoded = json.decode(respStr);
      setState(() {
        _steps = decoded['steps'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generated Practice"),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            "Error generating practice:\n$_error",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 显示上传图片
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(widget.imagePath),
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            "AI-Generated Steps",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),

          if (_steps.isEmpty)
            const Text("No steps returned from AI.")
          else
            ..._steps.asMap().entries.map((entry) {
              final i = entry.key;
              final step = entry.value;
              final title = step['title'] ?? 'Untitled Step';
              final text = step['text'] ?? '';
              final tip = step['tip'] ?? null;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step ${i + 1}: $title',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      text,
                      style: const TextStyle(height: 1.4),
                    ),
                    if (tip != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '💡 $tip',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
