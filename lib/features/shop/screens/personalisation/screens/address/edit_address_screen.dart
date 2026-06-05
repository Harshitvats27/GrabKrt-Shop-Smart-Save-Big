import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import '../../../../../../common/style/padding.dart';
import '../../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../../common/widgets/button/elevated_button.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/validators/validation.dart';
import '../../../../../personalisation/controllers/address_controller.dart';
import '../../../../../personalisation/models/address_model.dart';

class EditAddressScreen extends StatelessWidget {
  final AddressModel address;

  const EditAddressScreen({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    final controller = AddressController.instance;

    return Scaffold(
      appBar: UAppBar(
        showBackArrow: true,
        title: Text('Edit Address', style: Theme.of(context).textTheme.headlineMedium),
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
                SizedBox(
                  height: 250,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(USizes.borderRadiusLg),
                    child: GetBuilder<AddressController>(
                      builder: (controller) => Stack(
                        children: [
                          GoogleMap(
                            // 🔥 Map ka center purane latitude aur longitude par hoga
                            initialCameraPosition: CameraPosition(
                                target: LatLng(address.latitude, address.longitude),
                                zoom: 15
                            ),
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

                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 35),
                              child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: USizes.spaceBtwInputFields),

                /// --- GET CURRENT LOCATION BUTTON ---
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => controller.getCurrentLocation(),
                    icon: const Icon(Iconsax.location),
                    label: const Text('Use Current Location'),
                  ),
                ),
                const SizedBox(height: USizes.spaceBtwInputFields),

                /// --- ADDRESS TYPE SELECTION ---
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
                TextFormField(
                  validator: (value) => UValidator.validateEmptyText('Name', value),
                  controller: controller.name,
                  decoration: const InputDecoration(prefixIcon: Icon(Iconsax.user), labelText: 'Name'),
                ),
                const SizedBox(height: USizes.spaceBtwInputFields),

                TextFormField(
                  validator: (value) => UValidator.validateEmptyText('Phone Number', value),
                  controller: controller.phoneNumber,
                  decoration: const InputDecoration(prefixIcon: Icon(Iconsax.mobile), labelText: 'Phone Number'),
                ),
                const SizedBox(height: USizes.spaceBtwInputFields),

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

                TextFormField(
                  validator: (value) => UValidator.validateEmptyText('Country', value),
                  controller: controller.country,
                  decoration: const InputDecoration(prefixIcon: Icon(Iconsax.global), labelText: 'Country'),
                ),
                const SizedBox(height: USizes.spaceBtwSections),

                /// --- SAVE BUTTON ---
                SizedBox(
                  width: double.infinity,
                  child: UElevatedButton(
                    // 🔥 Naye update function ko call karega
                    onPressed: () => controller.updateExistingAddress(address.id, address.selectedAddress),
                    child: const Text('Update Address'),
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