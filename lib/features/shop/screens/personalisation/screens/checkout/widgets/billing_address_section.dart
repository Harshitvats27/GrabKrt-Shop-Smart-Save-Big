import 'package:e_commerce_application/common/widgets/text/section_heading.dart';
import 'package:e_commerce_application/features/personalisation/controllers/address_controller.dart';
import 'package:e_commerce_application/utils/constants/colors.dart';
import 'package:e_commerce_application/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 🔥 APNI ADD NEW ADDRESS SCREEN YAHAN IMPORT KAR LENA

import '../../address/new_address.dart';

class UBillingAddressSection extends StatelessWidget {
  const UBillingAddressSection({super.key});

  @override
  Widget build(BuildContext context) {
    // get.put ki jagah instance use karna better hai agar pehle se initialized hai
    final controller = AddressController.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        USectionHeading(
          title: 'Billing Address',
          buttonTitle: 'Change',
          onPressed: () => controller.selectNewAddressBottomSheet(context),
        ),
        Obx(() {
          final address = controller.selectedAddress.value;

          // 🔥 NAYA LOGIC: Agar address nahi hai toh Add Address ka button dikhao
          if (address.id.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: USizes.spaceBtwItems / 2),
                Text('No address selected. Please add an address to deliver your order.', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: USizes.spaceBtwItems),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // Seedha naye address screen par bhej dega
                    onPressed: () => Get.to(() => const AddNewAddressScreen()),
                    child: const Text('Add New Address'),
                  ),
                ),
              ],
            );
          }

          // 🔥 PURANA LOGIC: Agar address mil gaya toh usko dikhao
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(address.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: USizes.spaceBtwItems / 2),
              Row(
                children: [
                  const Icon(Icons.phone, size: USizes.iconSm, color: UColors.darkGrey),
                  const SizedBox(width: USizes.spaceBtwItems),
                  Text(address.phoneNumber, softWrap: true)
                ],
              ),
              const SizedBox(height: USizes.spaceBtwItems / 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Text ke hisaab se top-align kiya
                children: [
                  const Icon(Icons.location_history, size: USizes.iconSm, color: UColors.darkGrey),
                  const SizedBox(width: USizes.spaceBtwItems),
                  Expanded(
                      child: Text(address.toString(), softWrap: true)
                  )
                ],
              ),
            ],
          );
        })
      ],
    );
  }
}