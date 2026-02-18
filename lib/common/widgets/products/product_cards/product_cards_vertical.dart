import 'package:e_commerce_application/common/widgets/custom_shape/rounded_container.dart';
import 'package:e_commerce_application/common/widgets/favourite/favourite_icon.dart';
import 'package:e_commerce_application/common/widgets/icons/circular_icon.dart';
import 'package:e_commerce_application/common/widgets/images/rounded_image.dart';
import 'package:e_commerce_application/common/widgets/text/brand_title_text.dart';
import 'package:e_commerce_application/common/widgets/text/product_price_text.dart';
import 'package:e_commerce_application/utils/constants/colors.dart';
import 'package:e_commerce_application/utils/constants/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../features/shop/controllers/controller/product_controller.dart';
import '../../../../features/shop/models/product_model.dart';
import '../../../../features/shop/screens/product_details/product_details.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_function.dart';
import '../../../style/shadow.dart';
import '../../button/add_to_cart_button.dart';
import '../../text/brand_title_with_verify_icon.dart';
import '../../text/product_title_text.dart';

class UProductcardVertical extends StatelessWidget {
  const UProductcardVertical({super.key, required this.productModel});



  final ProductModel productModel;


  @override
  Widget build(BuildContext context) {
    final dark = UHelperfunctions.isDarkTheme(context);
    final controller=ProductController.instance;;
    String? salePercentage=controller.calculateSalePercentage(productModel.price, productModel.salePrice);

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailsScreen(product: productModel,)),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          boxShadow: UShadow.verticalProductShadow,
          borderRadius: BorderRadius.circular(USizes.productImageRadius),
          color: dark ? UColors.darkGrey : UColors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // thumbnail , Favourite button and Discount Tag
            URoundedContainer(
              height: 180,
              padding: const EdgeInsets.all(USizes.sm),
              backgroundColor: dark ? UColors.dark : UColors.white,
              child: Stack(
                children: [
                  // thumbnail
                  Center(child: URoundedImage(imageUrl: productModel.thumbnail,isNetworkImage: true,)),

                  // Discount Tag
                  if(salePercentage!=null)
                    Positioned(
                      top: 12.0,
                      left: 12,
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
                    child: UFavouriteIcon(productId: productModel.id,),
                  ),
                ],
              ),
            ),
            SizedBox(height: USizes.spaceBtwItems / 2),
            // details
            Padding(
              padding: const EdgeInsets.only(left: USizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // product title
                  UProductTitleText(title: productModel.title, smallSize: true),
                  SizedBox(height: USizes.spaceBtwItems / 2),

                  // product brand
                  UBrandTitleWithVerifyIcon(title: productModel.brand?.name??'',),
                ],
              ),
            ),
            Spacer(),

            // Product Price Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Expanded use kiya taaki price range ko maximum available space mile
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: USizes.sm),
                    child: UProductPriceText(
                      // Yahan hum manual style bhej rahe hain font size chota karne ke liye
                      price: controller.getProductPrices(productModel),
                      isLarge: false, // Large ko false kar diya taaki size default chota rahe
                      lineThrough: false,
                    ),
                  ),
                ),

                // Add to cart button apni jagah fixed rahega
                ProductAddToCartButton(product: productModel),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
