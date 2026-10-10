import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import 'network_hero_image.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showHeart = false,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final Widget child;
  final bool showHeart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _AuthDecor(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 22.w,
                  vertical: 16.h,
                ),
                child: Container(
                  padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 22.h),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(36.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      NetworkHeroImage(url: imageUrl),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (showHeart) ...[
                            Icon(
                              Icons.favorite,
                              size: 16.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 6.w),
                          ],
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSizes.paddingLg.h),
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthDecor extends StatelessWidget {
  const _AuthDecor();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.background, AppColors.backgroundDark],
            ),
          ),
        ),
        Positioned(
          top: 48.h,
          left: -10.w,
          child: const _Cloud(),
        ),
        Positioned(
          top: 80.h,
          right: 12.w,
          child: const _Cloud(),
        ),
        Positioned(
          bottom: 90.h,
          left: 8.w,
          child: Icon(Icons.lunch_dining, size: 56.sp, color: AppColors.primaryDark),
        ),
        Positioned(
          bottom: 70.h,
          right: 12.w,
          child: Icon(Icons.local_pizza, size: 48.sp, color: AppColors.primaryDark),
        ),
      ],
    );
  }
}

class _Cloud extends StatelessWidget {
  const _Cloud();

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.cloud, size: 56.sp, color: AppColors.cloud);
  }
}
