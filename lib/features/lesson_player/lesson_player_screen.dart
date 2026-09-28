import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/lesson.dart';
import '../../providers/app_providers.dart';
import 'widgets/lesson_notes_widget.dart';
import 'widgets/video_controls.dart';

class LessonPlayerScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String lessonId;

  const LessonPlayerScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  @override
  ConsumerState<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  String? _initializedLessonId;
  bool _isInitializing = false;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isFullscreen = false;
  double _playbackSpeed = 1.0;
  bool _showControls = true;

  Timer? _saveTimer;
  Timer? _controlsHideTimer;

  int _lastSavedSec = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(LessonPlayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lessonId != widget.lessonId ||
        oldWidget.courseId != widget.courseId) {
      _initializedLessonId = null;
    }
  }

  /// App lifecycle change: pause video when app goes to background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      if (_controller != null && _controller!.value.isPlaying) {
        _controller!.pause();
      }
    }
  }

  Future<void> _initializePlayerForLesson(Lesson lesson) async {
    if (_initializedLessonId == lesson.id || _isInitializing) return;
    _isInitializing = true;
    _initializedLessonId = lesson.id;

    _saveTimer?.cancel();
    _controlsHideTimer?.cancel();
    _controller?.removeListener(_onVideoControllerUpdate);
    await _controller?.dispose();
    _controller = null;

    if (mounted) {
      setState(() {
        _isInitialized = false;
        _hasError = false;
        _errorMessage = '';
      });
    }

    try {
      final controller = VideoPlayerController.asset(lesson.video);
      await controller.initialize();

      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitialized = true;
          _isInitializing = false;
        });
      }

      controller.addListener(_onVideoControllerUpdate);

      // Restore position from per-lesson progress
      final progressMap = ref.read(progressMapProvider);
      final savedProgress = progressMap[lesson.id];
      if (savedProgress != null && savedProgress.lastPositionSec > 0) {
        final seekPos = Duration(seconds: savedProgress.lastPositionSec);
        if (seekPos < controller.value.duration) {
          await controller.seekTo(seekPos);
        }
      }

      // Restore playback speed: prefer per-lesson saved speed,
      // otherwise fall back to the globally remembered last speed.
      final savedSpeed = savedProgress?.playbackSpeed;
      final globalSpeed = ref.read(defaultPlaybackSpeedProvider);
      final resolvedSpeed =
          (savedSpeed != null && savedSpeed != 1.0) ? savedSpeed : globalSpeed;

      if (resolvedSpeed != 1.0) {
        _playbackSpeed = resolvedSpeed;
        await controller.setPlaybackSpeed(_playbackSpeed);
      } else {
        _playbackSpeed = 1.0;
      }

      await controller.play();

      _saveTimer?.cancel();
      _saveTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        _saveProgressCurrentPosition();
      });

      _startControlsHideTimer();
    } catch (e, stack) {
      debugPrint('Error initializing video asset ${lesson.video}: $e\n$stack');
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = true;
          _errorMessage = e.toString().contains('Exception:')
              ? e.toString().replaceAll('Exception: ', '')
              : '';
        });
      }
    }
  }

  /// Only triggers a UI rebuild for playback-state changes (play/pause/buffer).
  /// Progress saving is handled exclusively by the periodic _saveTimer to avoid
  /// redundant writes on every video frame (can be 30-60 calls/sec).
  void _onVideoControllerUpdate() {
    if (!mounted || _controller == null) return;
    final value = _controller!.value;

    if (value.hasError) {
      setState(() {
        _hasError = true;
        _errorMessage = '';
      });
      return;
    }

    // Only rebuild UI — saving is handled by the periodic timer
    setState(() {});
  }

  void _saveProgressCurrentPosition({bool force = false}) {
    if (_controller == null || !_isInitialized) return;

    final posSec = _controller!.value.position.inSeconds;
    final durSec = _controller!.value.duration.inSeconds;

    if (durSec <= 0) return;

    if (!force && posSec == _lastSavedSec) return;
    _lastSavedSec = posSec;

    ref.read(progressMapProvider.notifier).saveProgress(
          lessonId: widget.lessonId,
          currentPositionSec: posSec,
          durationSec: durSec,
          playbackSpeed: _playbackSpeed,
        );
  }

  void _startControlsHideTimer() {
    _controlsHideTimer?.cancel();
    _controlsHideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _controller?.value.isPlaying == true) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  Future<void> _setPlaybackSpeed(double speed) async {
    setState(() {
      _playbackSpeed = speed;
    });
    if (_controller != null) {
      await _controller!.setPlaybackSpeed(speed);
    }
    // Persist the chosen speed globally so it's remembered across lessons
    await ref.read(defaultPlaybackSpeedProvider.notifier).setSpeed(speed);
    _saveProgressCurrentPosition(force: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Pause video before disposing so it stops cleanly when leaving the screen
    _controller?.pause();
    _saveProgressCurrentPosition(force: true);
    _saveTimer?.cancel();
    _controlsHideTimer?.cancel();
    _controller?.removeListener(_onVideoControllerUpdate);
    _controller?.dispose();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // ── Private builder methods ──────────────────────────────────────────────

  /// Builds the main body based on current player state (error / loading / player).
  Widget _buildBody(AppLocalizations loc) {
    if (_hasError) {
      return Container(
        color: AppColors.primaryDark,
        child: ErrorView(
          message: _errorMessage.isEmpty ? loc.errorLoadingVideo : _errorMessage,
          onRetry: () {
            setState(() {
              _initializedLessonId = null;
              _hasError = false;
            });
          },
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return LoadingView(
        message: loc.loadingVideo,
        textColor: Colors.white,
      );
    }

    return _buildPlayerContent(loc);
  }

  /// Builds the video player + controls + notes section once initialized.
  Widget _buildPlayerContent(AppLocalizations loc) {
    final isBuffering = _controller!.value.isBuffering;
    final progressMap = ref.watch(progressMapProvider);
    final progressService = ref.watch(progressServiceProvider);
    final coursesAsync = ref.watch(coursesProvider);

    return coursesAsync.maybeWhen(
      data: (courses) {
        // Safe lookup — show error if course/lesson not found
        final courseIndex = courses.indexWhere((c) => c.id == widget.courseId);
        if (courseIndex == -1) {
          return ErrorView(message: loc.courseNotFound);
        }
        final course = courses[courseIndex];

        final lessonIndex =
            course.allLessons.indexWhere((l) => l.id == widget.lessonId);
        if (lessonIndex == -1) {
          return ErrorView(message: loc.lessonNotFound);
        }
        final lesson = course.allLessons[lessonIndex];

        final langCode = ref.watch(localeProvider).languageCode;
        final nextLesson = progressService.getNextUnlockedLesson(
          currentLesson: lesson,
          course: course,
          progressMap: progressMap,
        );

        final isCurrentCompleted =
            progressMap[lesson.id]?.isCompleted ?? false;
        final isFinalLesson = course.allLessons.last.id == lesson.id;
        final nextLessonTitle = nextLesson?.getTitle(langCode) ?? '';

        return Column(
          children: [
            // ── Video Player Container ──────────────────────────────
            SizedBox(
              height: _isFullscreen
                  ? MediaQuery.of(context).size.height
                  : (MediaQuery.of(context).size.width * 9 / 16)
                      .clamp(200.0, 320.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showControls = !_showControls;
                  });
                  if (_showControls) {
                    _startControlsHideTimer();
                  }
                },
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: _controller!.value.isInitialized
                            ? AspectRatio(
                                aspectRatio:
                                    _controller!.value.aspectRatio > 0
                                        ? _controller!.value.aspectRatio
                                        : 16 / 9,
                                child: VideoPlayer(_controller!),
                              )
                            : LoadingView(
                                message: loc.loadingVideo,
                                textColor: Colors.white,
                              ),
                      ),
                      // Buffering Overlay
                      if (isBuffering)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black54,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    loc.loadingVideo,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      // Video Controls Overlay
                      if (_showControls)
                        Positioned.fill(
                          child: VideoControls(
                            controller: _controller!,
                            isFullscreen: _isFullscreen,
                            onToggleFullscreen: _toggleFullscreen,
                            currentSpeed: _playbackSpeed,
                            onSpeedChanged: _setPlaybackSpeed,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Scrollable Bottom Section (footer + notes) ─────────
            if (!_isFullscreen)
              Expanded(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Next Lesson / Completion Banner
                        Container(
                          color: Theme.of(context).cardTheme.color,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isFinalLesson && isCurrentCompleted) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withAlpha(25),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppColors.success),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.workspace_premium_rounded,
                                        color: AppColors.success,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          loc.completedCourse,
                                          style: const TextStyle(
                                            color: AppColors.success,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else if (nextLesson != null) ...[
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _saveProgressCurrentPosition(
                                          force: true);
                                      context.go(
                                        '/course/${widget.courseId}/lesson/${nextLesson.id}',
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                    ),
                                    icon: const Icon(
                                        Icons.skip_next_rounded),
                                    label: Text(
                                      '${loc.nextLesson}: $nextLessonTitle',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Per-Lesson Notes Widget
                        LessonNotesWidget(lessonId: widget.lessonId),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      orElse: () => LoadingView(
        message: loc.loadingVideo,
        textColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final langCode = ref.watch(localeProvider).languageCode;
    final coursesAsync = ref.watch(coursesProvider);

    // Resolve lesson from courses — trigger player init once ready
    coursesAsync.whenData((courses) {
      final courseIndex = courses.indexWhere((c) => c.id == widget.courseId);
      if (courseIndex == -1) return;
      final course = courses[courseIndex];

      final lessonIndex =
          course.allLessons.indexWhere((l) => l.id == widget.lessonId);
      if (lessonIndex == -1) return;
      final lesson = course.allLessons[lessonIndex];

      if (_initializedLessonId != lesson.id && !_isInitializing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializePlayerForLesson(lesson);
        });
      }
    });

    // Derive lesson title for AppBar (safe, with fallback)
    final lessonTitle = coursesAsync.maybeWhen(
      data: (courses) {
        final courseIndex = courses.indexWhere((c) => c.id == widget.courseId);
        if (courseIndex == -1) return loc.appTitle;
        final course = courses[courseIndex];
        final lessonIndex =
            course.allLessons.indexWhere((l) => l.id == widget.lessonId);
        if (lessonIndex == -1) return loc.appTitle;
        return course.allLessons[lessonIndex].getTitle(langCode);
      },
      orElse: () => loc.appTitle,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullscreen
          ? null
          : AppBar(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              title: Text(
                lessonTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () {
                  _saveProgressCurrentPosition(force: true);
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/course/${widget.courseId}');
                  }
                },
              ),
            ),
      body: _buildBody(loc),
    );
  }
}
