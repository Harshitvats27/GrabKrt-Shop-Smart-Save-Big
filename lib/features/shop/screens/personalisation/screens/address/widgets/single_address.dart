import 'package:e_commerce_application/utils/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../../common/widgets/custom_shape/rounded_container.dart';
import '../../../../../../../utils/constants/sizes.dart';
import '../../../../../../../utils/helpers/helper_function.dart';
import '../../../../../../personalisation/controllers/address_controller.dart';
import '../../../../../../personalisation/models/address_model.dart';
import '../edit_address_screen.dart';
// 🔥 Apni edit screen ko yahan import kar lena
// import 'package:e_commerce_application/features/shop/screens/personalisation/screens/address/edit_address_screen.dart';

class USingleAddress extends StatelessWidget {
  const USingleAddress({
    super.key, required this.addresses, required this.onTap,
  });

  final AddressModel addresses;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final controller = AddressController.instance;
    final dark = UHelperfunctions.isDarkTheme(context);

    return Obx(() {
      String selectedAddressId = controller.selectedAddress.value.id;
      bool isSelected = selectedAddressId == addresses.id;

      return InkWell(
        onTap: onTap,
        child: URoundedContainer(
            showBorder: true,
            backgroundColor: isSelected ? UColors.primary.withValues(alpha: 0.5) : Colors.transparent,
            borderColor: isSelected ? Colors.transparent : dark ? UColors.darkerGrey : UColors.grey,
            padding: const EdgeInsets.all(USizes.md),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text width ko thoda adjust kiya taaki Edit button overlap na kare
                    Padding(
                      padding: const EdgeInsets.only(right: 30.0),
                      child: Text(addresses.name, style: Theme.of(context).textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis,),
                    ),
                    const SizedBox(height: USizes.spaceBtwItems / 2),
                    Text(addresses.phoneNumber, maxLines: 1, overflow: TextOverflow.ellipsis,),
                    const SizedBox(height: USizes.spaceBtwItems / 2),
                    Text(addresses.toString(), maxLines: 2, overflow: TextOverflow.ellipsis,)
                  ],
                ),

                // 🔥 NAYA: Edit Button (Top Right Corner)
                Positioned(
                  right: 0,
                  top: 0,
                  child: InkWell(
                    onTap: () {
                      // Pehle controller mein data bharenge
                      controller.initAddressData(addresses);
                      // Phir Edit Screen par bhej denge (Un-comment the import above)
                       Get.to(() => EditAddressScreen(address: addresses));
                    },
                    child: const Icon(Iconsax.edit, size: 20, color: Colors.grey),
                  ),
                ),

                // Purana Tick Mark (Thoda neeche khiska diya taaki edit se na takraye)
                if (isSelected)
                  const Positioned(
                      bottom: 0,
                      right: 6,
                      child: Icon(Iconsax.tick_circle)
                  )
              ],
            )
        ),
      );
    });
  }
}