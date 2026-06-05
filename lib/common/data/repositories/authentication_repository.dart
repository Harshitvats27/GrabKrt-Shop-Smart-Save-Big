import 'package:e_commerce_application/common/data/repositories/user/user_repository.dart';
import 'package:e_commerce_application/data/repositories/brand/brand_repository.dart';
import 'package:e_commerce_application/data/repositories/promo_code/promo_code_repository.dart';
import 'package:e_commerce_application/dummy_data.dart';
import 'package:e_commerce_application/features/authentication/screens/login/login.dart';
import 'package:e_commerce_application/features/authentication/screens/signup/verify_email.dart';
import 'package:e_commerce_application/navigation_menu.dart';
import 'package:e_commerce_application/utils/exception/format_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../features/authentication/controllers/signup/verify_email_controller.dart';
import '../../../features/authentication/screens/onboarding/onboarding.dart';
import '../../../features/shop/controllers/cart/cart_controller.dart';
import '../../../features/shop/screens/home/home.dart';
import '../../../utils/exception/firebase_auth_exception.dart';
import '../../../utils/exception/firebase_exception.dart';

class AuthenticationReposiotory extends GetxController {
  static AuthenticationReposiotory get instance => Get.find();

  Stream<User?> get authState => _auth.authStateChanges();


  final Localstorage = GetStorage();
  final _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  @override
  void onReady() {
    FlutterNativeSplash.remove();
    screenRedirect();
    // Get.put(BrandRepository());
  }

  Future<void> screenRedirect() async{
    final user = _auth.currentUser;
    if (user != null) {
      if (user.emailVerified) {
        Get.offAll(() => NavigationMenu());

        await GetStorage.init(user.uid);
      } else {
        Get.offAll(() => VerifyEmailScreen(email: user.email));
      }
    } else {
      Localstorage.writeIfNull('isFirstTime', true);
      Localstorage.read('isFirstTime') == true
          ? Get.offAll(() => const OnboardingScreen())
          : Get.offAll(() => const LoginScreen());
    }
  }

  Future<UserCredential> registerUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw UFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw UFirebaseException(e.code).message;
    } on UFormatException catch (e) {
      throw UFormatException();
    } on PlatformException catch (e) {
      throw UFormatException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<UserCredential> loginWithEmailandPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw UFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw UFirebaseException(e.code).message;
    } on UFormatException catch (e) {
      throw UFormatException();
    } on PlatformException catch (e) {
      throw UFormatException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<UserCredential> loginWithGoogle() async {
    try {
      // Show Pop up to select account
      final GoogleSignInAccount? googleAccount = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleAccount?.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth?.idToken,
        accessToken: googleAuth?.accessToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw UFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw UFirebaseException(e.code).message;
    } on UFormatException catch (e) {
      throw UFormatException();
    } on PlatformException catch (e) {
      throw UFormatException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw UFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw UFirebaseException(e.code).message;
    } on UFormatException catch (e) {
      throw UFormatException();
    } on PlatformException catch (e) {
      throw UFormatException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<void> sendPassswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw UFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw UFirebaseException(e.code).message;
    } on UFormatException catch (e) {
      throw UFormatException();
    } on PlatformException catch (e) {
      throw UFormatException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<void> reAuthenticateUserEmailandPassword(
    String email,
    password,
  ) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await currentUser!.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw UFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw UFirebaseException(e.code).message;
    } on UFormatException catch (e) {
      throw UFormatException();
    } on PlatformException catch (e) {
      throw UFormatException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Logout

  Future<void> logout() async {
    try {
      if (Get.isRegistered<CartController>()) {
        Get.delete<CartController>();
      }
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      Get.offAll(() => const LoginScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500));
    } on FirebaseAuthException catch (e) {
      throw UFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw UFirebaseException(e.code).message;
    } on UFormatException catch (e) {
      throw UFormatException();
    } on PlatformException catch (e) {
      throw UFormatException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<void> deleteAccount() async {
    try {
      final uid = currentUser!.uid;

      // 🗑 Delete profile image (safe)
      await UserRepository.instance.deleteProfileImage(uid);

      // 🗑 Delete Firestore document
      await UserRepository.instance.removeUserRecord(uid);

      // 🗑 Delete Auth user
      await currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      throw UFirebaseAuthException(e.code).message;
    } catch (e) {
      throw 'Account deletion failed';
    }
  }

  Future<void> reAuthenticateWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw 'Google sign-in cancelled';

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      await currentUser!.reauthenticateWithCredential(credential);
    } catch (e) {
      throw 'Google reauthentication failed';
    }
  }

}
