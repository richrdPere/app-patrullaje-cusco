import 'package:flutter/material.dart';

class ImagePreviewDialog extends StatelessWidget {
  final String url;

  const ImagePreviewDialog({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            width: screenSize.width,
            height: screenSize.height * 0.82,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(18),
            ),
            clipBehavior: Clip.antiAlias,
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 5,
              boundaryMargin: const EdgeInsets.all(40),
              child: Center(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
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
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white70,
                            size: 48,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No se pudo cargar la imagen.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          Positioned(
            top: 10,
            right: 10,
            child: _ClosePreviewButton(
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
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
