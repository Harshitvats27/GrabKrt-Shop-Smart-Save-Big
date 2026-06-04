import 'package:e_commerce_application/features/shop/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/style/padding.dart';
import '../../../../../common/widgets/custom_shape/rounded_container.dart';
import '../../../../../common/widgets/images/circular_image.dart';
import '../../../../../common/widgets/text/brand_title_with_verify_icon.dart';
import '../../../../../common/widgets/text/product_price_text.dart';
import '../../../../../common/widgets/text/product_title_text.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text.dart';
import '../../../controllers/controller/product_controller.dart';
// 🔥 NAYA IMPORT: Yahan tera VariationController import karna zaroori hai
import '../../../controllers/controller/variation_controller.dart';

class UProductMetaData extends StatelessWidget {
  const UProductMetaData({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final productController = ProductController.instance;
    // 🔥 BRIDGE: Ab hum VariationController ko bhi is screen par le aaye hain
    final variationController = Get.put(VariationController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔥 ROW 1: Price & Sale Tag
        Obx(() {
          // Ab hum Data VariationController se le rahe hain!
          final variation = variationController.selectedVariation.value;

          // Check karo ki koi variation actually select hui hai ya nahi
          bool isVariationSelected = variation.id.isNotEmpty;

          // Base price aur Sale price set karo
          double originalPrice = isVariationSelected ? variation.price : product.price;
          double salePrice = isVariationSelected ? variation.salePrice : (product.salePrice ?? 0.0);

          // Calculate Sale Percentage dynamically
          String? salePercentage = productController.calculateSalePercentage(originalPrice, salePrice);

          return Row(
            children: [
              // 1. Sale Percentage Tag
              if (salePercentage != null) ...[
                URoundedContainer(
                  radius: USizes.sm,
                  backgroundColor: UColors.yellow.withValues(alpha: 0.8),
                  padding: const EdgeInsets.symmetric(horizontal: USizes.sm, vertical: USizes.xs),
                  child: Text(
                    '$salePercentage%',
                    style: Theme.of(context).textTheme.labelLarge!.apply(color: UColors.black),
                  ),
                ),
                const SizedBox(width: USizes.spaceBtwItems),
              ],

              // 2. Crossed out Original Price
              if (salePrice > 0) ...[
                Text(
                  '${UTexts.currency}${originalPrice.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleSmall!.apply(
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: USizes.spaceBtwItems),
              ],

              // 3. Final Current Price
              UProductPriceText(
                // 🔥 Agar variation selected hai to uska price dikhao, warna product ka default price
                price: isVariationSelected
                    ? variationController.getVariationPrice()
                    : productController.getProductPrices(product),
                isLarge: true,
              ),

              const Spacer(),
            ],
          );
        }),

        const SizedBox(height: USizes.spaceBtwItems / 1.5),

        // ROW 2: Product title
        UProductTitleText(title: product.title),
        const SizedBox(height: USizes.spaceBtwItems / 1.5),

        // ROW 3: Stock Status
        Row(
          children: [
            const UProductTitleText(title: 'Status'),
            const SizedBox(width: USizes.spaceBtwItems),
            Obx(() {
              final variation = variationController.selectedVariation.value;
              bool isVariationSelected = variation.id.isNotEmpty;

              // 🔥 Agar variation selected hai toh VariationController ka status lo, nahi to ProductController ka
              String stockStatus = isVariationSelected
                  ? variationController.variationStockStatus.value
                  : productController.getProductStockStatus(product.stock);

              return Text(
                  stockStatus,
                  style: Theme.of(context).textTheme.titleMedium
              );
            }),
          ],
        ),
        const SizedBox(height: USizes.spaceBtwItems / 1.5),

        // ROW 4: Brand
        Row(
          children: [
            UCircularImage(
                padding: 0,
                isNetworkImage: true,
                image: product.brand != null ? product.brand!.image : '',
                height: 32.0
            ),
            const SizedBox(width: USizes.spaceBtwItems),
            UBrandTitleWithVerifyIcon(title: product.brand != null ? product.brand!.name : ''),
          ],
        ),
      ],
    );
  }
}