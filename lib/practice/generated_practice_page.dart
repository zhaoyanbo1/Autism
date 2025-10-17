import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../app_colors.dart';
class GeneratedPracticePage extends StatelessWidget {
  const GeneratedPracticePage({
    super.key,
    required this.imagePath,
    required this.rawResult,
    required this.practiceTitle,
    this.practiceGoal,
  });
  final String imagePath;
  final String rawResult;
  final String practiceTitle;
  final String? practiceGoal;


  @override
  Widget build(BuildContext context) {
    final steps = _parseSteps(rawResult);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Practice'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 显示上传图片
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(imagePath),
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),

          if (practiceGoal != null && practiceGoal!.trim().isNotEmpty) ...[
            Text(
              practiceTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              practiceGoal!,
              style: const TextStyle(height: 1.4),
            ),
            const SizedBox(height: 16),
          ],
          const Text(
            'AI-Generated Steps',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),

          if (steps.isEmpty)
            const Text('No steps returned from AI.')
          else
            ...steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;

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
                      'Step ${index + 1}${step.title != null ? ': ${step.title}' : ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step.body,
                      style: const TextStyle(height: 1.4),
                    ),
                    if (step.tip != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '💡 ${step.tip}',
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
  List<_GeneratedStep> _parseSteps(String raw) {
    final normalized = raw.replaceAll('\r\n', '\n').trim();
    if (normalized.isEmpty) return const [];

    List<String> segments = normalized
        .split(RegExp(r'\n{2,}'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (segments.length <= 1) {
      final numbered = _splitNumbered(normalized);
      if (numbered.length > 1) {
        segments = numbered;
      }
    }

    final steps = <_GeneratedStep>[];

    for (final segment in segments) {
      final lines = segment
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      if (lines.isEmpty) {
        continue;
      }

      String? title;
      final firstLine = lines.first;
      final stripped = _stripNumbering(firstLine);
      if (stripped != firstLine) {
        title = stripped;
        lines[0] = stripped;
      }

      final tipIndex = lines.indexWhere(
            (line) => RegExp(
          r'^(Tip|Tips|Caregiver Tip|Therapist Tip)[:：]',
          caseSensitive: false,
        ).hasMatch(line),
      );

      String? tip;
      if (tipIndex != -1) {
        final tipLine = lines.removeAt(tipIndex);
        final parts = tipLine.split(RegExp(r'[:：]'));
        if (parts.length > 1) {
          tip = parts.sublist(1).join(':').trim();
        }
      }

      final bodyLines = List<String>.from(lines);
      if (title != null && bodyLines.isNotEmpty && bodyLines.first == title) {
        bodyLines.removeAt(0);
      }

      final bodyText = bodyLines.join('\n').trim();
      final body = bodyText.isEmpty ? lines.join('\n').trim() : bodyText;

      steps.add(
        _GeneratedStep(
          title: title,
          body: body,
          tip: tip,
        ),
      );
    }

    if (steps.isEmpty && normalized.isNotEmpty) {
      steps.add(
        _GeneratedStep(
          title: practiceTitle,
          body: normalized,
          tip: null,
        ),
      );
    }

    return steps;
  }

  List<String> _splitNumbered(String text) {
    final regex = RegExp(
      r'^\s*(?:Step\s*\d+|\d+[\.)\-:])',
      multiLine: true,
      caseSensitive: false,
    );
    final matches = regex.allMatches(text).toList();
    if (matches.length <= 1) return [text];

    final pieces = <String>[];
    for (var i = 0; i < matches.length; i++) {
      final start = matches[i].start;
      final end = i + 1 < matches.length ? matches[i + 1].start : text.length;
      final chunk = text.substring(start, end).trim();
      if (chunk.isNotEmpty) {
        pieces.add(chunk);
      }
    }

    final leading = text.substring(0, matches.first.start).trim();
    if (leading.isNotEmpty) {
      pieces.insert(0, leading);
    }

    return pieces;
  }

  String _stripNumbering(String line) {
    final stepMatch = RegExp(
      r'^(?:Step\s*(\d+)[\.:)\-]*\s*)(.*)',
      caseSensitive: false,
    ).firstMatch(line);
    if (stepMatch != null) {
      return stepMatch.group(2)?.trim() ?? '';
    }

    final numberedMatch = RegExp(r'^(\d+)[\.)\-:]\s*(.*)').firstMatch(line);
    if (numberedMatch != null) {
      return numberedMatch.group(2)?.trim() ?? '';
    }

    return line.trim();
  }
}

class _GeneratedStep {
  const _GeneratedStep({
    required this.body,
    this.title,
    this.tip,
  });

  final String body;
  final String? title;
  final String? tip;
}
