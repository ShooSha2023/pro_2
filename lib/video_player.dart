import 'dart:io';
import 'package:ffmpeg_kit_flutter_new_min_gpl/return_code.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/ffmpeg_kit.dart';
import 'package:pro_2/widgets/top_notification.dart';
import 'package:provider/provider.dart';
import 'package:pro_2/providers/locale_provider.dart';
import 'package:pro_2/localization/app_localizations.dart';

class VideoPlayerScreen extends StatefulWidget {
  final File videoFile;

  const VideoPlayerScreen({super.key, required this.videoFile});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isConverting = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _convertToAudio() async {
    setState(() {
      _isConverting = true;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final outputPath =
          "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.wav";
      final outputFile = File(outputPath);

      final command =
          '-i "${widget.videoFile.path}" -vn -acodec pcm_s16le -ar 44100 -ac 2 "$outputPath"';
      final session = await FFmpegKit.execute(command);

      final returnCode = await session.getReturnCode();
      if (returnCode != null && ReturnCode.isSuccess(returnCode)) {
        if (mounted) {
          final lang = Provider.of<LocaleProvider>(
            context,
            listen: false,
          ).locale.languageCode;
          TopNotification.show(
            context,
            AppLocalizations.getText('video_to_audio_done', lang),
          );

          // نرجع الملف للصفحة السابقة لتحديث الـ audio
          Navigator.pop(context, outputFile);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("فشل تحويل الفيديو")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("خطأ بالتحويل: $e")));
      }
    }

    setState(() {
      _isConverting = false;
    });
  }

  void _seekForward() {
    final newPosition =
        _controller.value.position + const Duration(seconds: 10);
    _controller.seekTo(newPosition);
  }

  void _seekBackward() {
    final newPosition =
        _controller.value.position - const Duration(seconds: 10);
    _controller.seekTo(
      newPosition >= Duration.zero ? newPosition : Duration.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.getText('video_player', lang)),
        actions: [
          IconButton(
            icon: _isConverting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.music_note),
            onPressed: _isConverting ? null : _convertToAudio,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
          VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: theme.colorScheme.primary,
              backgroundColor: Colors.grey[300]!,
              bufferedColor: Colors.grey[400]!,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10),
                iconSize: 36,
                onPressed: _seekBackward,
              ),
              IconButton(
                icon: Icon(
                  _controller.value.isPlaying
                      ? Icons.pause_circle
                      : Icons.play_circle,
                  color: theme.colorScheme.primary,
                ),
                iconSize: 56,
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.forward_10),
                iconSize: 36,
                onPressed: _seekForward,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
