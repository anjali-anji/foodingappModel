import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class PlaceholderView extends StatelessWidget {
  const PlaceholderView({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Text(
            AppStrings.comingSoon,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
