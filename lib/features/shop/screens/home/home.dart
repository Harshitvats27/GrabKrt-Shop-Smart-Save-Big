import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_commerce_application/features/shop/screens/all_products/all_products.dart';
import 'package:e_commerce_application/features/shop/screens/home/widgets/banners_dot_navigation.dart';
import 'package:e_commerce_application/features/shop/screens/home/widgets/home_app_bar.dart';
import 'package:e_commerce_application/features/shop/screens/home/widgets/home_categories.dart';
import 'package:e_commerce_application/common/widgets/custom_shape/primary_header_container.dart';
import 'package:e_commerce_application/features/shop/screens/home/widgets/promoslider.dart';
import 'package:e_commerce_application/utils/constants/images.dart';
import 'package:e_commerce_application/utils/constants/sizes.dart';
import 'package:e_commerce_application/utils/constants/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../common/layout/grid_layout.dart';
import '../../../../common/style/shadow.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/custom_shape/circular_contaner.dart';
import '../../../../common/widgets/images/rounded_image.dart';
import '../../../../common/widgets/products/cart/cart_counter_icon.dart';
import '../../../../common/widgets/products/product_cards/product_cards_vertical.dart';
import '../../../../common/widgets/text/section_heading.dart';
import '../../../../common/widgets/textfields/search_bar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/device_helpers.dart';
import '../../../../utils/helpers/helper_function.dart';
import '../../controllers/controller/product_controller.dart';
import '../../controllers/home/home_controller.dart';
import '../../models/product_model.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final productController = Get.put(ProductController());
    bool dark = UHelperfunctions.isDarkTheme(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // upper part
            Stack(
              children: [
                SizedBox(height: USizes.homePrimaryHeaderHeight + 10),
                PrimaryHeaderContainer(
                  height: USizes.homePrimaryHeaderHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UHomeAppbar(),
                      SizedBox(height: USizes.spaceBtwSections),
                      // row Categories
                      UHomeCategories(),
                    ],
                  ),
                ),

                Positioned(
                  bottom: 0,
                  left: USizes.defaultSpace,
                  right: USizes.defaultSpace,
                  child: USearchBar(),
                ),
              ],
            ),
            SizedBox(height: USizes.defaultSpace),

            // lower part

            // banners
            Padding(
              padding: const EdgeInsets.all(USizes.defaultSpace),
              child: Column(
                children: [
                  UPromoSlider(),
                  const SizedBox(height: USizes.spaceBtwSections),
                  // SectionnHeading
                  USectionHeading(
                    title: 'Popular Products',
                    onPressed: () => Get.to(() => AllProductsScreen(title: 'Popular Products',futureMethod: productController.getAllFeaturedProducts())),
                  ),
                  const SizedBox(height: USizes.spaceBtwSections),

                  // vertical product card
                  Obx(() {
                    if (productController.isLoading.value) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (productController.featuredProducts.isEmpty) {
                      return Center(child: Text('No Products Found'));
                    }
                    return UGridLayout(
                      itemBuilder: (context, index) {
                        ProductModel product= productController.featuredProducts[index];
                        return UProductcardVertical(productModel: product,);
                      },
                      itemCount: productController.featuredProducts.length,
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
