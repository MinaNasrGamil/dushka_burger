import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;
  final IconData placeholderIcon;
  final Color? backgroundColor;

  const AppImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
    this.placeholderIcon = Icons.fastfood,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Colors.grey[200]!;
    final cleanUrl = url.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        color: bg,
        child: cleanUrl.isEmpty
            ? Icon(placeholderIcon, color: Colors.grey)
            : Image.network(
                cleanUrl,
                fit: fit,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, color: Colors.grey),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
