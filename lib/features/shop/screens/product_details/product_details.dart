import 'package:e_commerce_application/common/style/padding.dart';
import 'package:e_commerce_application/common/widgets/appbar/appbar.dart';
import 'package:e_commerce_application/common/widgets/button/elevated_button.dart';
import 'package:e_commerce_application/common/widgets/icons/circular_icon.dart';
import 'package:e_commerce_application/common/widgets/images/circular_image.dart';
import 'package:e_commerce_application/common/widgets/images/rounded_image.dart';
import 'package:e_commerce_application/common/widgets/text/brand_title_with_verify_icon.dart';
import 'package:e_commerce_application/common/widgets/text/product_price_text.dart';
import 'package:e_commerce_application/common/widgets/text/product_title_text.dart';
import 'package:e_commerce_application/common/widgets/text/section_heading.dart';
import 'package:e_commerce_application/features/shop/models/product_model.dart';
import 'package:e_commerce_application/features/shop/screens/product_details/widgets/bottom_add_to_cart.dart';
import 'package:e_commerce_application/features/shop/screens/product_details/widgets/product_attributes.dart';
import 'package:e_commerce_application/features/shop/screens/product_details/widgets/product_meta_data.dart';
import 'package:e_commerce_application/features/shop/screens/product_details/widgets/product_thumbnail_and_slider.dart';
import 'package:e_commerce_application/utils/constants/colors.dart';
import 'package:e_commerce_application/utils/constants/images.dart';
import 'package:e_commerce_application/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:readmore/readmore.dart';

import '../../../../common/widgets/custom_shape/rounded_container.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/helpers/helper_function.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.product});

  final ProductModel product;
  @override
  Widget build(BuildContext context) {
    final dark = UHelperfunctions.isDarkTheme(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // product image with slider
            UProductThumbnailandSlider(product: product,),

            // product details
            /// price title  stack and brand
            Padding(
              padding: UPadding.screenPadding,
              child: Column(
                children: [
                  UProductMetaData(product: product,),
                  // attributes
                  if(product.productType==ProductType.variable.toString())...[
                    UProductAttributes(product: product,),
                    SizedBox(height: USizes.spaceBtwSections),
                  ],



                  // checkout button
                  UElevatedButton(onPressed: () {}, child: Text('Checkout')),
                  SizedBox(height: USizes.spaceBtwSections),


                  // Description
                  const USectionHeading(title: 'Description', showActionButtton: false),
                  const SizedBox(height: USizes.spaceBtwItems),

                  ReadMoreText(
                    product.description ?? 'No description available', // Fallback text
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: ' Show More',
                    trimExpandedText: ' Less',
                    // Use Theme color instead of hardcoded black
                    style: TextStyle(
                      color: dark ? Colors.white : Colors.black,
                      fontSize: 14,
                    ),
                    moreStyle: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w800,
                        color: Colors.blue
                    ),
                    lessStyle: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w800,
                        color: Colors.blue
                    ),
                  ),
                  SizedBox(height: USizes.spaceBtwSections),



                ],
              ),
            )


          ],
        ),
      ),
      //Bottom Navigation
      bottomNavigationBar: UBottomAddtoCart(product: product,),
    );
  }
}
