import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';
import '../../constants/app_strings.dart';
import '../../helpers/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_shell.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().register(
            name: _nameController.text,
            email: _emailController.text,
            mobile: _mobileController.text,
            password: _passwordController.text,
          );
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      debugPrint('REGISTER ERROR $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      imageUrl: AppImages.registerHero,
      title: AppStrings.registerTitle,
      subtitle: AppStrings.registerSubtitle,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            AppTextField(
              label: AppStrings.name,
              controller: _nameController,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.badge_outlined,
              validator: Validators.name,
            ),
            const FieldGap(),
            AppTextField(
              label: AppStrings.email,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.person_outline,
              validator: Validators.email,
            ),
            const FieldGap(),
            AppTextField(
              label: AppStrings.mobile,
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.phone_outlined,
              validator: Validators.mobile,
            ),
            const FieldGap(),
            AppTextField(
              label: AppStrings.password,
              controller: _passwordController,
              isPassword: true,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.lock_outline,
              validator: Validators.password,
            ),
            const FieldGap(),
            AppTextField(
              label: AppStrings.confirmPassword,
              controller: _confirmController,
              isPassword: true,
              textInputAction: TextInputAction.done,
              prefixIcon: Icons.lock_outline,
              validator: (value) => Validators.confirmPassword(
                value,
                _passwordController.text,
              ),
            ),
            SizedBox(height: 20.h),
            AppButton(
              label: AppStrings.register,
              onPressed: _submit,
              isLoading: _loading,
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.haveAccount,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    AppStrings.login,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
