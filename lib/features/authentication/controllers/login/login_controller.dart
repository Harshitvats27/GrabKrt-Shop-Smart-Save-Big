import 'package:e_commerce_application/common/data/repositories/authentication_repository.dart';
import 'package:e_commerce_application/common/data/repositories/user/user_repository.dart'; // 🔥 ADDED: UserRepository import kiya
import 'package:e_commerce_application/utils/constants/key.dart';
import 'package:e_commerce_application/utils/pop_ups/full_screen_loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // 🔥 ADDED: Messaging import kiya
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/pop_ups/snackbar_helpers.dart';
import '../../../personalisation/controllers/user_controller.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  // Variables
  final _userContrller=Get.put(UserController());
  final email = TextEditingController();
  final password = TextEditingController();
  RxBool isPasswordVisible = false.obs;
  RxBool rememberMe = false.obs;
  final loginFormKey = GlobalKey<FormState>();
  final localStorage = GetStorage();

  @override
  void onInit() {
    email.text=localStorage.read(UKeys.rememberMeEmail)??'';
    password.text=localStorage.read(UKeys.rememberMePassword)??'';
    super.onInit();
  }

  // 🔥 ADDED: Token nikalne aur save karne ka function
  Future<void> _saveUserToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        // Tere UserRepository ka updateSingleField use kar rahe hain
        await UserRepository.instance.updateSingleField({
          'userDeviceToken': token,
        });
        print("🔥 Token Saved to Firebase: $token");
      }
    } catch (e) {
      print("❌ Token Error: $e");
    }
  }

  Future<void> loginWithEmailandPassword() async {
    try {
      // Start Loading
      UFullScreenLoader.openLoadingDialog('Logging You in.......');

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        UFullScreenLoader.stopLoading();
        USnackBarHelpers.warningSnackBar(title: 'No Internet Connection');
        return;
      }

      if (!loginFormKey.currentState!.validate()) {
        UFullScreenLoader.stopLoading();
        return;
      }

      if (rememberMe.value) {
        localStorage.write(UKeys.rememberMeEmail, email.text.trim());
        localStorage.write(UKeys.rememberMePassword, password.text.trim());
      }

      // login user with email and password
      await AuthenticationReposiotory.instance.loginWithEmailandPassword(
        email.text.trim(),
        password.text.trim(),
      );

      // 🔥 ADDED: Screen redirect se pehle token save karwao
      await _saveUserToken();

      UFullScreenLoader.stopLoading();
      AuthenticationReposiotory.instance.screenRedirect();
    } catch (e) {
      UFullScreenLoader.stopLoading();
      USnackBarHelpers.errorSnackBar(
        title: 'Login Failed',
        message: e.toString(),
      );
    }
  }

  Future<void> googleSignIn()async{
    try{
      // start Loading
      UFullScreenLoader.openLoadingDialog('Logging You in.......');

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        UFullScreenLoader.stopLoading();
        USnackBarHelpers.warningSnackBar(title: 'No Internet Connection');
        return;
      }

      // Google Authrntication
      UserCredential userCredential = await AuthenticationReposiotory.instance.loginWithGoogle();

      await _userContrller.saveUserRecord(userCredential);

      // 🔥 ADDED: Screen redirect se pehle token save karwao
      await _saveUserToken();

      UFullScreenLoader.stopLoading();
      AuthenticationReposiotory.instance.screenRedirect();

    }catch(e){
      UFullScreenLoader.stopLoading();
      USnackBarHelpers.errorSnackBar(
          title: 'Login Failed',
          message: e.toString());
    }
  }
}