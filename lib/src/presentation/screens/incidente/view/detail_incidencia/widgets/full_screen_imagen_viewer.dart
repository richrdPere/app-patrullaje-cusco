import 'package:flutter/material.dart';

class FullscreenImageViewer extends StatelessWidget {
  final String url;
  final String heroTag;

  const FullscreenImageViewer({
    super.key,
    required this.url,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                boundaryMargin: const EdgeInsets.all(80),
                clipBehavior: Clip.none,
                child: Center(
                  child: Hero(
                    tag: heroTag,
                    child: Image.network(
                      url,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) {
                          return child;
                        }

                        final expectedBytes = progress.expectedTotalBytes;

                        final value = expectedBytes == null
                            ? null
                            : progress.cumulativeBytesLoaded / expectedBytes;

                        return Center(
                          child: CircularProgressIndicator(
                            value: value,
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) {
                        return const _FullscreenError(
                          icon: Icons.broken_image_outlined,
                          message: 'No se pudo cargar la imagen.',
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 8,
              right: 8,
              child: _FullscreenCloseButton(
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
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
