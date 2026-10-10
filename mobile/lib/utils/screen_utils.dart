import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_sizes.dart';

class ScreenUtils {
  ScreenUtils._();

  static const double designWidth = AppSizes.designWidth;
  static const double designHeight = AppSizes.designHeight;

  static double w(num value) => value.w;
  static double h(num value) => value.h;
  static double sp(num value) => value.sp;
  static double r(num value) => value.r;
}
