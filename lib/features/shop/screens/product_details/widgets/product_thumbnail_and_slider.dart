import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_application/common/widgets/shimmer/shimmer_effect.dart';
import 'package:e_commerce_application/features/shop/models/product_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/favourite/favourite_icon.dart';
import '../../../../../common/widgets/icons/circular_icon.dart';
import '../../../../../common/widgets/images/rounded_image.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/images.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_function.dart';
import '../../../controllers/controller/image_controller.dart';

class UProductThumbnailandSlider extends StatelessWidget {
  const UProductThumbnailandSlider({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final dark = UHelperfunctions.isDarkTheme(context);
    final controller = Get.put(ImageController());
    List<String> images = controller.getAllProductsImages(product);

    return Container(
      color: dark ? UColors.darkGrey : UColors.light,
      child: Stack(
        children: [
          // Image Thumbnail
          SizedBox(
            height: 400,
            child: Padding(
              padding: const EdgeInsets.all(USizes.productImageRadius * 2),
              child: Center(
                child: Obx(() {
                  final image = controller.selectedProductImage.value;
                  return GestureDetector(
                    onTap: () => controller.showEnlargedImage(image),
                    child: CachedNetworkImage(
                      imageUrl: image,
                      progressIndicatorBuilder: (context, url, progress) =>
                          CircularProgressIndicator(
                            color: UColors.primary,
                            value: progress.progress,
                          ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // image with slider
          Positioned(
            left: USizes.defaultSpace,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: 80,
              child: ListView.separated(
                separatorBuilder: (context, index) =>
                    const SizedBox(width: USizes.spaceBtwItems),
                itemCount: images.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => Obx(

                  (){
                    bool isImageSelected =
                    controller.selectedProductImage.value == images[index];
                    return URoundedImage(
                      width: 80,
                      backgroundColor: dark ? UColors.dark : Colors.white,
                      padding: const EdgeInsets.all(USizes.sm),
                      border: Border.all(color: isImageSelected?UColors.primary:Colors.transparent),
                      fit: BoxFit.contain,
                      isNetworkImage: true,

                      imageUrl: images[index],
                      onTap: () =>
                      controller.selectedProductImage.value = images[index],
                    );
                  }
                ),
              ),
            ),
          ),

          // app bar back arrow and favourite button
          UAppBar(
            showBackArrow: true,
            actions: [UFavouriteIcon(productId: product.id,)],
          ),
        ],
      ),
    );
  }
}
