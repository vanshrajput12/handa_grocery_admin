import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Product image for the admin panel. Images bundled inside the customer app
/// (assets/...) cannot be shown here, so they get a placeholder.
class ProductThumb extends StatelessWidget {
  const ProductThumb({super.key, required this.image});

  final String image;

  Widget _placeholder(IconData icon, String? text) {
    return Container(
      color: AppColors.amberLight,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: AppColors.inkSoft),
          if (text != null) ...[
            const SizedBox(height: 6),
            Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (image.isEmpty) {
      return _placeholder(Icons.image_outlined, null);
    }
    if (!image.startsWith('http')) {
      return _placeholder(Icons.phone_android_rounded, 'Image is inside the app');
    }
    return Image.network(
      image,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) =>
          _placeholder(Icons.broken_image_outlined, 'Preview unavailable'),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        );
      },
    );
  }
}
