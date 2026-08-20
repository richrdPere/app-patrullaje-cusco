import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewDialog extends StatefulWidget {
  final String url;

  const VideoPreviewDialog({super.key, required this.url});

  @override
  State<VideoPreviewDialog> createState() => _VideoPreviewDialogState();
}

class _VideoPreviewDialogState extends State<VideoPreviewDialog> {
  late final VideoPlayerController _controller;

  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));

      await _controller.initialize();

      if (!mounted) {
        await _controller.dispose();
        return;
      }

      _controller
        ..setLooping(false)
        ..addListener(_videoListener);

      setState(() {
        _isInitialized = true;
      });

      await _controller.play();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _hasError = true;
      });
    }
  }

  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _controller.removeListener(_videoListener);
    }

    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: screenSize.width,
        constraints: BoxConstraints(maxHeight: screenSize.height * 0.82),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _isInitialized
                  ? _controller.value.aspectRatio
                  : 16 / 9,
              child: _buildVideoContent(),
            ),

            if (_isInitialized && !_hasError)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _showControls = !_showControls;
                    });
                  },
                  child: AnimatedOpacity(
                    opacity: _showControls ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: _VideoControls(
                      controller: _controller,
                      onClose: _closeVideo,
                    ),
                  ),
                ),
              )
            else
              Positioned(
                top: 10,
                right: 10,
                child: _ClosePreviewButton(onPressed: _closeVideo),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_hasError) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white70, size: 48),
            SizedBox(height: 12),
            Text(
              'No se pudo reproducir el video.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }

    return VideoPlayer(_controller);
  }

  void _closeVideo() {
    if (_isInitialized) {
      _controller.pause();
    }

    Navigator.of(context).pop();
  }
}

class _VideoControls extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback onClose;

  const _VideoControls({required this.controller, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final isPlaying = controller.value.isPlaying;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.45),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.65),
              ],
              stops: const [0, 0.45, 1],
            ),
          ),
        ),

        Center(
          child: IconButton.filled(
            onPressed: () {
              if (isPlaying) {
                controller.pause();
              } else {
                controller.play();
              }
            },
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.65),
              foregroundColor: Colors.white,
              minimumSize: const Size(58, 58),
            ),
            iconSize: 34,
            icon: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            ),
          ),
        ),

        Positioned(
          left: 12,
          right: 12,
          bottom: 10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Colors.redAccent,
                  bufferedColor: Colors.white38,
                  backgroundColor: Colors.white24,
                ),
              ),

              const SizedBox(height: 5),

              Row(
                children: [
                  Text(
                    _formatDuration(controller.value.position),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),

                  const Spacer(),

                  Text(
                    _formatDuration(controller.value.duration),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),

        Positioned(
          top: 10,
          right: 10,
          child: _ClosePreviewButton(onPressed: onClose),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}

class _ClosePreviewButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ClosePreviewButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      tooltip: 'Cerrar',
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.65),
        foregroundColor: Colors.white,
      ),
      icon: const Icon(Icons.close_rounded),
    );
  }
}
