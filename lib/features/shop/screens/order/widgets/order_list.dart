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

class UOrderListItems extends StatelessWidget {
  const UOrderListItems({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = UHelperfunctions.isDarkTheme(context);
    final controller = Get.put(OrderController());

    return FutureBuilder(
        future: controller.fetchUserOrders(),
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
                String currentStatus = order.orderStatusText.toLowerCase();

                // Dynamic Status Colors & Icons
                Color statusColor = UColors.primary;
                IconData statusIcon = Iconsax.box_time;

                if (currentStatus.contains('deliver')) {
                  statusColor = Colors.green;
                  statusIcon = Iconsax.verify5;
                } else if (currentStatus.contains('way') || currentStatus.contains('ship') || currentStatus.contains('out')) {
                  statusColor = Colors.orange;
                  statusIcon = Iconsax.truck_fast;
                } else {
                  statusColor = Colors.blue;
                  statusIcon = Iconsax.box;
                }

                // 🔥 1. GESTURE DETECTOR ADD KIYA (Future screen ke liye)
                return GestureDetector(
                  onTap: () {
                    // TODO: Aage chal kar yahan se OrderDetailsScreen kholenge (Photos + Tracking ke liye)
                    print("Order Clicked: ${order.id}");
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
                                        order.orderStatusText.toUpperCase(),
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
                                    // 🔥 2. REAL DATABASE ID (With overflow handling)
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

                        // --- BOTTOM SECTION (Delivery PIN for Prepaid) ---
                        if (payMode != 'COD' && payMode != 'Cash on Delivery' && !currentStatus.contains('deliver')) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: USizes.md, right: USizes.md, bottom: USizes.md),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                              decoration: BoxDecoration(
                                  color: UColors.primary.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: UColors.primary.withOpacity(0.3), width: 1.5),
                                  boxShadow: [BoxShadow(color: UColors.primary.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
                              ),
                              // 🔥 3. RENDER FLEX OVERFLOW FIX (Expanded used)
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Delivery PIN", style: Theme.of(context).textTheme.labelMedium!.apply(color: UColors.primary)),
                                        const SizedBox(height: 2),
                                        const Text("Share with delivery partner", style: TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                    child: Text(
                                        order.deliveryOtp ?? '0000',
                                        style: Theme.of(context).textTheme.headlineMedium!.apply(
                                            color: UColors.primary,
                                            letterSpacingDelta: 6,
                                            fontWeightDelta: 2
                                        )
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ]
                      ],
                    ),
                  ),
                );
              });
        }
    );
  }
}