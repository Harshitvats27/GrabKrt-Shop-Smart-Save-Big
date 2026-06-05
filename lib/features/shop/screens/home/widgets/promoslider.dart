import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_commerce_application/common/widgets/shimmer/shimmer_effect.dart';
import 'package:e_commerce_application/features/personalisation/controllers/banners/banner_controller.dart';
import 'package:e_commerce_application/features/shop/controllers/home/home_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../../common/widgets/images/rounded_image.dart';
import '../../../../../utils/constants/images.dart';
import '../../../../../utils/constants/sizes.dart';
import 'banners_dot_navigation.dart';

class UPromoSlider extends StatelessWidget {
  const UPromoSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final bannerController = Get.put(BannerController());
    return Obx(() {
      if (bannerController.isLoading.value) {
        return UShimmerEffect(width: double.infinity, height: 190);
      }
      if (bannerController.banners.isEmpty) {
        return const Center(child: Text('No Banners'));
      }
      return Column(
        children: [
          CarouselSlider(
            items: bannerController.banners
                .map(
                  (banner) => URoundedImage(
                    imageUrl: banner.imageUrl,
                    isNetworkImage: true,
                    onTap: (banner.phoneNumber.isNotEmpty || banner.targetScreen.isNotEmpty)
                        ? () {
                      if (banner.phoneNumber.isNotEmpty) {
                        // 1st Priority: Phone no. hai toh call lagao
                        bannerController.makePhoneCall(banner.phoneNumber);
                      } else if (banner.targetScreen.isNotEmpty) {
                        // 2nd Priority: Screen name hai toh wahan jao
                        Get.toNamed(banner.targetScreen);
                      }
                    }
                    // 🔥 Agar dono khali hain, toh onTap ko null kardo
                        : null,
                  )).toList(),
            options: CarouselOptions(
              onPageChanged: (index, reason) => bannerController.onPageChanged(index, reason), // 🔥 Match updated
              height: 180,
              enlargeCenterPage: true,
              autoPlay: true,
              viewportFraction: 1.0,
            ),
            carouselController: bannerController.carouselController,
          ),
          SizedBox(height: USizes.spaceBtwItems),
          BannersDotNavigation(),
        ],
      );
    });
  }
}
