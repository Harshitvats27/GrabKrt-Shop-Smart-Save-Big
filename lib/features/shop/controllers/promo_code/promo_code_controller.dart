import 'package:e_commerce_application/utils/constants/text.dart';
import 'package:get/get.dart';

import '../../../../common/data/repositories/authentication_repository.dart';
import '../../../../data/repositories/promo_code/promo_code_repository.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/helpers/pricing_calculator.dart';
import '../../../../utils/pop_ups/snackbar_helpers.dart';
import '../../models/promo_code_model.dart';
import '../cart/cart_controller.dart';

class PromoCodeController extends GetxController {
  static PromoCodeController get instance => Get.find();

  // variables
  get _repository => Get.put(PromoCodeRepository());
  RxString promoCode = ''.obs;
  RxBool isLoading = false.obs;
  Rx<PromoCodeModel> appliedPromoCode = PromoCodeModel.empty().obs;
  final cartController = Get.put(CartController());

  // functions
  void onPromoChanged(String value) {
    promoCode.value = value;
  }

  Future<void> applyPromoCode() async {
    try {
      // start loading
      isLoading.value = true;

      // check internet connection
      bool isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        USnackBarHelpers.warningSnackBar(
          title: 'No Internet Connection',
          message: 'Please check your internet connection',
        );
        return;
      }

      // get promo code details
      PromoCodeModel promoCode =
      await _repository.fetchSinglePromoCode(this.promoCode.value);

      if (promoCode.id.isEmpty) {
        USnackBarHelpers.warningSnackBar(
          title: 'Invalid Promo Code',
          message: 'Please enter a valid promo code',
        );
        return;
      }

      // check promo code duration
      DateTime now = DateTime.now();
      if (promoCode.endDate!.isBefore(now)) {
        USnackBarHelpers.warningSnackBar(
          title: 'Promo Code Expired',
          message: 'This promo code has expired',
        );
        return;
      }

      if (!promoCode.isActive) {
        USnackBarHelpers.warningSnackBar(
          title: 'Promo Code Deactivated',
          message: 'This promo code has been deactivated',
        );
        return;
      }

      // check order
      double subTotal = cartController.totalCartPrice.value;

      // 🔥 FIX 1: 'Kenya' hata kar 'India' kar diya
      double totalPrice = UPricingCalculator.calculateTotalPrice(
        subTotal,
        'India',
      );

      if (!(totalPrice >= promoCode.minOrderPrice)) {
        USnackBarHelpers.warningSnackBar(
          title: 'Minimum Order Price Not Reached',
          message: 'Minimum order amount be ${UTexts.currency}${promoCode.minOrderPrice.toStringAsFixed(0)} to apply this promo code',
        );
        return;
      }

      // check available promo codes
      if (!(promoCode.noOfPromoCodes > 0)) {
        USnackBarHelpers.warningSnackBar(
          title: 'Promo Code Expired',
          message: 'This promo code has been deactivated',
        );
        return;
      }

      List<String> userIds = promoCode.userIds ?? [];
      String currentUserId = AuthenticationReposiotory.instance.currentUser!.uid;
      if (userIds.contains(currentUserId)) {
        USnackBarHelpers.warningSnackBar(
          title: 'Already Applied',
          message: 'You Have Already Applied the Promo Code',
        );
        return;
      }

      appliedPromoCode.value = promoCode;
      cartController.updateCart();

    } catch (e) {
      USnackBarHelpers.errorSnackBar(
        title: 'Promo Code Error',
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 🔥 FIX 2: UPricingCalculator ke purane functions hatakar discount ka logic yahi likh diya
  double calculatePriceAfterDiscount(PromoCodeModel promoCode, double totalPrice) {
    if (promoCode.id.isNotEmpty) {
      if (promoCode.discountType == DiscountType.percentage) {
        // Percentage ke hisaab se discount nikalna (Total - (Total * Discount%))
        return totalPrice - (totalPrice * (promoCode.discount / 100));
      } else {
        // Flat fixed discount nikalna (Total - Discount)
        return totalPrice - promoCode.discount;
      }
    }
    return totalPrice;
  }

  // Get Discount Price
  String getDiscountPrice() {
    if (appliedPromoCode.value.id.isEmpty) return '';

    if (appliedPromoCode.value.discountType == DiscountType.percentage) {
      return '${appliedPromoCode.value.discount}%';
    } else {
      return '${UTexts.currency}${appliedPromoCode.value.discount}';
    }
  }

  Future<void> decreaseNoOfPromoCodes() async {
    try {
      if (appliedPromoCode.value.id.isEmpty) return;

      int noOfPromoCodes = appliedPromoCode.value.noOfPromoCodes - 1;

      await _repository.updateSingleField(
        appliedPromoCode.value,
        'noOfPromoCodes',
        noOfPromoCodes,
      );

    } catch (e) {
      USnackBarHelpers.errorSnackBar(
        title: 'Promo Code Error',
        message: e.toString(),
      );
    }
  }

  /// Function to add the user to applied promo code
  Future<void> addUserToPromoCode() async {
    try {
      if (appliedPromoCode.value.id.isEmpty) return;

      List<String> userIds = appliedPromoCode.value.userIds ?? [];

      userIds.add(AuthenticationReposiotory.instance.currentUser!.uid);

      await _repository.updateSingleField(
        appliedPromoCode.value,
        'userIds',
        userIds,
      );

    } catch (e) {
      USnackBarHelpers.errorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    }
  }
}