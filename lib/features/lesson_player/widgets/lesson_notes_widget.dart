import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../providers/app_providers.dart';

class LessonNotesWidget extends ConsumerStatefulWidget {
  final String lessonId;

  const LessonNotesWidget({
    super.key,
    required this.lessonId,
  });

  @override
  ConsumerState<LessonNotesWidget> createState() => _LessonNotesWidgetState();
}

class _LessonNotesWidgetState extends ConsumerState<LessonNotesWidget> {
  late TextEditingController _notesController;
  bool _isSaved = false;
  String _lastLoadedLessonId = '';

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadNotesIfNeeded();
  }

  @override
  void didUpdateWidget(LessonNotesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lessonId != widget.lessonId) {
      _loadNotesIfNeeded(force: true);
    }
  }

  void _loadNotesIfNeeded({bool force = false}) {
    if (_lastLoadedLessonId != widget.lessonId || force) {
      _lastLoadedLessonId = widget.lessonId;
      final savedNote =
          ref.read(lessonNotesProvider.notifier).getNote(widget.lessonId);
      _notesController.text = savedNote;
      _isSaved = false;
    }
  }

  Future<void> _saveNote() async {
    final noteText = _notesController.text;
    await ref
        .read(lessonNotesProvider.notifier)
        .saveNote(widget.lessonId, noteText);
    if (mounted) {
      setState(() {
        _isSaved = true;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context).noteSaved),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _clearNote() async {
    _notesController.clear();
    await ref.read(lessonNotesProvider.notifier).saveNote(widget.lessonId, '');
    if (mounted) {
      setState(() {
        _isSaved = false;
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withAlpha(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  loc.lessonNotes,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_isSaved)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_rounded,
                          color: AppColors.success, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Saved',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 4,
            minLines: 2,
            onChanged: (_) {
              if (_isSaved) {
                setState(() {
                  _isSaved = false;
                });
              }
            },
            decoration: InputDecoration(
              hintText: loc.writeNotesPlaceholder,
              hintStyle: TextStyle(
                fontSize: 13,
                color: theme.hintColor.withAlpha(150),
              ),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor.withAlpha(180),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_notesController.text.isNotEmpty)
                TextButton.icon(
                  onPressed: _clearNote,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: Text(loc.clearNote),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _saveNote,
                icon: const Icon(Icons.save_rounded, size: 18),
                label: Text(loc.saveNote),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
