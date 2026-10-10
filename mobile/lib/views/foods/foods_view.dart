import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../providers/cart_provider.dart';
import '../../providers/foods_provider.dart';
import '../../widgets/food_card.dart';
import '../../widgets/logout_button.dart';

class FoodsView extends StatefulWidget {
  const FoodsView({super.key});

  @override
  State<FoodsView> createState() => _FoodsViewState();
}

class _FoodsViewState extends State<FoodsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final foodsState = context.watch<FoodsProvider>();
    final cart = context.watch<CartProvider>();
    final foods = foodsState.foods;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.foods),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Center(
              child: Text(
                '${cart.itemCount} in cart',
                style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
              ),
            ),
          ),
          const LogoutButton(),
        ],
      ),
      body: foodsState.loading && foods.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: foodsState.load,
              child: GridView.builder(
                padding: EdgeInsets.all(AppSizes.paddingMd.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 0.68,
                ),
                itemCount: foods.length,
                itemBuilder: (context, index) {
                  final food = foods[index];
                  final qty = cart.quantityOf(food.id);
                  return FoodCard(
                    food: food,
                    quantity: qty,
                    onAdd: () => context.read<CartProvider>().add(food),
                    onIncrease: () => context.read<CartProvider>().increase(food.id),
                    onDecrease: () => context.read<CartProvider>().decrease(food.id),
                  );
                },
              ),
            ),
    );
  }
}
