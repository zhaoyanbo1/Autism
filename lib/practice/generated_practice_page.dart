import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
    final parsed = _parseSteps(rawResult);
    final steps = parsed.steps;
    final bonusTip = parsed.bonusTip;
    final numberedSteps = steps.where((step) => step.number != null).toList();
    final displayedSteps = (numberedSteps.isNotEmpty ? numberedSteps : steps)
        .take(5)
        .toList();
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

          if (displayedSteps.isEmpty)
            const Text('No steps returned from AI.')
          else
            ...displayedSteps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final stepNumber = step.number ?? (index + 1);

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
                      'Step $stepNumber',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    MarkdownBody(
                      data: step.body,
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                          .copyWith(p: const TextStyle(height: 1.4)),
                    ),
                    if (step.tip != null) ...[
                      const SizedBox(height: 8),
                      MarkdownBody(
                        data: '💡 ${step.tip}',
                        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                            .copyWith(
                          p: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          if (bonusTip != null) ...[
            const SizedBox(height: 4),
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBlue.withOpacity(.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bonus Tip',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  MarkdownBody(
                    data: bonusTip!,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                        .copyWith(p: const TextStyle(height: 1.4)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  ({List<_GeneratedStep> steps, String? bonusTip}) _parseSteps(String raw) {
    final normalized = raw.replaceAll('\r\n', '\n').trim();
    if (normalized.isEmpty) {
      return (steps: const [], bonusTip: null);
    }

    final extraction = _extractBonusSection(normalized);
    final steps = _parseStepSegments(extraction.sanitized);
    return (steps: steps, bonusTip: extraction.bonusTip);
  }

  List<_GeneratedStep> _parseStepSegments(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) return const [];

    final stepHeadingPattern = RegExp(
      r'(^|\n)\s*(#{1,6}\s*)?Step\s*(\d+)[\.:)\-]?\s*(.*)',
      caseSensitive: false,
    );
    final matches = stepHeadingPattern.allMatches(normalized).toList();

    if (matches.isNotEmpty) {
      final steps = <_GeneratedStep>[];
      for (var i = 0; i < matches.length; i++) {
        final match = matches[i];
        final start = match.start;
        final end =
        i + 1 < matches.length ? matches[i + 1].start : normalized.length;
        final chunk = normalized.substring(start, end).trim();
        if (chunk.isEmpty) continue;

        final rawLines = chunk.split('\n');
        if (rawLines.isEmpty) continue;

        var headingLine = rawLines.first.trim();
        headingLine =
            headingLine.replaceFirst(RegExp(r'^#{1,6}\s*'), '').trim();

        final lines = rawLines.sublist(1);
        final contentLines = <String>[];
        String? tip;

        for (var line in lines) {
          final trimmedRight = line.trimRight();
          final trimmed = trimmedRight.trim();

          if (trimmed.isEmpty) {
            if (contentLines.isNotEmpty &&
                contentLines.last.trim().isNotEmpty) {
              contentLines.add('');
            }
            continue;
          }

          final withoutBullet =
          trimmed.replaceFirst(RegExp(r'^[-*•]\s*'), '');
          final tipMatch = RegExp(
            r'^(?:\*\*)?(Tip|Tips|Caregiver Tip|Therapist Tip)(?:\*\*)?[:：]\s*(.*)',
            caseSensitive: false,
          ).firstMatch(withoutBullet);

          if (tipMatch != null) {
            final tipText = tipMatch.group(2)?.trim();
            if (tipText != null && tipText.isNotEmpty) {
              tip = tipText;
            }
            continue;
          }

          if (RegExp(r'^(?:\*\*)?Bonus Tip', caseSensitive: false)
              .hasMatch(withoutBullet)) {
            continue;
          }

          contentLines.add(trimmedRight);
        }

        while (contentLines.isNotEmpty && contentLines.first.trim().isEmpty) {
          contentLines.removeAt(0);
        }
        while (contentLines.isNotEmpty && contentLines.last.trim().isEmpty) {
          contentLines.removeLast();
        }

        final body = contentLines.join('\n').trim();
        final title = _stripNumbering(headingLine);
        final stepNumber = int.tryParse(match.group(3) ?? '');

        steps.add(
          _GeneratedStep(
            number: stepNumber,
            title: title.isEmpty ? null : title,
            body: body,
            tip: tip,
          ),
        );
      }

      if (steps.isNotEmpty) {
        return steps;
      }
    }

    return _parseFallbackSteps(normalized);
  }

  ({String sanitized, String? bonusTip}) _extractBonusSection(String text) {
    final bonusPattern = RegExp(
      r'(?:^|\n)\s*(?:[-*•]\s*)?(?:#{1,6}\s*|\*\*)?Bonus Tip(?:\*\*)?[:：]?\s*(.*)',
      caseSensitive: false,
    );
    final match = bonusPattern.firstMatch(text);
    if (match == null) {
      return (sanitized: text, bonusTip: null);
    }

    final start = match.start;
    final inline = match.group(1)?.trim() ?? '';
    final collected = <String>[];
    if (inline.isNotEmpty) {
      collected.add(inline);
    }

    final remainder = text.substring(match.end);
    int consumedLength = 0;
    final linePattern = RegExp(r'.*(?:\n|$)');
    for (final lineMatch in linePattern.allMatches(remainder)) {
      final line = lineMatch.group(0)!;
      final trimmedLine = line.trimRight();
      final trimmed = trimmedLine.trim();
      if (trimmed.isEmpty) {
        if (collected.isEmpty) {
          consumedLength += line.length;
          continue;
        }
        consumedLength += line.length;
        break;
      }
      if (RegExp(r'^(#{1,6}\s*|Step\s*\d+)', caseSensitive: false)
          .hasMatch(trimmed)) {
        break;
      }
      collected.add(trimmedLine);
      consumedLength += line.length;
    }

    final end = match.end + consumedLength;
    final before = text.substring(0, start);
    final after = text.substring(end);
    final beforePart = before.trimRight();
    final afterPart = after.trimLeft();
    String sanitized;
    if (beforePart.isEmpty) {
      sanitized = afterPart;
    } else if (afterPart.isEmpty) {
      sanitized = beforePart;
    } else {
      sanitized = '$beforePart\n\n$afterPart';
    }

    final bonusTip = collected.join('\n').trim();
    return (sanitized: sanitized.trim(), bonusTip: bonusTip.isEmpty ? null : bonusTip);
  }

  List<_GeneratedStep> _parseFallbackSteps(String text) {
    List<String> segments = text
        .split(RegExp(r'\n{2,}'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (segments.length <= 1) {
      final numbered = _splitNumbered(text);
      if (numbered.length > 1) {
        segments = numbered;
      }
    }

    final steps = <_GeneratedStep>[];

    for (final segment in segments) {
      final rawLines = segment
          .split('\n')
          .map((line) => line.trimRight())
          .toList();

      while (rawLines.isNotEmpty && rawLines.first.trim().isEmpty) {
        rawLines.removeAt(0);
      }
      while (rawLines.isNotEmpty && rawLines.last.trim().isEmpty) {
        rawLines.removeLast();
      }

      if (rawLines.isEmpty) {
        continue;
      }

      final headingLine = rawLines.first.trim();
      final contentLines = List<String>.from(rawLines.sublist(1));

      final strippedHeading = _stripNumbering(headingLine);
      final stepNumber = _extractStepNumber(headingLine);
      String? title;
      if (strippedHeading != headingLine) {
        title = strippedHeading;
      }

      String? tip;
      final filteredLines = <String>[];
      for (final line in contentLines) {
        final trimmedRight = line.trimRight();
        final trimmed = trimmedRight.trim();

        if (trimmed.isEmpty) {
          if (filteredLines.isNotEmpty &&
              filteredLines.last.trim().isNotEmpty) {
            filteredLines.add('');
          }
          continue;
        }

        final withoutBullet =
        trimmed.replaceFirst(RegExp(r'^[-*•]\s*'), '');
        final tipMatch = RegExp(
          r'^(?:\*\*)?(Tip|Tips|Caregiver Tip|Therapist Tip)(?:\*\*)?[:：]\s*(.*)',
          caseSensitive: false,
        ).firstMatch(withoutBullet);

        if (tipMatch != null) {
          final tipText = tipMatch.group(2)?.trim();
          if (tipText != null && tipText.isNotEmpty) {
            tip = tipText;
          }
          continue;
        }
      }

      while (filteredLines.isNotEmpty && filteredLines.first.trim().isEmpty) {
        filteredLines.removeAt(0);
      }
      while (filteredLines.isNotEmpty && filteredLines.last.trim().isEmpty) {
        filteredLines.removeLast();
      }

      final body = filteredLines.join('\n').trim();

      steps.add(
        _GeneratedStep(
          number: stepNumber,
          title: (title ?? strippedHeading).isEmpty
              ? null
              : (title ?? strippedHeading),
          body: body.isEmpty ? segment.trim() : body,
          tip: tip,
        ),
      );
    }

    if (steps.isEmpty && text.trim().isNotEmpty) {
      steps.add(
        _GeneratedStep(
          number: null,
          title: practiceTitle,
          body: text.trim(),
          tip: null,
        ),
      );
    }

    return steps;
  }

  int? _extractStepNumber(String line) {
    final normalized = line.trim();
    final stepMatch =
    RegExp(r'Step\s*(\d+)', caseSensitive: false).firstMatch(normalized);
    if (stepMatch != null) {
      return int.tryParse(stepMatch.group(1) ?? '');
    }

    final numberedMatch =
    RegExp(r'^(?:\*\*)?(\d+)[\.)\-]', caseSensitive: false)
        .firstMatch(normalized);
    if (numberedMatch != null) {
      return int.tryParse(numberedMatch.group(1) ?? '');
    }

    return null;
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
    this.number,
  });

  final String body;
  final String? title;
  final String? tip;
  final int? number;
}
