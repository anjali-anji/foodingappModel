import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../helpers/price_format.dart';
import '../../models/order_model.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/logout_button.dart';
import 'order_details_view.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = context.watch<OrdersProvider>();
    final orders = ordersState.orders;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.myOrders),
        automaticallyImplyLeading: false,
        actions: const [LogoutButton()],
      ),
      body: ordersState.loading && orders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? Center(
              child: Text(
                AppStrings.emptyOrders,
                style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              ),
            )
          : RefreshIndicator(
              onRefresh: ordersState.load,
              child: ListView.separated(
                padding: EdgeInsets.all(AppSizes.paddingMd.w),
                itemCount: orders.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  return _OrderTile(order: orders[index]);
                },
              ),
            ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrderDetailsView(orderId: order.orderId),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radius.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderId,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  PriceFormat.inr(order.amount),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              '${AppStrings.paymentStatus}: ${order.paymentStatus}',
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
            Text(
              '${AppStrings.orderStatus}: ${order.orderStatus}',
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
