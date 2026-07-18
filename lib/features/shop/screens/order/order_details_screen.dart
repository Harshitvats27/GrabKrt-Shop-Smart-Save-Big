import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/custom_shape/rounded_container.dart';
import '../../../../common/widgets/images/rounded_image.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_function.dart';
import '../../../../utils/helpers/pricing_calculator.dart';
import '../../models/order_model.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final dark = UHelperfunctions.isDarkTheme(context);
    String payMode = order.paymentMethod ?? 'COD';
    String currentStatus = order.status ?? '';

    // Dynamic Status Colors & Icons
    Color statusColor = UColors.primary;
    IconData statusIcon = Iconsax.box_time;

    if (currentStatus.contains('deliver')) {
      statusColor = Colors.green;
      statusIcon = Iconsax.verify5;
    } else if (currentStatus.contains('way') ||
        currentStatus.contains('ship') ||
        currentStatus.contains('out')) {
      statusColor = Colors.orange;
      statusIcon = Iconsax.truck_fast;
    } else {
      statusColor = Colors.blue;
      statusIcon = Iconsax.box;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(USizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. STATUS & ORDER INFO CARD
            URoundedContainer(
              showBorder: true,
              backgroundColor: dark ? UColors.dark : UColors.light,
              padding: const EdgeInsets.all(USizes.md),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 32),
                      const SizedBox(width: USizes.spaceBtwItems),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.status.toUpperCase(),
                              style: Theme.of(context).textTheme.titleLarge!
                                  .apply(
                                color: statusColor,
                                fontWeightDelta: 2,
                              ),
                            ),
                            Text(
                              "Placed on: ${order.formattedOrderDate}",
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: USizes.spaceBtwSections),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order ID', style: Theme.of(context).textTheme.bodyMedium),
                      Text(order.id, style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                  const SizedBox(height: USizes.spaceBtwItems / 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Payment Method', style: Theme.of(context).textTheme.bodyMedium),
                      Text(payMode, style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: USizes.spaceBtwSections),

            // 2. ITEMS LIST CARD
            Text("Purchased Items", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: USizes.spaceBtwItems),
            URoundedContainer(
              showBorder: true,
              backgroundColor: dark ? UColors.dark : UColors.light,
              padding: const EdgeInsets.all(USizes.md),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                separatorBuilder: (_, __) => const Divider(height: 25),
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return Row(
                    children: [
                      URoundedImage(
                        imageUrl: item.image ?? '',
                        isNetworkImage: true,
                        width: 60,
                        height: 60,
                        backgroundColor: dark ? UColors.darkerGrey : UColors.grey,
                      ),
                      const SizedBox(width: USizes.spaceBtwItems),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text("Qty: ${item.quantity}", style: Theme.of(context).textTheme.labelLarge),
                          ],
                        ),
                      ),
                      Text(
                        "₹${(item.price * item.quantity).toStringAsFixed(2)}",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: USizes.spaceBtwSections),

            // 3. DELIVERY ADDRESS CARD
            if (order.address != null) ...[
              Text("Delivery Address", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: USizes.spaceBtwItems),
              URoundedContainer(
                showBorder: true,
                backgroundColor: dark ? UColors.dark : UColors.light,
                padding: const EdgeInsets.all(USizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.address!.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.grey, size: 16),
                        const SizedBox(width: 8),
                        Text(order.address!.phoneNumber, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${order.address!.street}, ${order.address!.city}, ${order.address!.state} - ${order.address!.postalCode}",
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: USizes.spaceBtwSections),
            ],

            // 4. BILLING SUMMARY (Swiggy Style)
            Text("Bill Details", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: USizes.spaceBtwItems),
            URoundedContainer(
              showBorder: true,
              backgroundColor: dark ? UColors.dark : UColors.light,
              padding: const EdgeInsets.all(USizes.md),
              child: Builder(
                builder: (context) {
                  double subTotal = order.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
                  double taxFee = double.tryParse(UPricingCalculator.calculateTax(subTotal, 'Kenya')) ?? 0.0;
                  double shippingFee = double.tryParse(UPricingCalculator.calculateShippingCost(subTotal, 'Kenya')) ?? 0.0;

                  double expectedTotal = subTotal + taxFee + shippingFee;
                  double actualTotal = order.totalAmount;
                  double discount = expectedTotal - actualTotal;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Item Total', style: Theme.of(context).textTheme.bodyMedium),
                          Text("₹${subTotal.toStringAsFixed(2)}", style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: USizes.spaceBtwItems / 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Delivery Partner Fee', style: Theme.of(context).textTheme.bodyMedium),
                          Text("₹${shippingFee.toStringAsFixed(2)}", style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: USizes.spaceBtwItems / 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Taxes & Platform Charges', style: Theme.of(context).textTheme.bodyMedium),
                          Text("₹${taxFee.toStringAsFixed(2)}", style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: USizes.spaceBtwItems / 2),

                      if (discount > 0.1) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Promo Discount', style: Theme.of(context).textTheme.bodyMedium!.apply(color: UColors.success)),
                            Text("- ₹${discount.toStringAsFixed(2)}", style: Theme.of(context).textTheme.bodyMedium!.apply(color: UColors.success)),
                          ],
                        ),
                        const SizedBox(height: USizes.spaceBtwItems / 2),
                      ],

                      const Divider(),
                      const SizedBox(height: USizes.spaceBtwItems / 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Grand Total', style: Theme.of(context).textTheme.titleLarge),
                          Text("₹${actualTotal.toStringAsFixed(2)}", style: Theme.of(context).textTheme.titleLarge!.apply(color: UColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: UColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Iconsax.info_circle, size: 16, color: UColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Your delivery partner is travelling long distance to deliver your order.",
                                style: TextStyle(fontSize: 11, color: UColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: USizes.spaceBtwSections),

            // 5. DELIVERY OTP SECTION
            if (!currentStatus.contains('deliver') && !currentStatus.contains('cancelled')) ...[
              URoundedContainer(
                backgroundColor: UColors.primary.withOpacity(0.1),
                padding: const EdgeInsets.all(USizes.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Delivery PIN", style: Theme.of(context).textTheme.titleMedium!.apply(color: UColors.primary)),
                        const Text("Share with delivery partner", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
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
            ]
          ],
        ),
      ),
    );
  }
}