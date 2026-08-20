import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullscreenVideoViewer extends StatefulWidget {
  final String url;

  const FullscreenVideoViewer({super.key, required this.url});

  @override
  State<FullscreenVideoViewer> createState() => _FullscreenVideoViewerState();
}

class _FullscreenVideoViewerState extends State<FullscreenVideoViewer> {
  late final VideoPlayerController _controller;

  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();

      if (!mounted) {
        return;
      }

      await _controller.setLooping(false);
      _controller.addListener(_videoListener);

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _isInitialized
                    ? () {
                        setState(() {
                          _showControls = !_showControls;
                        });
                      }
                    : null,
                child: Center(child: _buildVideoContent()),
              ),
            ),

            if (_isInitialized && !_hasError)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: AnimatedOpacity(
                    opacity: _showControls ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: _buildControls(),
                  ),
                ),
              ),

            Positioned(
              top: 8,
              right: 8,
              child: _FullscreenCloseButton(onPressed: _close),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_hasError) {
      return const _FullscreenError(
        icon: Icons.error_outline_rounded,
        message: 'No se pudo reproducir el video.',
      );
    }

    if (!_isInitialized) {
      return const CircularProgressIndicator(
        strokeWidth: 2,
        color: Colors.white,
      );
    }

    final aspectRatio = _controller.value.aspectRatio > 0
        ? _controller.value.aspectRatio
        : 16 / 9;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: VideoPlayer(_controller),
    );
  }

  Widget _buildControls() {
    final isPlaying = _controller.value.isPlaying;

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
                Colors.black.withValues(alpha: 0.72),
              ],
              stops: const [0, 0.5, 1],
            ),
          ),
        ),

        Center(
          child: IconButton.filled(
            onPressed: _togglePlayback,
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.65),
              foregroundColor: Colors.white,
              minimumSize: const Size(64, 64),
            ),
            iconSize: 38,
            icon: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            ),
          ),
        ),

        Positioned(
          left: 18,
          right: 18,
          bottom: 18,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                colors: const VideoProgressColors(
                  playedColor: Colors.redAccent,
                  bufferedColor: Colors.white38,
                  backgroundColor: Colors.white24,
                ),
              ),

              Row(
                children: [
                  Text(
                    _formatDuration(_controller.value.position),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),

                  const Spacer(),

                  Text(
                    _formatDuration(_controller.value.duration),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _togglePlayback() async {
    if (_controller.value.isPlaying) {
      await _controller.pause();
    } else {
      if (_controller.value.position >= _controller.value.duration) {
        await _controller.seekTo(Duration.zero);
      }

      await _controller.play();
    }
  }

  void _close() {
    if (_isInitialized) {
      _controller.pause();
    }

    Navigator.of(context).pop();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}

class _FullscreenCloseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _FullscreenCloseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      tooltip: 'Cerrar',
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.68),
        foregroundColor: Colors.white,
        minimumSize: const Size(44, 44),
      ),
      icon: const Icon(Icons.close_rounded),
    );
  }
}

class _FullscreenError extends StatelessWidget {
  final IconData icon;
  final String message;

  const _FullscreenError({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: Colors.white70),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
