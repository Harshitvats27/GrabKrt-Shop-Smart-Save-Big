import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Official Package [cite: 300, 323]\
import 'package:flutter/foundation.dart'; // Factory ke liye
import 'package:flutter/gestures.dart';   // GestureRecognizer ke liye

// Aapke projects ke specific paths (Inhe check kar lena)
import '../../../../../../common/style/padding.dart';
import '../../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../../common/widgets/button/elevated_button.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/validators/validation.dart';
import '../../../../../personalisation/controllers/address_controller.dart';

class AddNewAddressScreen extends StatelessWidget {
  const AddNewAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller ka instance le rahe hain [cite: 374]
    final controller = AddressController.instance;

    return Scaffold(
      appBar: UAppBar(
        showBackArrow: true,
        title: Text('Add New Address', style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: UPadding.screenPadding,
          child: Form(
            key: controller.addressFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// --- INTERACTIVE MAP PICKER ---
                /// Isse user map drag karke center pin se location select kar sakta hai
                SizedBox(
                  height: 250,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(USizes.borderRadiusLg),
                    child: GetBuilder<AddressController>(
                      builder: (controller) => Stack( // 1. Yahan GoogleMap ki jagah Stack lagaya
                        children: [
                          GoogleMap(
                            initialCameraPosition: const CameraPosition(target: LatLng(28.6139, 77.2090), zoom: 14),

                            // 2. onTap aur markers hata kar onCameraMove laga diya
                            onCameraMove: (CameraPosition position) {
                              controller.onCameraMove(position);
                            },
                              zoomControlsEnabled: false,
                            gestureRecognizers: Set()
                              ..add(Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer())),
                            onMapCreated: (GoogleMapController mapController) {
                              controller.googleMapController = mapController;
                            },

                          ),

                          // 3. Center mein ek static Pin laga di jo hamesha map ke beech mein rahegi
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 35), // Pin ke point ko center mein laane ke liye
                              child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: USizes.spaceBtwInputFields),

                /// --- GET CURRENT LOCATION BUTTON --- [cite: 126, 252]
                /// Automatic GPS coordinates fetch karne ke liye
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => controller.getCurrentLocation(),
                    icon: const Icon(Iconsax.location),
                    label: const Text('Use Current Location'),
                  ),
                ),
                const SizedBox(height: USizes.spaceBtwInputFields),

                /// --- ADDRESS TYPE SELECTION (Home, Office, Other) --- [cite: 267, 286, 296]
                Text('Save Address As', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: USizes.xs),
                Obx(() => Row(
                  children: ['Home', 'Office', 'Other'].map((type) => Padding(
                    padding: const EdgeInsets.only(right: USizes.sm),
                    child: ChoiceChip(
                      label: Text(type),
                      selected: controller.selectedAddressType.value == type,
                      onSelected: (val) => controller.selectedAddressType.value = type,
                    ),
                  )).toList(),
                )),
                const SizedBox(height: USizes.spaceBtwInputFields),

                /// --- TEXT FORM FIELDS ---
                // Name
                TextFormField(
                  validator: (value) => UValidator.validateEmptyText('Name', value),
                  controller: controller.name,
                  decoration: const InputDecoration(prefixIcon: Icon(Iconsax.user), labelText: 'Name'),
                ),
                const SizedBox(height: USizes.spaceBtwInputFields),

                // Phone Number
                TextFormField(
                  validator: (value) => UValidator.validateEmptyText('Phone Number', value),
                  controller: controller.phoneNumber,
                  decoration: const InputDecoration(prefixIcon: Icon(Iconsax.mobile), labelText: 'Phone Number'),
                ),
                const SizedBox(height: USizes.spaceBtwInputFields),

                // Street & Postal Code
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        validator: (value) => UValidator.validateEmptyText('Street', value),
                        controller: controller.street,
                        decoration: const InputDecoration(prefixIcon: Icon(Iconsax.building_31), labelText: 'Street'),
                      ),
                    ),
                    const SizedBox(width: USizes.spaceBtwInputFields),
                    Expanded(
                      child: TextFormField(
                        validator: (value) => UValidator.validateEmptyText('Postal Code', value),
                        controller: controller.postalCode,
                        decoration: const InputDecoration(prefixIcon: Icon(Iconsax.code), labelText: 'Postal Code'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: USizes.spaceBtwInputFields),

                // City & State
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        validator: (value) => UValidator.validateEmptyText('City', value),
                        controller: controller.city,
                        decoration: const InputDecoration(prefixIcon: Icon(Iconsax.building), labelText: 'City'),
                      ),
                    ),
                    const SizedBox(width: USizes.spaceBtwInputFields),
                    Expanded(
                      child: TextFormField(
                        validator: (value) => UValidator.validateEmptyText('State', value),
                        controller: controller.state,
                        decoration: const InputDecoration(prefixIcon: Icon(Iconsax.activity), labelText: 'State'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: USizes.spaceBtwInputFields),

                // Country
                TextFormField(
                  validator: (value) => UValidator.validateEmptyText('Country', value),
                  controller: controller.country,
                  decoration: const InputDecoration(prefixIcon: Icon(Iconsax.global), labelText: 'Country'),
                ),
                const SizedBox(height: USizes.spaceBtwSections),

                /// --- SAVE BUTTON ---
                /// Isse saari details (coordinates ke sath) database mein save ho jayengi [cite: 375]
                SizedBox(
                  width: double.infinity,
                  child: UElevatedButton(
                    onPressed: () => controller.addNewAddress(),
                    child: const Text('Save Address'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}