
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../common/widgets/text/section_heading.dart';
import '../../../../utils/constants/images.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../models/payment_mehod_model.dart';
import '../../screens/personalisation/screens/checkout/widgets/payment_tile.dart';
import '../order/order_controller.dart';

class CheckoutController extends GetxController {
  static CheckoutController get instance => Get.find();

  Rx<PaymentMethodModel> selectedPaymentMethod = PaymentMethodModel.empty().obs;

  late Razorpay _razorpay;

  @override
  void onInit() {
    super.onInit();

    // Default payment method
    selectedPaymentMethod.value = PaymentMethodModel(
      name: 'Cash on Delivery',
      image: UImages.codIcon,
      paymentMethod: PaymentMethods.cashOnDelivery,
    );

    // Initialize Razorpay
    _razorpay = Razorpay();

    // Register listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  // 👇 THIS WAS MISSING
  void openRazorpay(double amount) {
    var options = {
      'key': 'rzp_test_SHIEAnUdXRpsNx', // 🔥 Put your test key here
      'amount': (amount * 100).toInt(),
      'name': 'E Commerce App',
      'description': 'Order Payment',
      'prefill': {'contact': '9999999999', 'email': 'test@gmail.com'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void handleCheckout(double totalAmount) {
    if (selectedPaymentMethod.value.name == "Cash on Delivery") {
      OrderController.instance.processOrder(totalAmount);
    } else {
      openRazorpay(totalAmount);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    await OrderController.instance.processOrderFromRazorpay(
      response.paymentId ?? '',
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar("Payment Failed", response.message ?? "Error");
  }

  Future<void> selectPaymentMethod(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(USizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              USectionHeading(
                title: 'Select Payment Method',
                showActionButtton: false,
              ),
              SizedBox(height: USizes.spaceBtwSections),
              UPaymentTile(
                paymentMethod: PaymentMethodModel(
                  name: 'Cash on Delivery',
                  image: UImages.codIcon,
                  paymentMethod: PaymentMethods.cashOnDelivery,
                ),
              ),
              SizedBox(height: USizes.spaceBtwItems / 2),
              UPaymentTile(
                paymentMethod: PaymentMethodModel(
                  name: 'Paypal',
                  image: UImages.paypal,
                  paymentMethod: PaymentMethods.paypal,
                ),
              ),
              SizedBox(height: USizes.spaceBtwItems / 2),
              UPaymentTile(
                paymentMethod: PaymentMethodModel(
                  name: 'Credit Card',
                  image: UImages.creditCard,
                  paymentMethod: PaymentMethods.creditCard,
                ),
              ),
              SizedBox(height: USizes.spaceBtwItems / 2),
              UPaymentTile(
                paymentMethod: PaymentMethodModel(
                  name: 'Master Card',
                  image: UImages.masterCard,
                  paymentMethod: PaymentMethods.masterCard,
                ),
              ),
              SizedBox(height: USizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}
