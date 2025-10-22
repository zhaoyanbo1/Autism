import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../app_colors.dart';
import '../../backend_config.dart';
import '../../backend_error.dart';
import '../../image_upload.dart';

enum DomainGenerationMode { simple, medium, hard }

class DomainAiUploadPage extends StatefulWidget {
  const DomainAiUploadPage({
    super.key,
    required this.category,
    required this.displayName,
  });

  final String category;
  final String displayName;

  @override
  State<DomainAiUploadPage> createState() => _DomainAiUploadPageState();
}

class _DomainAiUploadPageState extends State<DomainAiUploadPage> {
  DomainGenerationMode _mode = DomainGenerationMode.simple;
  XFile? _image;
  bool _sending = false;

  static const String _basePrompt =
      'You are an experienced pediatric therapist. Based on the objects or situations in the photo, craft a playful practice routine with clear coaching tips for caregivers.';

  static const Map<String, String> _categoryPrompts = {
    'Leisure':
    'Emphasize leisure play ideas, imagination building, and turn-taking games that use the materials in the photo.',
    'Listen':
    'Focus on receptive-language growth. Include listening games and step-following activities that match the photo context.',
    'Speak':
    'Target expressive-language practice. Encourage labeling, requesting, and short-sentence practice inspired by the photo.',
    'Emotion':
    'Highlight emotional awareness. Suggest ways to name, explore, and regulate feelings using what you see in the photo.',
    'Social':
    'Create social interaction activities that promote sharing, cooperation, and joint attention moments.',
    'Learn':
    'Design cognitive learning prompts such as sorting, matching, sequencing, or early academics tied to the pictured objects.',
    'Behavior':
    'Suggest positive behavior supports, routines, or reinforcement strategies relevant to the photo.',
    'GrossMotor':
    'Build gross-motor play that encourages movement, balance, and whole-body coordination with the pictured setting.',
    'FineMotor':
    'Focus on fine-motor and hand-strength tasks that use small-object manipulation inspired by the photo.',
  };

  static const Map<DomainGenerationMode, String> _modePrompts = {
    DomainGenerationMode.simple:
    'Keep the routine short with 3 concise steps. Provide very clear caregiver cues and simple language.',
    DomainGenerationMode.medium:
    'Provide 4-5 steps with moderate scaffolding. Include ideas for prompting the child and optional extensions.',
    DomainGenerationMode.hard:
    'Offer 5-6 detailed steps that challenge the child. Include opportunities for independence and generalization.',
  };

