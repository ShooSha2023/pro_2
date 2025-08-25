import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/return_code.dart';
import 'package:flutter/material.dart';
import 'package:pro_2/localization/app_localizations.dart';
import 'package:pro_2/video_player.dart';
import 'package:pro_2/widgets/ActionButton.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:ffmpeg_kit_flutter_new_min_gpl/ffmpeg_kit.dart';
import 'package:pro_2/widgets/top_notification.dart';
import 'package:pro_2/providers/locale_provider.dart';

class TranscriptionPage extends StatefulWidget {
  final File? audioFromVideo;
  const TranscriptionPage({Key? key, this.audioFromVideo}) : super(key: key);

  @override
  State<TranscriptionPage> createState() => _TranscriptionPageState();
}

class _TranscriptionPageState extends State<TranscriptionPage> {
  File? _audioFile;
  String _transcribedText = '';
  bool _isProcessing = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _audioDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.audioFromVideo != null) {
      _audioFile = widget.audioFromVideo;
      _transcribedText = '✅ Audio from video is ready!';
    }

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _audioDuration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      setState(() {
        _audioFile = file;
        _transcribedText = '';
        _isProcessing = true;
      });

      Future.delayed(const Duration(seconds: 1), () {
        final lang = Provider.of<LocaleProvider>(
          context,
          listen: false,
        ).locale.languageCode;
        setState(() {
          _isProcessing = false;
          _transcribedText =
              '✅ ${AppLocalizations.getText('transcription_done', lang)}';
        });
      });
    }
  }

  Future<void> _pickVideoFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      final videoFile = File(result.files.single.path!);

      // تشغيل الفيديو مباشرة بدون خيارات
      final audioFile = await Navigator.push<File?>(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(videoFile: videoFile),
        ),
      );

      if (audioFile != null) {
        setState(() {
          _audioFile = audioFile;
          final lang = Provider.of<LocaleProvider>(
            context,
            listen: false,
          ).locale.languageCode;
          _transcribedText =
              '✅ ${AppLocalizations.getText('transcription_done', lang)}';
        });
      }
    }
  }

  void _showAudioBottomSheet(File file) async {
    await _audioPlayer.setSource(DeviceFileSource(file.path));
    final duration = await _audioPlayer.getDuration();
    if (duration != null) _audioDuration = duration;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isPlaying = _audioPlayer.state == PlayerState.playing;

            String _formatDuration(Duration duration) {
              String twoDigits(int n) => n.toString().padLeft(2, '0');
              final minutes = twoDigits(duration.inMinutes.remainder(60));
              final seconds = twoDigits(duration.inSeconds.remainder(60));
              return '$minutes:$seconds';
            }

            _audioPlayer.onPositionChanged.listen((position) {
              setState(() {
                _currentPosition = position;
              });
            });

            _audioPlayer.onPlayerComplete.listen((event) {
              setState(() {
                _currentPosition = Duration.zero;
              });
            });

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    path.basename(file.path),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_currentPosition)),
                      Text(_formatDuration(_audioDuration)),
                    ],
                  ),
                  Slider(
                    value: _currentPosition.inMilliseconds.toDouble().clamp(
                      0,
                      _audioDuration.inMilliseconds.toDouble(),
                    ),
                    min: 0,
                    max: _audioDuration.inMilliseconds.toDouble(),
                    onChanged: (value) async {
                      final newPos = Duration(milliseconds: value.toInt());
                      await _audioPlayer.seek(newPos);
                      setState(() {
                        _currentPosition = newPos;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause_circle : Icons.play_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    iconSize: 60,
                    onPressed: () async {
                      if (isPlaying) {
                        await _audioPlayer.pause();
                      } else {
                        await _audioPlayer.resume();
                      }
                      setState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _saveTranscription() {
    final lang = Provider.of<LocaleProvider>(
      context,
      listen: false,
    ).locale.languageCode;
    if (_transcribedText.isEmpty || _isProcessing) {
      TopNotification.show(
        context,
        AppLocalizations.getText('no_text_to_save', lang),
      );
      return;
    }
    TopNotification.show(context, AppLocalizations.getText('save_done', lang));
  }

  void _editTranscription() {
    final lang = Provider.of<LocaleProvider>(
      context,
      listen: false,
    ).locale.languageCode;
    TopNotification.show(context, AppLocalizations.getText('edit_mode', lang));
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final lang = localeProvider.locale.languageCode;
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(AppLocalizations.getText('transcription', lang)),
          backgroundColor: theme.colorScheme.primary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ActionButton(
                      color: theme.colorScheme.primary,
                      icon: Icons.audiotrack,
                      label: AppLocalizations.getText('pick_audio_file', lang),
                      onPressed: _pickAudioFile,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ActionButton(
                      color: theme.colorScheme.tertiary,
                      icon: Icons.video_file,
                      label: AppLocalizations.getText('pick_video_file', lang),
                      onPressed: _pickVideoFile,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_audioFile != null)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '🎵 ${AppLocalizations.getText('file', lang)}: ${path.basename(_audioFile!.path)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.play_arrow,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () {
                        _showAudioBottomSheet(_audioFile!);
                      },
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(
                        Icons.text_snippet,
                        color: theme.colorScheme.secondary,
                      ),
                      onPressed: () async {
                        final lang = Provider.of<LocaleProvider>(
                          context,
                          listen: false,
                        ).locale.languageCode;

                        setState(() => _isProcessing = true);

                        // ضع هنا كود التحويل الفعلي
                        await Future.delayed(const Duration(seconds: 2));

                        setState(() {
                          _isProcessing = false;
                          _transcribedText =
                              '✅ ${AppLocalizations.getText('transcription_done', lang)}';
                        });
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  width: size.width,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _isProcessing
                        ? const Center(
                            key: ValueKey('loading'),
                            child: CircularProgressIndicator(),
                          )
                        : SingleChildScrollView(
                            key: const ValueKey('text'),
                            child: Text(
                              _transcribedText.isEmpty
                                  ? AppLocalizations.getText(
                                      'placeholder_text',
                                      lang,
                                    )
                                  : _transcribedText,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ActionButton(
                  color: theme.colorScheme.primary,
                  icon: Icons.save_alt,
                  label: AppLocalizations.getText('save', lang),
                  onPressed: _saveTranscription,
                ),
              ),
              const SizedBox(width: 80),
              Expanded(
                child: ActionButton(
                  color: theme.colorScheme.primary,
                  icon: Icons.edit,
                  label: AppLocalizations.getText('edit', lang),
                  onPressed: _editTranscription,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
