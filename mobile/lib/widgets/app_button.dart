import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final canTap = enabled && !isLoading && onPressed != null;

    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight.h,
      child: isOutlined
          ? OutlinedButton(
              onPressed: canTap ? onPressed : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill.r),
                ),
              ),
              child: _child,
            )
          : ElevatedButton(
              onPressed: canTap ? onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                disabledBackgroundColor: AppColors.disabled,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill.r),
                ),
              ),
              child: _child,
            ),
    );
  }

  Widget get _child {
    if (isLoading) {
      return SizedBox(
        width: 22.w,
        height: 22.w,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.textPrimary,
        ),
      );
    }
    return Text(
      label,
      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
    );
  }
}
