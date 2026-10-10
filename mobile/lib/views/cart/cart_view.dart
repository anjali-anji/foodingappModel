import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../helpers/price_format.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/logout_button.dart';
import '../../widgets/qty_stepper.dart';
import '../checkout/checkout_view.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.cart),
        automaticallyImplyLeading: false,
        actions: const [LogoutButton()],
      ),
      body: cart.isEmpty
          ? Center(
              child: Text(
                AppStrings.emptyCart,
                style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.all(AppSizes.paddingMd.w),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return _CartTile(item: item);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
                  color: AppColors.surface,
                  child: Column(
                    children: [
                      _AmountRow(label: AppStrings.subtotal, value: cart.subtotal),
                      SizedBox(height: 8.h),
                      _AmountRow(label: AppStrings.total, value: cart.total, bold: true),
                      SizedBox(height: 16.h),
                      AppButton(
                        label: AppStrings.checkout,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CheckoutView()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(
              item.food.image,
              width: 72.w,
              height: 72.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                width: 72.w,
                height: 72.w,
                color: AppColors.accent,
                child: const Icon(Icons.fastfood),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.food.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  PriceFormat.inr(item.lineTotal),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                QtyStepper(
                  quantity: item.quantity,
                  onIncrease: () => cart.increase(item.food.id),
                  onDecrease: () => cart.decrease(item.food.id),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => cart.remove(item.food.id),
            icon: Icon(Icons.delete_outline, color: AppColors.error, size: 22.sp),
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final double value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 16.sp : 14.sp,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      color: AppColors.textPrimary,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(PriceFormat.inr(value), style: style),
      ],
    );
  }
}
