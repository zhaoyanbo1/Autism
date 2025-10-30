import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../app_colors.dart';

class GeneratedPracticePage extends StatefulWidget {
  const GeneratedPracticePage({
    super.key,
    required this.imagePath,
    required this.rawResult,
    required this.practiceTitle,
    this.practiceGoal,
    this.resultIllustration,
  });

  final String imagePath;
  final String rawResult;
  final String practiceTitle;
  final String? practiceGoal;
  final String? resultIllustration;

  @override
  State<GeneratedPracticePage> createState() => _GeneratedPracticePageState();
}

class _GeneratedPracticePageState extends State<GeneratedPracticePage> {
  late final PageController _pageCtrl;
  int _index = 0;

  late final List<_StepItem> _steps;
  String? _bonusTip;
  late final String? _illustrationUrl;
  late final Uint8List? _illustrationBytes;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();

    final parsed = _parseSteps(widget.rawResult);
    final steps = parsed.steps;
    final numberedSteps = steps.where((step) => step.number != null).toList();
    final displayedSteps =
        (numberedSteps.isNotEmpty ? numberedSteps : steps).take(5).toList();

    _steps = [
      for (var i = 0; i < displayedSteps.length; i++)
        _StepItem(
          title: _resolveTitle(displayedSteps[i], i),
          text: _markdownToPlainText(displayedSteps[i].body),
          tip: _normalizeTip(displayedSteps[i].tip),
        ),
    ];

    final bonus = parsed.bonusTip?.trim() ?? '';
    _bonusTip = bonus.isEmpty ? null : _markdownToPlainText(bonus);
    final trimmedIllustration = widget.resultIllustration?.trim();
    Uint8List? decodedBytes;
    String? remoteUrl;

    if (trimmedIllustration != null && trimmedIllustration.isNotEmpty) {
      decodedBytes = _decodeDataUrl(trimmedIllustration);
      if (decodedBytes == null && trimmedIllustration.startsWith('http')) {
        remoteUrl = trimmedIllustration;
      }
    }

