import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppStrings.logout),
          content: const Text(AppStrings.logoutConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(AppStrings.logout),
            ),
          ],
        );
      },
    );

    if (confirm != true || !context.mounted) return;

    await context.read<AuthProvider>().logout();
    context.read<CartProvider>().clear();
    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppStrings.logout,
      onPressed: () => _logout(context),
      icon: const Icon(Icons.logout, color: AppColors.textPrimary),
    );
  }
}
