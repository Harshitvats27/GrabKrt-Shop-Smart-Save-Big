import 'package:e_commerce_application/common/widgets/custom_shape/rounded_container.dart';
import 'package:e_commerce_application/common/widgets/text/product_price_text.dart';
import 'package:e_commerce_application/common/widgets/text/product_title_text.dart';
import 'package:e_commerce_application/common/widgets/text/section_heading.dart';
import 'package:e_commerce_application/features/shop/models/product_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../../common/widgets/chips/choice_chip.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text.dart';
import '../../../../../utils/helpers/helper_function.dart';
import '../../../controllers/controller/variation_controller.dart';

class UProductAttributes extends StatelessWidget {
  const UProductAttributes({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final dark = UHelperfunctions.isDarkTheme(context);
    final controller = Get.put(VariationController());

    return Obx(
          () =>
          Column(
            children: [
              // 1. Selected Variation Price & Description Frame
              if (controller.selectedVariation.value.id.isNotEmpty)
                URoundedContainer(
                  padding: const EdgeInsets.all(USizes.sm),
                  backgroundColor: dark ? UColors.darkGrey : UColors.grey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const USectionHeading(
                              title: 'Variations', showActionButtton: false),
                          const SizedBox(width: USizes.spaceBtwItems),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const UProductTitleText(
                                      title: 'Price: ', smallSize: true),
                                  if (controller.selectedVariation.value
                                      .salePrice > 0)
                                    Text(
                                      '${UTexts.currency}${controller
                                          .selectedVariation.value.price}',
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .titleSmall!
                                          .apply(decoration: TextDecoration
                                          .lineThrough),
                                    ),
                                  const SizedBox(width: USizes.spaceBtwItems),
                                  UProductPriceText(
                                      price: controller.getVariationPrice()),
                                ],
                              ),
                              Row(
                                children: [
                                  const UProductTitleText(
                                      title: 'Stock: ', smallSize: true),
                                  Text(
                                    controller.variationStockStatus.value,
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Variation Description
                      UProductTitleText(
                        title: controller.selectedVariation.value.description ??
                            '',
                        smallSize: true,
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: USizes.spaceBtwItems),

              // 2. Attributes (Colors, Sizes, etc.)
              // We use ?? [] to ensure that if productAttributes is null, it doesn't crash
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (product.productAttributes ?? []).map((attribute) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      USectionHeading(title: attribute.name ?? '',
                          showActionButtton: false),
                      const SizedBox(height: USizes.spaceBtwItems / 2),
                      Wrap(
                        spacing: 8,
                        children: (attribute.values ?? []).map((
                            attributeValue) {
                          final isSelected = controller
                              .selectedAttribute[attribute.name] ==
                              attributeValue;

                          // Check if this specific value is available in any variation
                          final available = controller
                              .getAttributesAvailabilityInVariation(
                              product.productVariations ?? [],
                              attribute.name ?? '')
                              .contains(attributeValue);

                          return UChoiceChip(
                            text: attributeValue,
                            selected: isSelected,
                            onSelected: available
                                ? (selected) {
                              if (selected) {
                                controller.onAttributeSelected(
                                    product, attribute.name ?? '',
                                    attributeValue);
                              }
                            }
                                : null,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: USizes.spaceBtwItems),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
    );
  }
}