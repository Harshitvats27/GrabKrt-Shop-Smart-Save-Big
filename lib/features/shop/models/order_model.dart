

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_application/utils/helpers/helper_function.dart';
import '../../../utils/constants/enums.dart';
import '../../personalisation/models/address_model.dart';
import 'cart_item_model.dart';

class OrderModel{
  final String id;
  final String userId;
  final OrderStatus status;
  final double totalAmount;
  final DateTime orderDate;
  final String paymentMethod;
  final AddressModel? address;
  final DateTime? deliveryDate;
  final List<CartItemModel> items;
  final String? deliveryOtp;

  OrderModel({
    required this.id,
    this.userId = '',
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    this.paymentMethod = '',
    this.address,
    this.deliveryDate,
    this.deliveryOtp,
  });

  String get formattedOrderDate => UHelperfunctions.getFormattedDate(orderDate);

  String get formattedDeliveryDate => UHelperfunctions.getFormattedDate(deliveryDate!);

  String get orderStatusText => status == OrderStatus.delivered
      ? 'Delivered'
      : status == OrderStatus.pending ? 'Pending'
      : status == OrderStatus.processing ? 'Processing'
      : status == OrderStatus.shipped
      ? 'Shipment on the way'
      : 'Processing';

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'userId': userId,
      'status' : status.toString(), // Enum to string
      'totalAmount': totalAmount,
      'orderDate' : orderDate,
      'paymentMethod': paymentMethod,
      'address': address?.toJson(), // convert address model to map
      'deliveryDate': deliveryDate,
      'items': items.map((item) => item.toJson()).toList(), // convert CartItemModel to map
      'deliveryOtp': deliveryOtp,
    };
  }

  factory OrderModel.fromSnapshot(DocumentSnapshot snapshot){
    final data = snapshot.data() as Map<String, dynamic>?;

    // Agar data null aa jaye to crash bachane ke liye (wese hoga nahi)
    if (data == null) throw Exception("Order data is empty");

    return OrderModel(
      // 1. Strings ke liye safe fallback ('')
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',

      // 2. Enum fallback (Agar status galat ho to pending maan lega)
      status: OrderStatus.values.firstWhere(
              (element) => element.toString() == data['status'],
          orElse: () => OrderStatus.pending
      ),

      // 3. Number safety (Firebase kabhi int deta hai kabhi double, to .toDouble() zaroori hai)
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),

      // 4. Date safety
      orderDate: data['orderDate'] != null ? (data['orderDate'] as Timestamp).toDate() : DateTime.now(),

      // 🔥 5. Yahan error aa raha tha! (As String hata diya)
      paymentMethod: data['paymentMethod'] ?? 'COD',

      // 6. Address aur items ke liye null checks
      address: data['address'] != null ? AddressModel.fromMap(data['address'] as Map<String, dynamic>) : null,

      deliveryDate: (data.containsKey('deliveryDate') && data['deliveryDate'] is Timestamp)
          ? (data['deliveryDate'] as Timestamp).toDate()
          : null,

      items: data['items'] != null
          ? (data['items'] as List<dynamic>).map((itemData) => CartItemModel.fromJson(itemData as Map<String, dynamic>)).toList()
          : [],

      // 7. Aapka OTP hack
      deliveryOtp: data['deliveryOtp'] ?? '0000',
    );
  }
}