    _illustrationBytes = decodedBytes;
    _illustrationUrl = remoteUrl;
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _go(int delta) {
    if (_steps.isEmpty) return;
    final next = (_index + delta).clamp(0, _steps.length - 1);
    if (next != _index) {
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  String _resolveTitle(_GeneratedStep step, int index) {
    final rawTitle = step.title?.trim() ?? '';
    if (rawTitle.isNotEmpty) {
      return rawTitle;
    }
    final fallbackNumber = step.number ?? index + 1;
    return 'Step $fallbackNumber';
  }

  String? _normalizeTip(String? tip) {
    if (tip == null) return null;
    final normalized = _markdownToPlainText(tip).trim();
    return normalized.isEmpty ? null : normalized;
  }

  String _markdownToPlainText(String markdown) {
    var text = markdown;

    text = text.replaceAll('\\r\\n', '\\n');
    text = text.replaceAllMapped(
      RegExp(r'\[(.*?)\]\((.*?)\)'),
      (match) => match.group(1) ?? '',
    );
    text = text.replaceAllMapped(
      RegExp(r'\*\*(.*?)\*\*'),
      (match) => match.group(1) ?? '',
    );
    text = text.replaceAllMapped(
      RegExp(r'__(.*?)__'),
      (match) => match.group(1) ?? '',
    );
    text = text.replaceAllMapped(
      RegExp(r'`([^`]*)`'),
      (match) => match.group(1) ?? '',
    );
    text = text.replaceAll(RegExp(r'^[-*•]\s*', multiLine: true), '• ');
    text = text.replaceAllMapped(
      RegExp(r'_([^_]*)_'),
      (match) => match.group(1) ?? '',
    );

    return text.trim();
  }

  @override
  Widget build(BuildContext context) {
    final hasSteps = _steps.isNotEmpty;
    final goalText = (widget.practiceGoal ?? '').trim();
    final resolvedGoal = goalText.isEmpty
        ? 'Use these generated steps to guide your practice session.'
        : goalText;

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.practiceTitle),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBlue.withOpacity(.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(.15)),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _iconBadge(Icons.auto_awesome),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.practiceTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        resolvedGoal,
                        style: TextStyle(
                          color: Colors.black.withOpacity(.80),
                          height: 1.3,
                        ),
                      ),
                      if (widget.imagePath.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(widget.imagePath),
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (hasSteps) ...[
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Game steps',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
                Text(
                  'Step ${_index + 1}/${_steps.length}',
                  style: TextStyle(color: Colors.black.withOpacity(.6)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _progressBar(_index, _steps.length, colorScheme.primary),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageCtrl,
                    itemCount: _steps.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) => _StepCard(
                      item: _steps[i],
                      index: i,
                      total: _steps.length,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _arrowButton(
                      Icons.chevron_left,
                      onTap: () => _go(-1),
                      enabled: _index > 0,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _arrowButton(
                      Icons.chevron_right,
                      onTap: () => _go(1),
                      enabled: _index < _steps.length - 1,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Text(
              'No steps returned from AI.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],

          if (_hasIllustration) ...[
            const SizedBox(height: 200),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.primary.withOpacity(.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _buildIllustration(),
              ),
            ),
          ],


          if (_bonusTip != null) ...[
            const SizedBox(height: 20),
            _bonusTipCard(_bonusTip!),
          ],
        ],
      ),
    );
  }
  bool get _hasIllustration {
    final hasBytes = _illustrationBytes != null && _illustrationBytes!.isNotEmpty;
    final hasUrl = _illustrationUrl != null && _illustrationUrl!.isNotEmpty;
    return hasBytes || hasUrl;
  }

  Widget _buildIllustration() {
    if (_illustrationBytes != null && _illustrationBytes!.isNotEmpty) {
      return Image.memory(
        _illustrationBytes!,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    if (_illustrationUrl != null && _illustrationUrl!.isNotEmpty) {
      return Image.network(
        _illustrationUrl!,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return const SizedBox.shrink();
  }

  Uint8List? _decodeDataUrl(String? dataUrl) {
    final value = dataUrl?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    final match = RegExp(
      r'^data:image\/[^;]+;base64,(.*)$',
      dotAll: true,
    ).firstMatch(value);
    final base64Data = match != null ? match.group(1) ?? '' : value;
    if (base64Data.isEmpty) {
      return null;
    }
    try {
      return base64.decode(base64Data);
    } catch (_) {
      return null;
    }
  }


  Widget _bonusTipCard(String tip) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(.18)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.emoji_objects_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bonus Tip',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tip,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBadge(IconData icon) {
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

  Widget _progressBar(int index, int total, Color color) {
    final ratio = (index + 1) / total;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          Container(height: 8, color: color.withOpacity(.12)),
          FractionallySizedBox(
            widthFactor: ratio,
            child: Container(height: 8, color: color),
          ),
        ],
      ),
    );
  }

  Widget _arrowButton(
    IconData icon, {
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: enabled ? Colors.white : Colors.white.withOpacity(.7),
        shape: const CircleBorder(),
        elevation: enabled ? 2 : 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              icon,
              size: 24,
              color: enabled ? AppColors.primary : Colors.black26,
            ),
          ),
        ),
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
        final end = i + 1 < matches.length ? matches[i + 1].start : normalized.length;
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

    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
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

        filteredLines.add(trimmedRight);
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
          title: widget.practiceTitle,
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

class _StepItem {
  const _StepItem({
    required this.title,
    required this.text,
    this.tip,
  });

  final String title;
  final String text;
  final String? tip;
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.item,
    required this.index,
    required this.total,
  });

  final _StepItem item;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Step ${index + 1}/$total',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.text,
            style: TextStyle(
              height: 1.45,
              color: Colors.black.withOpacity(.86),
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          if (item.tip != null) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(.18)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.tips_and_updates_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.tip!,
                      style: TextStyle(
                        color: AppColors.primary,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
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
