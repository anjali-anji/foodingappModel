import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

class NetworkHeroImage extends StatelessWidget {
  const NetworkHeroImage({super.key, required this.url, this.height});

  final String url;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: Image.network(
        url,
        height: height ?? 168.h,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            height: height ?? 168.h,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height ?? 168.h,
            color: AppColors.accent,
            child: Icon(Icons.person, size: 72.sp, color: AppColors.primaryDark),
          );
        },
      ),
    );
  }
}
