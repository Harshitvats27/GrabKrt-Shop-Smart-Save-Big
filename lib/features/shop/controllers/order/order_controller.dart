import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_application/common/data/repositories/authentication_repository.dart';
import 'package:e_commerce_application/features/shop/controllers/cart/cart_controller.dart';
import 'package:e_commerce_application/utils/pop_ups/snackbar_helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'dart:math';

import '../../../../common/widgets/screeens/success_screen.dart';
import '../../../../data/repositories/order/order_repository.dart';
import '../../../../navigation_menu.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/images.dart';
import '../../../../utils/pop_ups/full_screen_loader.dart';
import '../../../personalisation/controllers/address_controller.dart';
import '../../models/cart_item_model.dart';
import '../../models/order_model.dart';
import '../checkout/checkout_controller.dart';
import '../promo_code/promo_code_controller.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();
  final cartController = CartController.instance;
  final checkoutControllerc = CheckoutController.instance;
  final addressController = AddressController.instance;
  final _repository = Get.put(OrderRepository());

//   Future<void> processOrder(double totalAmount) async {
//     try {
//       // start loading
//       UFullScreenLoader.openLoadingDialog('Processing your order...');
//
//       // check user existence
//       String userId = AuthenticationReposiotory.instance.currentUser!.uid;
//       if (userId.isEmpty) return;
// // 🔥 1. YAHAN 4-DIGIT KA PIN GENERATE KARO
//       String generatedPin = (Random().nextInt(9000) + 1000).toString();
//       // Create Order Model
//       OrderModel order = OrderModel(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         status: OrderStatus.pending,
//         items: cartController.cartItems.toList(),
//         totalAmount: totalAmount,
//         orderDate: DateTime.now(),
//         userId: userId,
//         paymentMethod: checkoutControllerc.selectedPaymentMethod.value.name,
//         address: addressController.selectedAddress.value,
//         deliveryDate: DateTime.now().add(Duration(days: 3)),
//         deliveryOtp: generatedPin,
//       );
//       await _repository.saveOrder(order);
//       // 🔥 Decrease promo code count after successful order
//       if (PromoCodeController.instance.appliedPromoCode.value.id.isNotEmpty) {
//         await PromoCodeController.instance.decreaseNoOfPromoCodes();
//       }
//       // 🔥 Add user to promo AFTER successful order
//       if (PromoCodeController.instance.appliedPromoCode.value.id.isNotEmpty) {
//
//         await PromoCodeController.instance.addUserToPromoCode();
//
//         await PromoCodeController.instance.decreaseNoOfPromoCodes();
//       }
//
//
//       cartController.clearCart();
//       Get.to(
//         () => SuccessScreen(
//           image: UImages.successfulPaymentIcon,
//           title: 'Payment Success',
//           subTitle: 'Your Items will be Shipped Soon',
//           onTap: () => Get.offAll(() => NavigationMenu()),
//         ),
//       );
//     } catch (e) {
//       USnackBarHelpers.errorSnackBar(
//         title: 'Order Failed',
//         message: e.toString(),
//       );
//     }
//   }
  Future<void> processOrder(double totalAmount) async {
    try {
      // start loading
      UFullScreenLoader.openLoadingDialog('Processing your order...');

      // check user existence
      String userId = AuthenticationReposiotory.instance.currentUser!.uid;
      if (userId.isEmpty) return;

      // 🔥 STEP 1: CART ITEMS KO VENDOR ID KE BASIS PE GROUP KARO
      Map<String, List<CartItemModel>> groupedItems = {};
      for (var item in cartController.cartItems) {
        String vendorId = item.vendorId ?? 'unknown_vendor';

        if (!groupedItems.containsKey(vendorId)) {
          groupedItems[vendorId] = [];
        }
        groupedItems[vendorId]!.add(item);
      }

      // 🔥 STEP 2: MASTER ORDER (User ke dashboard ke liye)
      String generatedPin = (Random().nextInt(9000) + 1000).toString();

      OrderModel order = OrderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        status: OrderStatus.pending,
        items: cartController.cartItems.toList(),
        totalAmount: totalAmount,
        orderDate: DateTime.now(),
        userId: userId,
        paymentMethod: checkoutControllerc.selectedPaymentMethod.value.name,
        address: addressController.selectedAddress.value,
        deliveryDate: DateTime.now().add(const Duration(days: 3)),
        deliveryOtp: generatedPin,
      );

      // Master Order Save
      await _repository.saveOrder(order);

      // 🔥 STEP 3: SUB-ORDERS (Vendors ke liye)
      for (var vendorId in groupedItems.keys) {
        double vendorTotal = groupedItems[vendorId]!.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

        // 🟢 NAYA LOGIC: 'where' query se vendorId dhoondhna
        double storeLat = 0.0;
        double storeLng = 0.0;
        String storeName = "Unknown Store";

        if (vendorId != 'unknown_vendor') {
          try {
            // 🔥 FIX: doc() ki jagah where() lagaya hai
            QuerySnapshot storeQuery = await FirebaseFirestore.instance
                .collection('Stores')
                .where('vendorId', isEqualTo: vendorId)
                .limit(1) // Ek vendor ka ek store uthayega
                .get();

            if (storeQuery.docs.isNotEmpty) {
              var sData = storeQuery.docs.first.data() as Map<String, dynamic>;

              double parseToDouble(dynamic val) {
                if (val == null) return 0.0;
                if (val is double) return val;
                if (val is int) return val.toDouble();
                if (val is String) return double.tryParse(val) ?? 0.0;
                return 0.0;
              }

              // 🔥 FIX 2: Tere StoreModel ke hisaab se keys 'latitude' aur 'longitude' hain
              storeLat = parseToDouble(sData['latitude']);
              storeLng = parseToDouble(sData['longitude']);
              storeName = sData['storeName'] ?? "Store";

              print("✅ SUCCESS: Store Location Mil Gayi -> Lat: $storeLat, Lng: $storeLng");
            } else {
              print("❌ Store Doc nahi mila is vendorId par: $vendorId");
            }
          } catch (e) {
            print("🚨 ERROR fetching store location: $e");
          }
        }
        // 🟢 NAYA LOGIC: Database mein dono ki locations save karna
        await FirebaseFirestore.instance.collection('Store_Orders').doc().set({
          'masterOrderId': order.id,
          'vendorId': vendorId,
          'userId': userId,
          'items': groupedItems[vendorId]!.map((e) => e.toJson()).toList(),
          'vendorTotal': vendorTotal,
          'status': 'Pending',
          'orderDate': Timestamp.now(),
          'userName': addressController.selectedAddress.value.name,
          'deliveryOtp': generatedPin,
          'paymentMethod': checkoutControllerc.selectedPaymentMethod.value.name,

          // 🔥 1. CUSTOMER KA ADDRESS (Jo Red Screen de raha tha, ab fix ho gaya)
          'address': addressController.selectedAddress.value.toJson(),

          // 🔥 2. VENDOR/STORE KI LOCATION (Delivery Boy ke Radius Filter ke liye)
          'storeName': storeName,
          'storeLat': storeLat,
          'storeLng': storeLng,
        });
      }

      // Promo logic
      if (PromoCodeController.instance.appliedPromoCode.value.id.isNotEmpty) {
        await PromoCodeController.instance.addUserToPromoCode();
        await PromoCodeController.instance.decreaseNoOfPromoCodes();
      }

      cartController.clearCart();

      Get.to(() => SuccessScreen(
        image: UImages.successfulPaymentIcon,
        title: 'Payment Success',
        subTitle: 'Your Items will be Shipped Soon',
        onTap: () => Get.offAll(() => NavigationMenu()),
      ));

    } catch (e) {
      USnackBarHelpers.errorSnackBar(title: 'Order Failed', message: e.toString());
    }
  }










  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      final orders = await _repository.fetchUserOrders();
      return orders;
    } catch (e) {
      USnackBarHelpers.errorSnackBar(title: 'Failed', message: e.toString());
      return [];
    }
  }

  Future<void> processOrderFromRazorpay(String paymentId) async {
    await processOrder(cartController.totalCartPrice.value);
  }
}
