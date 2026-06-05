import 'package:e_commerce_application/common/style/padding.dart';
import 'package:e_commerce_application/features/authentication/screens/login/widgets/login_form.dart';
import 'package:e_commerce_application/features/authentication/screens/login/widgets/login_header.dart';
import 'package:e_commerce_application/utils/constants/sizes.dart';
import 'package:e_commerce_application/utils/constants/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/button/elevated_button.dart';
import '../../../../common/widgets/button/special_buttons.dart';
import '../../../../common/widgets/login_signup/form_divider.dart';
import '../../../../utils/constants/images.dart';
import '../../../../utils/helpers/helper_function.dart';
import '../../controllers/login/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoginController());
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: UPadding.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
        
            // header
            children: [
              // header
              // title and sub title
              ULoginHeader(),
              SizedBox(height: USizes.spaceBtwSections),
        
              // form
              ULoginForm(),
              SizedBox(height: USizes.spaceBtwSections),
        
              // divider
              UFormDivider(title: UTexts.orSignInWith),
              SizedBox(height: USizes.spaceBtwSections),
        
              // fotter
              USpecialButtoms(),
            ],
          ),
        ),
      ),
    );
  }
}
