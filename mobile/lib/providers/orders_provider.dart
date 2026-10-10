import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';

class OrdersProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  bool loading = false;
  String? error;

  List<OrderModel> get orders => List.unmodifiable(_orders);

  OrderModel? byId(String id) {
    for (final order in _orders) {
      if (order.orderId == id) return order;
    }
    return null;
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final json = await ApiService.instance.get(ApiConstants.orders, auth: true);
      final list = json['orders'] as List<dynamic>;
      _orders = list
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<OrderModel> create({
    required double amount,
    required String name,
    required String mobile,
    required String address,
    required String pincode,
  }) async {
    final json = await ApiService.instance.post(
      ApiConstants.orders,
      {
        'amount': amount,
        'name': name,
        'mobile': mobile,
        'address': address,
        'pincode': pincode,
      },
      auth: true,
    );
    final order = OrderModel.fromJson(json['order'] as Map<String, dynamic>);
    _orders.insert(0, order);
    notifyListeners();
    return order;
  }

  Future<Map<String, dynamic>> createPayment({
    required String orderId,
    required double amount,
  }) async {
    debugPrint('RAZORPAY CREATE order=$orderId amount=$amount');
    return ApiService.instance.post(
      ApiConstants.paymentCreate,
      {'order_id': orderId, 'amount': amount},
      auth: true,
    );
  }

  Future<OrderModel> verifyPayment({
    required String orderId,
    required String razorpayOrderId,
    required String paymentId,
    required String signature,
  }) async {
    debugPrint('RAZORPAY VERIFY order=$orderId payment=$paymentId');
    final json = await ApiService.instance.post(
      ApiConstants.paymentVerify,
      {
        'order_id': orderId,
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      },
      auth: true,
    );
    final order = OrderModel.fromJson(json['order'] as Map<String, dynamic>);
    final index = _orders.indexWhere((o) => o.orderId == order.orderId);
    if (index >= 0) {
      _orders[index] = order;
    } else {
      _orders.insert(0, order);
    }
    notifyListeners();
    return order;
  }

  void addOrder(OrderModel order) {
    _orders.insert(0, order);
    notifyListeners();
  }
}
