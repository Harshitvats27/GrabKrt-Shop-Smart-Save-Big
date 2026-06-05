import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';

import '../../../common/data/repositories/authentication_repository.dart';
import '../../../features/shop/models/order_model.dart';
import '../../../utils/constants/key.dart';

class OrderRepository extends GetxController{
  static OrderRepository get instance => Get.find();

  /// Variables
  final _db = FirebaseFirestore.instance;


  /// [Save] - Save user Order
  /// [Save] - Save user Order using DUAL-WRITE strategy
  Future<void> saveOrder(OrderModel order) async{
    try{
      // Create a batch to run multiple writes at the exact same time
      WriteBatch batch = _db.batch();

      // Write 1: Admin & User History (Users -> {uid} -> Orders -> {orderId})
      DocumentReference userOrderRef = _db
          .collection(UKeys.userCollection)
          .doc(order.userId)
          .collection(UKeys.ordersCollection)
          .doc(order.id); // Using order.id instead of .add()

      // Write 2: Delivery Partner App
      // (All_Orders -> {orderId})
      DocumentReference globalOrderRef = _db
          .collection(UKeys.allOrdersCollection)
          .doc(order.id); // Keeping the same ID makes it easy to sync later

      // Add both operations to the batch
      batch.set(userOrderRef, order.toJson());
      batch.set(globalOrderRef, order.toJson());

      // Commit the batch to Firebase
      await batch.commit();

    }catch(e){
      throw 'Something went wrong while saving order info: $e';
    }
  }

  /// [Fetch] - Fetch user orders
  /// [Fetch] - Fetch user orders
  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      final userId = AuthenticationReposiotory.instance.currentUser!.uid;
      if (userId.isEmpty) throw 'Unable to find user information';

      // 🔥 NAYA CHANGE: .orderBy('orderDate', descending: true) add kiya hai
      final query = await _db
          .collection(UKeys.userCollection)
          .doc(userId)
          .collection(UKeys.ordersCollection)
          .orderBy('orderDate', descending: true) // Naye orders top par aayenge
          .get();

      if (query.docs.isNotEmpty) {
        List<OrderModel> orders = query.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList();
        return orders;
      }

      return [];

    } catch (e) {
      throw 'Something went wrong while fetching order info';
    }
  }
}