import 'package:e_commerce_application/common/data/repositories/authentication_repository.dart';
import 'package:e_commerce_application/features/authentication/models/user_model.dart';
import 'package:e_commerce_application/features/shop/screens/personalisation/screens/edit_profile/widgets/re_authenticate_user_form.dart';
import 'package:e_commerce_application/utils/constants/sizes.dart';
import 'package:e_commerce_application/utils/helpers/network_manager.dart';
import 'package:e_commerce_application/utils/pop_ups/full_screen_loader.dart';
import 'package:e_commerce_application/utils/pop_ups/snackbar_helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


import '../../../common/data/repositories/user/user_repository.dart';
import '../../authentication/screens/login/login.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  // variables
  final _userReposiotory = Get.put(UserRepository());
  Rx<UserModel> user = UserModel.empty().obs;
  RxBool profileLoading = false.obs;
  RxBool imageUploading = false.obs;


  final email = TextEditingController();
  final password = TextEditingController();
  final reAuthFormKey = GlobalKey<FormState>();
  RxBool isPasswordVisible = false.obs;

  @override
  void onInit() {
    fetchUserDetails();
    super.onInit();
  }

  Future<void> saveUserRecord(UserCredential userCredential) async {
    try {
      await fetchUserDetails();
      if (user.value.id.isEmpty) {
        final nameParts = UserModel.nameParts(userCredential.user!.displayName);
        final username = '${userCredential.user!.displayName}';
        UserModel userModel = UserModel(
          id: userCredential.user!.uid,
          firstName: nameParts[0],
          lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
          username: username,
          email: userCredential.user!.email ?? '',
          phoneNumber: userCredential.user!.phoneNumber ?? '',
          profilePicture: userCredential.user!.photoURL ?? '',
        );

        await _userReposiotory.saveUserRecord(userModel);
      }

    } catch (e) {
      USnackBarHelpers.warningSnackBar(
        title: 'Data not saved',
        message: 'Something Went Wrong While Saving Data',
      );
    }
  }

  Future<void> fetchUserDetails() async {
    try {
      profileLoading.value = true;
      UserModel user = await _userReposiotory.fetchUserDetails();
      this.user(user);
    } catch (e) {
      user(UserModel.empty());
    } finally {
      profileLoading.value = false;
    }
  }

  void deleteAccountMarginPopup() {
    Get.defaultDialog(
      title: 'Delete Account',
      middleText: 'Are you sure you want to delete your account?',
      confirm: ElevatedButton(
        onPressed: () {
          Get.back(); // close dialog first
          handleAccountDeletion(); // ✅ CENTRALIZED METHOD
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          side: BorderSide(color: Colors.red),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: USizes.lg),
          child: Text('Delete'),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        child: Text('Cancel'),
      ),
    );
  }
  Future<void> confirmEmailPasswordReAuthAndDelete() async {
    try {
      // 1️⃣ Network check
      bool isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) return;

      // 2️⃣ Form validation
      if (!reAuthFormKey.currentState!.validate()) return;

      UFullScreenLoader.openLoadingDialog('Verifying...');

      final authRepo = AuthenticationReposiotory.instance;
      final uid = authRepo.currentUser!.uid;

      // 3️⃣ Re-authenticate (Email / Password)
      await authRepo.reAuthenticateUserEmailandPassword(
        email.text.trim(),
        password.text.trim(),
      );

      // 4️⃣ Delete profile image (safe)
      await UserRepository.instance.deleteProfileImage(uid);

      // 5️⃣ Delete Firestore user document
      await UserRepository.instance.removeUserRecord(uid);

      // 6️⃣ Delete Firebase Auth account
      await authRepo.currentUser!.delete();

      UFullScreenLoader.stopLoading();

      Get.offAll(() => LoginScreen());

      USnackBarHelpers.successSnackBar(
        title: 'Account Deleted',
        message: 'Your account has been deleted successfully',
      );
    } catch (e) {
      UFullScreenLoader.stopLoading();
      USnackBarHelpers.errorSnackBar(
        title: 'Verification Failed',
        message: e.toString(),
      );
    }
  }


  // Future<void> deleteUserAccount() async {
  //   try {
  //     UFullScreenLoader.openLoadingDialog('Processing....');
  //     final authRepository = AuthenticationReposiotory.instance;
  //     final provider = authRepository.currentUser!.providerData
  //         .map((e) => e.providerId)
  //         .first;
  //     if (provider == 'google.com') {
  //       await authRepository.loginWithGoogle();
  //       await authRepository.deleteAccount();
  //
  //       UFullScreenLoader.stopLoading();
  //       Get.offAll(() => LoginScreen());
  //     } else if (provider == 'password') {
  //       UFullScreenLoader.stopLoading();
  //       Get.offAll(() => ReAuthenticateUserFormScreen());
  //     }
  //   } catch (e) {
  //     UFullScreenLoader.stopLoading();
  //     USnackBarHelpers.errorSnackBar(title: 'Error', message: e.toString());
  //   }
  // }
  // Future<void> deleteUserAccount() async {
  //   try {
  //     UFullScreenLoader.openLoadingDialog('Deleting account...');
  //
  //     final authRepo = AuthenticationReposiotory.instance;
  //     final uid = authRepo.currentUser!.uid;
  //
  //     // 1️⃣ Delete profile image from Storage (override-safe)
  //     try {
  //       await FirebaseStorage.instance
  //           .ref('users/$uid/profile.jpg')
  //           .delete();
  //     } catch (_) {
  //       // Image may not exist → ignore safely
  //     }
  //
  //     // 2️⃣ Delete Firestore user document
  //     await _userReposiotory.removeUserRecord(uid);
  //
  //     // 3️⃣ Delete Firebase Auth user
  //     await authRepo.deleteAccount();
  //
  //     UFullScreenLoader.stopLoading();
  //     Get.offAll(() => LoginScreen());
  //
  //     USnackBarHelpers.successSnackBar(
  //       title: 'Account Deleted',
  //       message: 'Your account has been permanently deleted',
  //     );
  //   } catch (e) {
  //     UFullScreenLoader.stopLoading();
  //     USnackBarHelpers.errorSnackBar(
  //       title: 'Deletion Failed',
  //       message: e.toString(),
  //     );
  //   }
  // }
  Future<void> handleAccountDeletion() async {
    try {
      UFullScreenLoader.openLoadingDialog('Processing...');

      final authRepo = AuthenticationReposiotory.instance;
      final providerId =
          authRepo.currentUser!.providerData.first.providerId;

      /// 🔐 EMAIL/PASSWORD → Ask reauth
      if (providerId == 'password') {
        UFullScreenLoader.stopLoading();
        Get.to(() => ReAuthenticateUserFormScreen());
        return;
      }

      /// 🔐 GOOGLE → Silent reauth + delete
      if (providerId == 'google.com') {
        await authRepo.reAuthenticateWithGoogle();
        await authRepo.deleteAccount();

        UFullScreenLoader.stopLoading();
        Get.offAll(() => LoginScreen());

        USnackBarHelpers.successSnackBar(
          title: 'Account Deleted',
          message: 'Your account has been deleted successfully',
        );
      }
    } catch (e) {
      UFullScreenLoader.stopLoading();
      USnackBarHelpers.errorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    }
  }
  Future<void> reauthenticateAndDelete() async {
    try {
      UFullScreenLoader.openLoadingDialog('Verifying...');

      final authRepo = AuthenticationReposiotory.instance;

      await authRepo.reAuthenticateUserEmailandPassword(
        email.text.trim(),
        password.text.trim(),
      );

      await authRepo.deleteAccount();

      UFullScreenLoader.stopLoading();
      Get.offAll(() => LoginScreen());

      USnackBarHelpers.successSnackBar(
        title: 'Account Deleted',
        message: 'Your account has been deleted successfully',
      );
    } catch (e) {
      UFullScreenLoader.stopLoading();
      USnackBarHelpers.errorSnackBar(
        title: 'Failed',
        message: e.toString(),
      );
    }
  }

  // Future<void> reAuthenticateUser() async {
  //   try {
  //     UFullScreenLoader.openLoadingDialog('Processing....');
  //     final authRepository = AuthenticationReposiotory.instance;
  //     bool isConnected = await NetworkManager.instance.isConnected();
  //     if (!isConnected) {
  //       UFullScreenLoader.stopLoading();
  //       return;
  //     }
  //     if (!reAuthFormKey.currentState!.validate()) {
  //       UFullScreenLoader.stopLoading();
  //       return;
  //     }
  //     await authRepository.reAuthenticateUserEmailandPassword(
  //       email.text.trim(),
  //       password.text.trim(),
  //     );
  //     await AuthenticationReposiotory.instance.deleteAccount();
  //     UFullScreenLoader.stopLoading();
  //     Get.offAll(()=>LoginScreen());
  //   } catch (e) {
  //     UFullScreenLoader.stopLoading();
  //     USnackBarHelpers.errorSnackBar(title: 'Failed!', message: e.toString());
  //   }
  // }

  // Future<void>reAuthenticateUser () async {
  //   try {
  //     final authRepo = AuthenticationReposiotory.instance;
  //
  //     final provider = authRepo.currentUser!
  //         .providerData
  //         .first
  //         .providerId;
  //
  //     if (provider == 'google.com') {
  //       // Google auto re-auth
  //       await authRepo.loginWithGoogle();
  //       await deleteUserAccount();
  //     } else {
  //       // Email/password → manual re-auth required
  //       Get.to(() => ReAuthenticateUserFormScreen());
  //     }
  //   } catch (e) {
  //     USnackBarHelpers.errorSnackBar(
  //       title: 'Error',
  //       message: e.toString(),
  //     );
  //   }
  // }

  Future<void> updateUserProfilePicture() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedImage =
      await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage == null) {
        USnackBarHelpers.warningSnackBar(
          title: 'Cancelled',
          message: 'No image selected',
        );
        return;
      }

      imageUploading.value = true;

      final imageFile = File(pickedImage.path);

      final imageUrl =
      await _userReposiotory.uploadProfileImage(imageFile);

      await _userReposiotory.updateSingleField({
        'profilePicture': imageUrl,
      });

      user.update((u) {
        u!.profilePicture = imageUrl;
      });

      imageUploading.value = false;

      USnackBarHelpers.successSnackBar(
        title: 'Success',
        message: 'Profile picture updated',
      );
    } on FirebaseException catch (e) {
      imageUploading.value = false;
      USnackBarHelpers.errorSnackBar(
        title: 'Upload failed',
        message: e.message ?? 'Firebase error',
      );
    } catch (e) {
      imageUploading.value = false;
      USnackBarHelpers.errorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    }
  }

}
