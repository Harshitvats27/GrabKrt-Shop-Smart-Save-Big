
import 'package:e_commerce_application/common/widgets/button/add_to_cart_button.dart';
import 'package:e_commerce_application/common/widgets/favourite/favourite_icon.dart';
import 'package:e_commerce_application/common/widgets/text/brand_title_with_verify_icon.dart';
import 'package:e_commerce_application/common/widgets/text/product_price_text.dart';
import 'package:e_commerce_application/common/widgets/text/product_title_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../features/shop/controllers/controller/product_controller.dart';
import '../../../../features/shop/models/product_model.dart';
import '../../../../features/shop/screens/product_details/product_details.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/images.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_function.dart';
import '../../custom_shape/rounded_container.dart';
import '../../icons/circular_icon.dart';
import '../../images/rounded_image.dart';

class UProductCardHorizontal extends StatelessWidget {
  const UProductCardHorizontal({
    super.key, required this.productId,
  });
final ProductModel productId;



  @override
  Widget build(BuildContext context) {
    final dark=UHelperfunctions.isDarkTheme(context);
    final controller=ProductController.instance;;
    String? salePercentage=controller.calculateSalePercentage(productId.price, productId.salePrice);

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailsScreen(product: productId,)),
      child: Container(
        width: 310,
        padding: EdgeInsets.all(1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(USizes.productImageRadius),
          color: dark ? UColors.darkerGrey:UColors.grey,
        ),
        child: Row(
          children: [
            URoundedContainer(
              height: 120,
              padding: EdgeInsets.all(USizes.sm),
              backgroundColor: dark? UColors.dark:UColors.light,
              child: Stack(
                children: [
                  // Thumbnail

                  SizedBox(
                      width: 120,
                      height: 120,

                      child: URoundedImage(imageUrl: productId.thumbnail,isNetworkImage: true,)),

                  // Discount Tag
                  if(salePercentage!=null)
                  Positioned(
                    top: 12.0,
                    child: URoundedContainer(
                      radius: USizes.sm,
                      backgroundColor: UColors.yellow.withValues(alpha: 0.8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: USizes.sm,
                        vertical: USizes.xs,
                      ),
                      child: Text(
                        '$salePercentage%',
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge!.apply(color: UColors.black),
                      ),
                    ),
                  ),

                  // favourite button
                  Positioned(
                    right: 0,
                    top: 0,
                    child: UFavouriteIcon(productId: productId.id,),
                  ),
                ],
              ),

            ),

            SizedBox(
              width: 172.0,

              child: Padding(
                padding: const EdgeInsets.only(left: USizes.sm,top: USizes.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UProductTitleText(title: productId.title,smallSize: true,),
                      SizedBox(height: USizes.spaceBtwItems/2),
                      UBrandTitleWithVerifyIcon(title: productId.brand?.name ?? 'No Brand'),
                      SizedBox(height: USizes.spaceBtwItems/2)

                    ],
                  ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: UProductPriceText(price: controller.getProductPrices(productId),isLarge: true,)),
                        ProductAddToCartButton(product: productId),
                      ],
                    )

                  ],
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}
