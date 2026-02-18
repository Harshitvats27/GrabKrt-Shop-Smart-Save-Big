import 'package:e_commerce_application/features/shop/models/product_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../../common/style/padding.dart';
import '../../../../../common/widgets/custom_shape/rounded_container.dart';
import '../../../../../common/widgets/images/circular_image.dart';
import '../../../../../common/widgets/text/brand_title_with_verify_icon.dart';
import '../../../../../common/widgets/text/product_price_text.dart';
import '../../../../../common/widgets/text/product_title_text.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/images.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text.dart';
import '../../../controllers/controller/product_controller.dart';

class UProductMetaData extends StatelessWidget {
  const UProductMetaData({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final controller = ProductController.instance;
    String? SalePercentage = controller.calculateSalePercentage(
      product.price,
      product.salePrice,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [

            if (SalePercentage != null)...[
              URoundedContainer(
                radius: USizes.sm,
                backgroundColor: UColors.yellow.withValues(alpha: 0.8),
                padding: const EdgeInsets.symmetric(
                  horizontal: USizes.sm,
                  vertical: USizes.xs,
                ),
                child: Text(
                  '$SalePercentage%',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge!.apply(color: UColors.black),
                ),
              ),
              SizedBox(width: USizes.spaceBtwItems),
            ],

            if(product.productType==ProductType.single.toString()&&product.salePrice>0)...[Text(
              '${UTexts.currency}${product.price.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleSmall!.apply(
                decoration: TextDecoration.lineThrough,
              ),
            ),
              SizedBox(width: USizes.spaceBtwItems),],
            Obx(() {
              final v = controller.selectedVariation.value;

              print("UI Rebuild - Selected Variation: $v");

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text("Selected: ${v?.price ?? "NONE"}"),

                  UProductPriceText(
                    price: controller.getProductPrices(product),
                    isLarge: true,
                  ),
                ],
              );
            }),Spacer(),
            // shgare button
            IconButton(onPressed: () {}, icon: Icon(Icons.share)),
          ],
        ),
        SizedBox(height: USizes.spaceBtwItems / 1.5),

        // product title
        UProductTitleText(title: product.title),
        SizedBox(height: USizes.spaceBtwItems / 1.5),
        Row(
          children: [
            UProductTitleText(title: 'Status'),
            SizedBox(width: USizes.spaceBtwItems),
            Text(controller.getProductStockStatus(product.stock), style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        SizedBox(height: USizes.spaceBtwItems / 1.5),

        Row(
          children: [
            UCircularImage(padding: 0,
                isNetworkImage: true,
                image: product.brand!=null?product.brand!.image:'', height: 32.0),
            SizedBox(width: USizes.spaceBtwItems),
            UBrandTitleWithVerifyIcon(title: product.brand!=null?product.brand!.name:''),
          ],
        ),
      ],
    );
  }
}
