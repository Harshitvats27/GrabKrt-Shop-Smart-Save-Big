import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_application/features/shop/models/banners_models.dart';
import 'package:e_commerce_application/utils/pop_ups/snackbar_helpers.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/repositories/banners/banner_repository.dart';
class BannerController extends GetxController {
  static BannerController get instance => Get.find();
  final _repository = Get.put(BannerRepository());
  RxList<BannerModel> banners = <BannerModel>[].obs;
  RxBool isLoading = false.obs;
  final CarouselSliderController carouselController = CarouselSliderController();
  RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  void onPageChanged(int index, CarouselPageChangedReason reason) {
    currentIndex.value = index;
  }

  Future<void> fetchBanners() async {
    try {
      isLoading.value = true;
      final bannersList = await _repository.fetchBanners();
      banners.assignAll(bannersList);
    } catch (e) {
      USnackBarHelpers.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      // Agar promotion ka koi number nahi hai toh simple return kardo
      return;
    }

    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        USnackBarHelpers.errorSnackBar(title: 'Oops!', message: 'Bhai, call connect nahi ho pa rahi!');
      }
    } catch (e) {
      USnackBarHelpers.errorSnackBar(title: 'Error', message: 'Something went wrong: $e');
    }
  }
}