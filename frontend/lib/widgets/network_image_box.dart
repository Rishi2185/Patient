import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Network image with a tinted placeholder while loading and a graceful
/// fallback icon if it fails — so layouts never break offline.
class NetworkImageBox extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData fallbackIcon;
  final BorderRadius? radius;

  const NetworkImageBox({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.local_hospital_rounded,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    Widget placeholder({bool loading = false}) => Container(
          width: width,
          height: height,
          color: AppColors.mint,
          alignment: Alignment.center,
          child: loading
              ? const CircularProgressIndicator(
                  strokeWidth: 2.4, color: AppColors.primaryLight)
              : Icon(fallbackIcon, color: AppColors.primaryLight, size: 36),
        );

    final image = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : placeholder(loading: true),
      errorBuilder: (_, __, ___) => placeholder(),
    );

    if (radius != null) {
      return ClipRRect(borderRadius: radius!, child: image);
    }
    return image;
  }
}
