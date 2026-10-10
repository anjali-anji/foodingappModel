import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.isPassword = false,
    this.prefixIcon,
    this.textInputAction,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool isPassword;
  final IconData? prefixIcon;
  final TextInputAction? textInputAction;
  final int maxLines;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.isPassword && _obscure,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      style: TextStyle(fontSize: 15.sp, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: widget.label,
        hintStyle: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(widget.prefixIcon, size: 20.sp, color: AppColors.textSecondary),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  size: 20.sp,
                  color: AppColors.textSecondary,
                ),
              )
            : null,
      ),
    );
  }
}

/// Extra spacing between form fields using ScreenUtil.
class FieldGap extends StatelessWidget {
  const FieldGap({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: AppSizes.paddingMd.h);
  }
}
