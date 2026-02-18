
import 'package:e_commerce_application/features/shop/screens/search_store/search_store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text.dart';
import '../../../utils/helpers/helper_function.dart';
import '../../style/shadow.dart';

class USearchBar extends StatelessWidget {
  const USearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool dark = UHelperfunctions.isDarkTheme(context);
    return GestureDetector(
      onTap: ()=>Get.to(()=>SearchStoreScreen()),
      child: Hero(
        tag: 'search_animation',
        child: Container(
          height: USizes.searchBarHeight,
          padding: EdgeInsets.symmetric(horizontal: USizes.md),
          decoration: BoxDecoration(
              borderRadius: BorderRadiusGeometry.circular(USizes.borderRadiusLg),
              color: dark ? UColors.dark : UColors.light,
              boxShadow:UShadow.searchBarShadow

          ),
          child: Row(
            children: [
              Icon(Iconsax.search_normal,color: UColors.darkerGrey,),
              SizedBox(width: USizes.spaceBtwItems,),
              Text(UTexts.searchBarTitle,style: Theme.of(context).textTheme.bodySmall,)
            ],
          ),
        ),
      ),
    );
  }
}
