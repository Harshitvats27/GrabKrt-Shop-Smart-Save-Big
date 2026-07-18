import 'package:e_commerce_application/common/widgets/custom_shape/rounded_container.dart';
import 'package:e_commerce_application/common/widgets/loaders/animation_loader.dart';
import 'package:e_commerce_application/features/shop/models/order_model.dart';
import 'package:e_commerce_application/utils/constants/colors.dart';
import 'package:e_commerce_application/utils/constants/images.dart';
import 'package:e_commerce_application/utils/helpers/cloud_helper_functions.dart';
import 'package:e_commerce_application/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../navigation_menu.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/order/order_controller.dart';
import '../order_details_screen.dart';

class UOrderListItems extends StatelessWidget {
  const UOrderListItems({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = UHelperfunctions.isDarkTheme(context);
    final controller = Get.put(OrderController());

    return StreamBuilder(
        stream: controller.getLiveStoreOrdersStream(),
        builder: (context, snapshot) {
          final nothingFound = UAnimationLoader(
            text: 'No Orders Yet',
            showActionButton: true,
            actionText: "Let's Fill it",
            animation: UImages.pencilAnimation,
            onActionPressed: () => Get.offAll(() => const NavigationMenu()),
          );

          final widget = UCloudHelperFunctions.checkMultiRecordState(snapshot: snapshot, nothingFound: nothingFound);
          if (widget != null) return widget;

          List<OrderModel> orders = snapshot.data!;

          return ListView.separated(
              padding: const EdgeInsets.all(USizes.defaultSpace),
              separatorBuilder: (context, index) => const SizedBox(height: USizes.spaceBtwItems),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                OrderModel order = orders[index];
                String payMode = order.paymentMethod ?? 'COD';

                // 🔥 Sabse pehle status ko lowercase mein convert karenge taaki match karne mein galti na ho
                String currentStatus = order.status.toLowerCase();

                // Dynamic Status Colors & Icons
                Color statusColor = UColors.primary;
                IconData statusIcon = Iconsax.timer;

                // 1. ✅ DELIVERED (Green) - Order complete ho gaya
                if (currentStatus == 'delivered') {
                  statusColor = Colors.green;
                  statusIcon = Iconsax.verify5;
                }
                // 2. 🚚 OUT FOR DELIVERY (Orange) - Driver raste mein hai
                else if (currentStatus == 'out for delivery' || currentStatus == 'picked up') {
                  statusColor = Colors.orange;
                  statusIcon = Iconsax.truck_fast;
                }
                // 3. 🛵 DRIVER ASSIGNED (Teal) - Driver ne accept kar liya ya usko mil gaya
                else if (currentStatus == 'handed over to delivery boy' || currentStatus == 'accepted') {
                  statusColor = Colors.teal; // Ek premium color assigned driver ke liye
                  statusIcon = Iconsax.routing_2; // Ya phir Iconsax.user_tick use kar sakta hai
                }
                // 4. 📦 PROCESSING AT STORE (Blue) - Vendor ka kaam chal raha hai
                else if (currentStatus == 'accepted by vendor' || currentStatus == 'packed') {
                  statusColor = Colors.blue;
                  statusIcon = Iconsax.box;
                }
                // 5. ⏳ DEFAULT (Grey) - Pending (Jab order bas place hua hai)
                else {
                  statusColor = Colors.grey;
                  statusIcon = Iconsax.timer;
                }

                return GestureDetector(
                  onTap: () {
                    Get.to(() => OrderDetailsScreen(order: order));
                  },
                  child: URoundedContainer(
                    showBorder: true,
                    backgroundColor: dark ? UColors.dark : UColors.light,
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- TOP HEADER (Status & Date) ---
                        Container(
                          padding: const EdgeInsets.all(USizes.md),
                          decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))
                          ),
                          child: Row(
                            children: [
                              Icon(statusIcon, color: statusColor, size: 28),
                              const SizedBox(width: USizes.spaceBtwItems),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        order.status.toUpperCase(),
                                        style: Theme.of(context).textTheme.titleMedium!.apply(color: statusColor, fontWeightDelta: 2)
                                    ),
                                    Text(order.formattedOrderDate, style: Theme.of(context).textTheme.labelMedium)
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                child: Text("₹${order.totalAmount}", style: Theme.of(context).textTheme.titleMedium!.apply(color: Colors.black)),
                              )
                            ],
                          ),
                        ),

                        // --- MIDDLE SECTION (Real Order ID & Delivery Date) ---
                        Padding(
                          padding: const EdgeInsets.all(USizes.md),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Iconsax.tag, color: Colors.grey),
                                    const SizedBox(width: USizes.spaceBtwItems / 2),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Order ID', style: Theme.of(context).textTheme.labelMedium),
                                          Text(order.id, style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Iconsax.calendar, color: Colors.grey),
                                    const SizedBox(width: USizes.spaceBtwItems / 2),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Delivery By', style: Theme.of(context).textTheme.labelMedium),
                                          Text(order.formattedDeliveryDate, style: Theme.of(context).textTheme.titleSmall)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // --- BOTTOM SECTION (OTP) ---
                        // --- BOTTOM SECTION (OTP) ---
                        if (!currentStatus.contains('deliver') && !currentStatus.contains('cancelled')) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: USizes.md, right: USizes.md, bottom: USizes.md),
                            child: URoundedContainer(
                              backgroundColor: UColors.primary.withOpacity(0.1),
                              padding: const EdgeInsets.all(USizes.md),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // 🔥 FIX: Expanded laga diya taaki lamba text screen ke bahar na bage
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Delivery PIN", style: Theme.of(context).textTheme.titleMedium!.apply(color: UColors.primary)),
                                        const Text(
                                          "Share with delivery partner",
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                          overflow: TextOverflow.ellipsis, // 🔥 FIX: Agar text zyada lamba hua toh '...' dikhega
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10), // Dono ke beech thoda gap

                                  Text(
                                    order.deliveryOtp ?? '0000',
                                    style: Theme.of(context).textTheme.headlineMedium!.apply(
                                        color: UColors.primary,
                                        letterSpacingDelta: 5,
                                        fontWeightDelta: 2
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]
                        // 🔥 Yahan ek extra ']' tha jo ab maine hata diya hai
                      ],
                    ),
                  ),
                );
              });
        }
    );
  }
}