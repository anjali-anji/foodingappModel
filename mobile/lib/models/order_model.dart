class OrderModel {
  const OrderModel({
    required this.orderId,
    required this.userId,
    required this.amount,
    this.paymentId,
    required this.paymentStatus,
    required this.orderStatus,
    this.name,
    this.mobile,
    this.address,
    this.pincode,
  });

  final String orderId;
  final int userId;
  final double amount;
  final String? paymentId;
  final String paymentStatus;
  final String orderStatus;
  final String? name;
  final String? mobile;
  final String? address;
  final String? pincode;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'].toString(),
      userId: (json['user_id'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      paymentId: json['payment_id'] as String?,
      paymentStatus: json['payment_status'] as String,
      orderStatus: json['order_status'] as String,
      name: json['name'] as String?,
      mobile: json['mobile'] as String?,
      address: json['address'] as String?,
      pincode: json['pincode'] as String?,
    );
  }
}
