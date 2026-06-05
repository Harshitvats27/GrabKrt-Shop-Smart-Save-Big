import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:e_commerce_application/common/widgets/loaders/circular_loader.dart';
import 'package:e_commerce_application/common/widgets/text/section_heading.dart';
import 'package:e_commerce_application/utils/constants/sizes.dart';
import 'package:e_commerce_application/utils/helpers/cloud_helper_functions.dart';
import 'package:e_commerce_application/utils/helpers/network_manager.dart';
import 'package:e_commerce_application/utils/pop_ups/full_screen_loader.dart';
import 'package:e_commerce_application/utils/pop_ups/snackbar_helpers.dart';

import '../../../data/repositories/address/address_repository.dart';
import '../../shop/screens/personalisation/screens/address/widgets/single_address.dart';
import '../models/address_model.dart';

class AddressController extends GetxController {
  static AddressController get instance => Get.find();

  final _repository = Get.put(AddressRepository());
  Rx<AddressModel> selectedAddress = AddressModel.empty().obs;
  RxBool refreshData = false.obs;
  GoogleMapController? googleMapController;
  /// Text Controllers
  final name = TextEditingController();
  final phoneNumber = TextEditingController();
  final street = TextEditingController();


  final postalCode = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final country = TextEditingController();

  /// Location & Type Controllers
  final latitude = TextEditingController();
  final longitude = TextEditingController();
  final selectedAddressType = 'Home'.obs;
  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }
  final GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();

  /// Fetch all addresses from Firebase
  Future<List<AddressModel>> getAllAddresses() async {
    try {
      List<AddressModel> addresses = await _repository.fetchUserAddresses();
      selectedAddress.value = addresses.firstWhere(
            (element) => element.selectedAddress,
        orElse: () => AddressModel.empty(),
      );
      return addresses;
    } catch (e) {
      USnackBarHelpers.errorSnackBar(title: 'Error', message: e.toString());
      return [];
    }
  }

  /// Update Coordinates from Map Tap or GPS
  void updateCoordinates(LatLng position) {
    latitude.text = position.latitude.toString();
    longitude.text = position.longitude.toString();
    update();
  }

  /// Fetch Current GPS Location
  Future<void> getCurrentLocation() async {
    try {
      UFullScreenLoader.openLoadingDialog('Fetching Current Location...');
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        LatLng currentLocation = LatLng(position.latitude, position.longitude);

        updateCoordinates(currentLocation);

        // NAYA CODE: Map ke camera ko automatically current location par animate karein
        if (googleMapController != null) {
          googleMapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: currentLocation, zoom: 16),
            ),
          );
        }
      }
      UFullScreenLoader.stopLoading();
    } catch (e) {
      UFullScreenLoader.stopLoading();
      USnackBarHelpers.errorSnackBar(title: 'Location Error', message: e.toString());
    }
  }

  /// Save New Address
  Future<void> addNewAddress() async {
    try {
      UFullScreenLoader.openLoadingDialog('Storing Address...');

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        UFullScreenLoader.stopLoading();
        return;
      }

      if (!addressFormKey.currentState!.validate()) {
        UFullScreenLoader.stopLoading();
        return;
      }

      AddressModel address = AddressModel(
        id: '',
        name: name.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        street: street.text.trim(),
        city: city.text.trim(),
        state: state.text.trim(),
        postalCode: postalCode.text.trim(),
        country: country.text.trim(),
        selectedAddress: true,
        dateTime: DateTime.now(),
        latitude: double.tryParse(latitude.text.trim()) ?? 0.0,
        longitude: double.tryParse(longitude.text.trim()) ?? 0.0,
        addressType: selectedAddressType.value,
      );

      String addressId = await _repository.addAddress(address);
      address.id = addressId;
      await selectAddress(address);

      UFullScreenLoader.stopLoading();
      resetFormFields();
      Navigator.pop(Get.context!);
      Navigator.pop(Get.context!);
      USnackBarHelpers.successSnackBar(title: 'Success', message: 'Address saved successfully');
      refreshData.toggle();
    } catch (e) {
      UFullScreenLoader.stopLoading();
      USnackBarHelpers.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Select a specific address and update in DB
  Future<void> selectAddress(AddressModel newSelectedAddress) async {
    try {
      Get.defaultDialog(
        title: '',
        onWillPop: () async => false,
        barrierDismissible: false,
        backgroundColor: Colors.transparent,
        content: const UCircularLoader(),
      );

      if (selectedAddress.value.id.isNotEmpty) {
        await _repository.updateSelectedField(selectedAddress.value.id, false);
      }

      newSelectedAddress.selectedAddress = true;
      selectedAddress.value = newSelectedAddress;
      await _repository.updateSelectedField(selectedAddress.value.id, true);
      Get.back();
    } catch (e) {
      Get.back();
      USnackBarHelpers.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// [FIX] Missing Method for Checkout Address Change
  Future<void> selectNewAddressBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(USizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              USectionHeading(title: 'Select Address', showActionButtton: false),
              const SizedBox(height: USizes.spaceBtwItems),
              FutureBuilder(
                future: getAllAddresses(),
                builder: (context, snapshot) {
                  final widget = UCloudHelperFunctions.checkMultiRecordState(snapshot: snapshot);
                  if (widget != null) return widget;

                  return ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (_, __) => const SizedBox(height: USizes.spaceBtwItems),
                    itemBuilder: (context, index) => USingleAddress(
                      addresses: snapshot.data![index],
                      onTap: () async {
                        await selectAddress(snapshot.data![index]);
                        Get.back();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void resetFormFields() {
    name.clear();
    phoneNumber.clear();
    street.clear();
    postalCode.clear();
    city.clear();
    state.clear();
    country.clear();
    latitude.clear();
    longitude.clear();
    selectedAddressType.value = 'Home';
    addressFormKey.currentState?.reset();
    update();
  }
// Controller ke andar is method ko sahi kijiye
  void onCameraMove(CameraPosition position) {
    latitude.text = position.target.latitude.toString();
    longitude.text = position.target.longitude.toString();
    update();
  }

  /// --- EDIT ADDRESS LOGIC ---

  // 1. Jab bhi Edit button dabega, pehle purana data fields mein bhar do
  void initAddressData(AddressModel address) {
    name.text = address.name;
    phoneNumber.text = address.phoneNumber;
    street.text = address.street;
    postalCode.text = address.postalCode;
    city.text = address.city;
    state.text = address.state;
    country.text = address.country;
    latitude.text = address.latitude.toString();
    longitude.text = address.longitude.toString();
    selectedAddressType.value = address.addressType.isNotEmpty ? address.addressType : 'Home';
    update();
  }

  // 2. Naya data save karne ke liye
  Future<void> updateExistingAddress(String addressId, bool isSelected) async {
    try {
      UFullScreenLoader.openLoadingDialog('Updating Address...');

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        UFullScreenLoader.stopLoading();
        return;
      }

      if (!addressFormKey.currentState!.validate()) {
        UFullScreenLoader.stopLoading();
        return;
      }

      // Naya updated address model banao
      AddressModel updatedAddress = AddressModel(
        id: addressId,
        name: name.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        street: street.text.trim(),
        city: city.text.trim(),
        state: state.text.trim(),
        postalCode: postalCode.text.trim(),
        country: country.text.trim(),
        selectedAddress: isSelected, // Purana selection status maintain rakho
        dateTime: DateTime.now(),
        latitude: double.tryParse(latitude.text.trim()) ?? 0.0,
        longitude: double.tryParse(longitude.text.trim()) ?? 0.0,
        addressType: selectedAddressType.value,
      );

      // Firebase me update call karo
      // NOTE: Apne AddressRepository mein updateAddress(AddressModel address) function bana lena agar nahi hai toh
      await _repository.updateAddress(updatedAddress);

      // Agar yehi selected address tha, toh local state bhi update kar do
      if(selectedAddress.value.id == addressId){
        selectedAddress.value = updatedAddress;
      }

      UFullScreenLoader.stopLoading();
      resetFormFields();
      Navigator.pop(Get.context!); // Edit screen band karo
      USnackBarHelpers.successSnackBar(title: 'Success', message: 'Address updated successfully');
      refreshData.toggle(); // List ko refresh karo
    } catch (e) {
      UFullScreenLoader.stopLoading();
      USnackBarHelpers.errorSnackBar(title: 'Error', message: e.toString());
    }
  }


}