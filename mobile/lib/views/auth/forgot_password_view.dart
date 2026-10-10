import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';
import '../../constants/app_strings.dart';
import '../../helpers/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_shell.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.resetSent)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      imageUrl: AppImages.forgotHero,
      title: AppStrings.forgotTitle,
      subtitle: AppStrings.forgotSubtitle,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            AppTextField(
              label: AppStrings.email,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              prefixIcon: Icons.email_outlined,
              validator: Validators.email,
            ),
            SizedBox(height: 24.h),
            AppButton(label: AppStrings.sendResetLink, onPressed: _submit),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text(
                AppStrings.backToLogin,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