  String get _promptPreview {
    final pieces = <String>[_basePrompt];
    final categoryPrompt = _categoryPrompts[widget.category];
    if (categoryPrompt != null && categoryPrompt.isNotEmpty) {
      pieces.add(categoryPrompt);
    }
    final modePrompt = _modePrompts[_mode];
    if (modePrompt != null && modePrompt.isNotEmpty) {
      pieces.add(modePrompt);
    }
    return pieces.join('\n\n');
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final result = await picker.pickImage(source: source, imageQuality: 85);
      if (!mounted) return;
      setState(() => _image = result);
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  Future<void> _submit() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick an image first')),
      );
      return;
    }

    setState(() => _sending = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text(
                'Generating practice…',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final uri = Uri.parse(backendEndpoint);
      final request = http.MultipartRequest('POST', uri)
        ..fields['category'] = widget.category
        ..fields['difficulty'] = _mode.name
        ..fields['prompt'] = _promptPreview
        ..fields['instruction'] = _promptPreview
        ..files.add(await createImageMultipart('image', _image!));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (!mounted) return;

      if (response.statusCode != 200) {
        throw HttpException(describeBackendError(response));
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final text = (data['result'] as String?)?.trim();
      if (text == null || text.isEmpty) {
        throw const FormatException('Missing result from backend');
      }

      Navigator.of(context)
        ..pop()
        ..push(
          MaterialPageRoute(
            builder: (_) => DomainGeneratedPracticePage(
              displayName: widget.displayName,
              mode: _mode,
              resultText: text,
              imagePath: _image!.path,
            ),
          ),
        );
    } catch (err) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate practice: $err')),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.displayName} AI Practice'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
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
                child: Icon(Icons.smart_toy_outlined, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generate ${widget.displayName} routine',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Upload a related photo and choose a difficulty. The AI will craft a caregiver-friendly routine tailored to this skill area.',
                      style: TextStyle(fontSize: 14, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.photo_outlined, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Prompt preview updates with your difficulty choice',
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
                _ModeSelector(
                  value: _mode,
                  onChanged: (mode) => setState(() => _mode = mode),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withOpacity(.15)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prompt preview',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _promptPreview,
                        style: const TextStyle(height: 1.35, fontSize: 13.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
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
                                onPressed: _sending ? null : () => _pickImage(ImageSource.camera),
                                icon: const Icon(Icons.photo_camera_outlined),
                                label: const Text('Camera'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  side: BorderSide(color: AppColors.primary.withOpacity(.35)),
                                  foregroundColor: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _sending ? null : () => _pickImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library_outlined),
                                label: const Text('Gallery'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  side: BorderSide(color: AppColors.primary.withOpacity(.35)),
                                  foregroundColor: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_image!.path),
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _sending ? null : () => _pickImage(ImageSource.camera),
                                icon: const Icon(Icons.refresh_outlined),
                                label: const Text('Retake'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  side: BorderSide(color: AppColors.primary.withOpacity(.35)),
                                  foregroundColor: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _sending
                                    ? null
                                    : () {
                                  setState(() => _image = null);
                                },
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Remove'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  side: BorderSide(color: AppColors.primary.withOpacity(.35)),
                                  foregroundColor: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _sending ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Generate with AI'),
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

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.value, required this.onChanged});

  final DomainGenerationMode value;
  final ValueChanged<DomainGenerationMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          _ModeChip(
            label: 'Simple',
            selected: value == DomainGenerationMode.simple,
            onTap: () => onChanged(DomainGenerationMode.simple),
            position: _ChipPosition.left,
          ),
          const SizedBox(width: 6),
          _ModeChip(
            label: 'Medium',
            selected: value == DomainGenerationMode.medium,
            onTap: () => onChanged(DomainGenerationMode.medium),
            position: _ChipPosition.middle,
          ),
          const SizedBox(width: 6),
          _ModeChip(
            label: 'Hard',
            selected: value == DomainGenerationMode.hard,
            onTap: () => onChanged(DomainGenerationMode.hard),
            position: _ChipPosition.right,
          ),
        ],
      ),
    );
  }
}

enum _ChipPosition { left, middle, right }

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.position,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final _ChipPosition position;

  BorderRadius get _radius {
    switch (position) {
      case _ChipPosition.left:
        return const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        );
      case _ChipPosition.right:
        return const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        );
      case _ChipPosition.middle:
        return BorderRadius.circular(12);
    }
  }

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
              color:
              selected ? AppColors.primary : AppColors.primary.withOpacity(.25),
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
}

class DomainGeneratedPracticePage extends StatelessWidget {
  const DomainGeneratedPracticePage({
    super.key,
    required this.displayName,
    required this.mode,
    required this.resultText,
    required this.imagePath,
  });

  final String displayName;
  final DomainGenerationMode mode;
  final String resultText;
  final String imagePath;

  String get _modeLabel {
    switch (mode) {
      case DomainGenerationMode.simple:
        return 'Simple';
      case DomainGenerationMode.medium:
        return 'Medium';
      case DomainGenerationMode.hard:
        return 'Hard';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$displayName Practice'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(imagePath),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBlue.withOpacity(.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(.15)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _modeLabel,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${displayName.toUpperCase()} routine',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  resultText,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}