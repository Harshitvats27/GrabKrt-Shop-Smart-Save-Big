import 'package:e_commerce_application/features/personalisation/controllers/user_controller.dart';
import 'package:e_commerce_application/navigation_menu.dart';
import 'package:e_commerce_application/utils/helpers/network_manager.dart';
import 'package:e_commerce_application/utils/pop_ups/full_screen_loader.dart';
import 'package:e_commerce_application/utils/pop_ups/snackbar_helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../../common/data/repositories/user/user_repository.dart';

class ChangeNameController extends GetxController {
  static ChangeNameController get instance => Get.find();

  // 🔥 1. Saare Naye TextEditingControllers Add Kar Diye Hain
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final userName = TextEditingController();
  final email = TextEditingController();
  final phoneNumber = TextEditingController();

  final _userController = UserController.instance;
  final updateUserFormKey = GlobalKey<FormState>();
  final _userRepository = UserRepository.instance;

  @override
  void onInit() {
    initializeNames();
    super.onInit();
  }

  // 🔥 2. Screen khulte hi purana data automatically fields me bhar jayega
  void initializeNames() {
    firstName.text = _userController.user.value.firstName;
    lastName.text = _userController.user.value.lastName;
    userName.text = _userController.user.value.username;
    email.text = _userController.user.value.email;
    phoneNumber.text = _userController.user.value.phoneNumber;
  }

  Future<void> updateUsername() async {
    try {
      UFullScreenLoader.openLoadingDialog(
        'We are updating your information...',
      );

      // Check internet connectivity
      bool isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected){
        UFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation check
      if (!updateUserFormKey.currentState!.validate()) {
        UFullScreenLoader.stopLoading();
        return;
      }

      // 🔥 3. Firebase me save hone wala Naya Map Update kar diya
      Map<String,dynamic> map = {
        'firstName': firstName.text.trim(),
        'lastName': lastName.text.trim(),
        'username': userName.text.trim(),
        'email': email.text.trim(),
        'phoneNumber': phoneNumber.text.trim(),
      };

      // Update data in Firebase
      await _userRepository.updateSingleField(map);

      // 🔥 4. App ke State (UserController) ko bhi immediately update kar diya
      _userController.user.value.firstName = firstName.text.trim();
      _userController.user.value.lastName = lastName.text.trim();
      _userController.user.value.username = userName.text.trim();
      _userController.user.value.email = email.text.trim();
      _userController.user.value.phoneNumber = phoneNumber.text.trim();

      // Loading band karo aur wapas bhejo
      UFullScreenLoader.stopLoading();
      Get.offAll(() => const NavigationMenu());
      USnackBarHelpers.successSnackBar(
          title: 'Congratulations',
          message: 'Your profile has been successfully updated.'
      );

    } catch (e) {
      UFullScreenLoader.stopLoading();
      USnackBarHelpers.warningSnackBar(
        title: 'Update Profile Failed',
        message: e.toString(),
      );
    }
  }
}