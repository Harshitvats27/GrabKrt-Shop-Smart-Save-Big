import 'package:e_commerce_application/common/style/padding.dart';
import 'package:e_commerce_application/common/widgets/appbar/appbar.dart';
import 'package:e_commerce_application/common/widgets/button/elevated_button.dart';
import 'package:e_commerce_application/utils/constants/sizes.dart';
import 'package:e_commerce_application/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../utils/constants/text.dart';
import '../../controllers/change_name_controller.dart';

class ChangeNameScreen extends StatelessWidget {
  const ChangeNameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangeNameController());

    return Scaffold(
      appBar: UAppBar(
        showBackArrow: true,
        title: Text(
          'Update Profile', // Title change kar diya profile ke hisaab se
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: UPadding.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update your profile details to keep your account accurate and personalised.',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: USizes.spaceBtwSections),

              Form(
                key: controller.updateUserFormKey,
                child: Column(
                  children: [
                    // 1. First Name
                    TextFormField(
                      controller: controller.firstName,
                      validator: (value) =>
                          UValidator.validateEmptyText('First name', value),
                      decoration: const InputDecoration(
                        labelText: UTexts.firstName,
                        prefixIcon: Icon(Iconsax.user),
                      ),
                    ),
                    const SizedBox(height: USizes.spaceBtwInputFields),

                    // 2. Last Name
                    TextFormField(
                      controller: controller.lastName,
                      validator: (value) =>
                          UValidator.validateEmptyText('Last name', value),
                      decoration: const InputDecoration(
                        labelText: UTexts.lastName,
                        prefixIcon: Icon(Iconsax.user),
                      ),
                    ),
                    const SizedBox(height: USizes.spaceBtwInputFields),

                    // 3. Username
                    TextFormField(
                      controller: controller.userName, // Controller me userName add karna hoga
                      validator: (value) =>
                          UValidator.validateEmptyText('Username', value),
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Iconsax.user_edit),
                      ),
                    ),
                    const SizedBox(height: USizes.spaceBtwInputFields),

                    // 4. Email
                    TextFormField(
                      controller: controller.email, // Controller me email add karna hoga
                      // Agar validateEmail function nahi hai UValidator me, toh validateEmptyText use kar lena
                      validator: (value) => UValidator.validateEmail(value),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Iconsax.direct),
                      ),
                    ),
                    const SizedBox(height: USizes.spaceBtwInputFields),

                    // 5. Phone Number
                    TextFormField(
                      controller: controller.phoneNumber, // Controller me phoneNumber add karna hoga
                      validator: (value) => UValidator.validatePhoneNumber(value),
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Iconsax.call),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: USizes.spaceBtwSections),

              // Save Button
              SizedBox(
                width: double.infinity, // Button ko poori width dene ke liye
                child: UElevatedButton(
                  onPressed: controller.updateUsername, // Controller me update function edit kar lena sab save karne ke liye
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}