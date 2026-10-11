import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../helpers/price_format.dart';
import '../../helpers/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
import '../../services/fcm_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../orders/order_details_view.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _razorpay = Razorpay();
  bool _loading = false;
  String? _pendingOrderId;

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final cart = context.read<CartProvider>();
    if (cart.isEmpty) return;

    setState(() => _loading = true);
    try {
      final orders = context.read<OrdersProvider>();
      final order = await orders.create(
        amount: cart.total,
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        address: _addressController.text.trim(),
        pincode: _pincodeController.text.trim(),
      );
      _pendingOrderId = order.orderId;
      debugPrint('RAZORPAY APP ORDER ${_pendingOrderId}');

      final payment = await orders.createPayment(
        orderId: order.orderId,
        amount: order.amount,
      );
      debugPrint('RAZORPAY CREATE RES $payment');

      final razorpayOrder = Map<String, dynamic>.from(
        payment['razorpay_order'] as Map,
      );
      final keyId = payment['key_id']?.toString() ?? '';
      final testMode = payment['test_mode'] == true ||
          keyId.contains('placeholder') ||
          keyId.isEmpty;

      if (mounted) setState(() => _loading = false);

      if (testMode) {
        debugPrint('RAZORPAY TEST MODE checkout');
        await _openTestCheckout(order.orderId, razorpayOrder);
        return;
      }

      final email = context.read<AuthProvider>().user?.email ?? '';
      final options = {
        'key': keyId,
        'amount': (razorpayOrder['amount'] as num).toInt(),
        'currency': 'INR',
        'name': 'Fooding',
        'description': 'Order ${order.orderId}',
        'order_id': razorpayOrder['id'].toString(),
        'prefill': {
          'name': _nameController.text.trim(),
          'email': email,
          'contact': _mobileController.text.trim(),
        },
        'method': {
          'upi': true,
          'card': true,
          'netbanking': true,
          'wallet': true,
        },
        'config': {
          'display': {
            'blocks': {
              'upi_only': {
                'name': 'Pay using UPI',
                'instruments': [
                  {'method': 'upi'},
                ],
              },
              'other': {
                'name': 'Cards, Netbanking & Wallets',
                'instruments': [
                  {'method': 'card'},
                  {'method': 'netbanking'},
                  {'method': 'wallet'},
                ],
              },
            },
            'sequence': ['block.upi_only', 'block.other'],
            'preferences': {
              'show_default_blocks': true,
            },
          },
        },
        'theme': {'color': '#F5C518'},
      };
      debugPrint('RAZORPAY OPEN $options');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _razorpay.open(options);
      });
    } catch (e) {
      debugPrint('RAZORPAY START ERROR $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), duration: const Duration(seconds: 5)),
      );
      setState(() => _loading = false);
    }
  }

  Future<void> _openTestCheckout(
    String orderId,
    Map<String, dynamic> razorpayOrder,
  ) async {
    final amount = context.read<CartProvider>().total;
    final pay = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Razorpay Test'),
          content: Text(
            'Amount ${PriceFormat.inr(amount)}\nOrder $orderId\n\nTest payment complete karein.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Pay'),
            ),
          ],
        );
      },
    );
    if (pay == true) {
      await _verifyAndFinish(
        razorpayOrderId: razorpayOrder['id'].toString(),
        paymentId: 'pay_test_${DateTime.now().millisecondsSinceEpoch}',
        signature: '',
      );
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint(
      'RAZORPAY SUCCESS paymentId=${response.paymentId} orderId=${response.orderId} sign=${response.signature}',
    );
    await _verifyAndFinish(
      razorpayOrderId: response.orderId ?? '',
      paymentId: response.paymentId ?? '',
      signature: response.signature ?? '',
    );
  }

  Future<void> _verifyAndFinish({
    required String razorpayOrderId,
    required String paymentId,
    required String signature,
  }) async {
    final orderId = _pendingOrderId;
    if (orderId == null) return;

    setState(() => _loading = true);
    try {
      final updated = await context.read<OrdersProvider>().verifyPayment(
            orderId: orderId,
            razorpayOrderId: razorpayOrderId,
            paymentId: paymentId,
            signature: signature,
          );
      if (!mounted) return;
      await FcmService.instance.showOrderNotification(
        title: 'Order confirmed',
        body:
            'Order ${updated.orderId} of ₹${updated.amount.toStringAsFixed(0)} is confirmed',
      );
      context.read<CartProvider>().clear();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderDetailsView(orderId: updated.orderId),
        ),
      );
    } catch (e) {
      debugPrint('RAZORPAY VERIFY ERROR $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), duration: const Duration(seconds: 5)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    debugPrint('RAZORPAY ERROR code=${response.code} message=${response.message}');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message ?? 'cancelled'}'),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    debugPrint('RAZORPAY WALLET ${response.walletName}');
  }

  @override
  Widget build(BuildContext context) {
    final total = context.watch<CartProvider>().total;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.checkout)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.paddingLg.w),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppStrings.total}: ${PriceFormat.inr(total)}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 20.h),
              AppTextField(
                label: AppStrings.name,
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: Validators.name,
              ),
              const FieldGap(),
              AppTextField(
                label: AppStrings.mobile,
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                textInputAction: TextInputAction.next,
                validator: Validators.mobile,
              ),
              const FieldGap(),
              AppTextField(
                label: AppStrings.address,
                controller: _addressController,
                prefixIcon: Icons.home_outlined,
                textInputAction: TextInputAction.next,
                maxLines: 3,
                validator: Validators.address,
              ),
              const FieldGap(),
              AppTextField(
                label: AppStrings.pincode,
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.pin_drop_outlined,
                textInputAction: TextInputAction.done,
                validator: Validators.pincode,
              ),
              SizedBox(height: 28.h),
              AppButton(
                label: AppStrings.placeOrder,
                onPressed: _pay,
                isLoading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
