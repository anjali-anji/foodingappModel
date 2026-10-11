import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../helpers/price_format.dart';
import '../../providers/orders_provider.dart';

class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>();
    final order = orders.byId(orderId);
    final email = orders.lastEmail;
    final fcm = orders.lastFcm;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Order details')),
      body: order == null
          ? const Center(child: Text('Order not found'))
          : ListView(
              padding: EdgeInsets.all(AppSizes.paddingLg.w),
              children: [
                _DetailCard(
                  children: [
                    _row(AppStrings.orderId, order.orderId),
                    _row(AppStrings.userId, '${order.userId}'),
                    _row(AppStrings.amount, PriceFormat.inr(order.amount)),
                    _row(AppStrings.paymentId, order.paymentId ?? '-'),
                    _row(AppStrings.paymentStatus, order.paymentStatus),
                    _row(AppStrings.orderStatus, order.orderStatus),
                  ],
                ),
                if (order.name != null) ...[
                  SizedBox(height: 16.h),
                  _DetailCard(
                    children: [
                      _row(AppStrings.name, order.name!),
                      _row(AppStrings.mobile, order.mobile ?? '-'),
                      _row(AppStrings.address, order.address ?? '-'),
                      _row(AppStrings.pincode, order.pincode ?? '-'),
                    ],
                  ),
                ],
                if (email != null || fcm != null) ...[
                  SizedBox(height: 16.h),
                  _DetailCard(
                    children: [
                      if (email != null)
                        _row(
                          'Email',
                          email['sent'] == true
                              ? 'Sent to ${email['to'] ?? ''}'
                              : 'Saved locally',
                        ),
                      if (email?['previewUrl'] != null)
                        _row('Email preview', email!['previewUrl'].toString()),
                      if (fcm != null)
                        _row(
                          'FCM',
                          fcm['sent'] == true ? 'Sent to phone' : 'Not sent',
                        ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius.r),
      ),
      child: Column(children: children),
    );
  }
}
