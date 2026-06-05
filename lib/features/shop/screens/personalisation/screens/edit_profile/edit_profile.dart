import 'package:e_commerce_application/common/widgets/text/section_heading.dart';
import 'package:e_commerce_application/features/shop/screens/personalisation/screens/change_name/change_name.dart';
import 'package:e_commerce_application/features/shop/screens/personalisation/screens/edit_profile/user_profile_with_edit_icon.dart';
import 'package:e_commerce_application/utils/constants/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../common/style/padding.dart';
import '../../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../../common/widgets/icons/circular_icon.dart';
import '../../../../../../common/widgets/images/user_profile_logo.dart';
import '../../../../../personalisation/controllers/user_controller.dart';

class EditProfileScree extends StatelessWidget {
  const EditProfileScree({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    return Scaffold(
      appBar: UAppBar(
        showBackArrow: true,
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Obx(
        ()=> SingleChildScrollView(
          child: Padding(
            padding: UPadding.screenPadding,
            child: Column(
              children: [
                UserProfileWithEditIcon(),
                SizedBox(height: USizes.spaceBtwSections),
                Divider(),
                SizedBox(height: USizes.spaceBtwItems),

                // account setting Heading
                USectionHeading(
                  title: 'Account Settings',
                  showActionButtton: false,
                ),
                SizedBox(height: USizes.spaceBtwItems),
                // account details
                UserDetailRow(title: 'Name', value: controller.user.value.fullName, onTap: ()=>Get.to(()=>ChangeNameScreen())),
                UserDetailRow(
                  title: 'Username',
                  value: controller.user.value.username,
                    onTap: ()=>Get.to(()=>ChangeNameScreen())
                ),
                SizedBox(height: USizes.spaceBtwItems),

                Divider(),
                SizedBox(height: USizes.spaceBtwItems),

                // profile Section Heading
                USectionHeading(title: 'Profile', showActionButtton: false),

                SizedBox(height: USizes.spaceBtwItems),

                // profile settings
                UserDetailRow(title: 'User ID', value: controller.user.value.id, onTap: () {}),
                UserDetailRow(
                  title: 'Email',
                  value: controller.user.value.email,
                    onTap: ()=>Get.to(()=>ChangeNameScreen())
                ),
                UserDetailRow(
                  title: 'Phone Number',
                  value: '+91${controller.user.value.phoneNumber}',
                    onTap: ()=>Get.to(()=>ChangeNameScreen())
                ),
                // UserDetailRow(title: 'Gender', value: 'Male', onTap: () {}),
                // SizedBox(height: USizes.spaceBtwItems),
                Divider(),
                SizedBox(height: USizes.spaceBtwItems),

                TextButton(
                  onPressed: controller.deleteAccountMarginPopup,
                  child: Text(
                    'Close Account',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserDetailRow extends StatelessWidget {
  const UserDetailRow({
    super.key,
    required this.title,
    required this.value,
    this.icon = Iconsax.arrow_right_34,
    required this.onTap,
  });

  final String title, value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: USizes.spaceBtwItems / 1.5,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(flex: 1, child: Icon(icon, size: USizes.iconSm)),
          ],
        ),
      ),
    );
  }
}
