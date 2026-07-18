import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_application/utils/helpers/helper_function.dart';
import '../../../utils/constants/enums.dart';
import '../../personalisation/models/address_model.dart';
import 'cart_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final String status;
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

  String get formattedDeliveryDate => deliveryDate != null ? UHelperfunctions.getFormattedDate(deliveryDate!) : 'N/A';

  // String get orderStatusText => status == OrderStatus.delivered
  //     ? 'Delivered'
  //     : status == OrderStatus.pending ? 'Pending'
  //     : status == OrderStatus.processing ? 'Processing'
  //     : status == OrderStatus.shipped ? 'Shipment on the way'
  //     : 'Processing';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'status': status,
      'totalAmount': totalAmount,
      'orderDate': orderDate,
      'paymentMethod': paymentMethod,
      'address': address?.toJson(),
      'deliveryDate': deliveryDate,
      'items': items.map((item) => item.toJson()).toList(),
      'deliveryOtp': deliveryOtp,
    };
  }

  // 1. Map se model banane ke liye
  factory OrderModel.fromJson(Map<String, dynamic> data) {
    return OrderModel(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      status: data['status']??'',
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      orderDate: data['orderDate'] != null ? (data['orderDate'] as Timestamp).toDate() : DateTime.now(),
      paymentMethod: data['paymentMethod'] ?? 'COD',
      address: data['address'] != null ? AddressModel.fromMap(data['address'] as Map<String, dynamic>) : null,
      deliveryDate: (data.containsKey('deliveryDate') && data['deliveryDate'] is Timestamp)
          ? (data['deliveryDate'] as Timestamp).toDate()
          : null,
      items: data['items'] != null
          ? (data['items'] as List<dynamic>).map((itemData) => CartItemModel.fromJson(itemData as Map<String, dynamic>)).toList()
          : [],
      deliveryOtp: data['deliveryOtp'] ?? '0000',
    );
  }

  // 2. Firebase Snapshot se model banane ke liye
  factory OrderModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return OrderModel.fromJson({...data, 'id': snapshot.id});
  }
}