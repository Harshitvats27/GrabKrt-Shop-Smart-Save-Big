
import 'package:flutter/material.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/products/cart/cart_counter_icon.dart';
import '../../../../../common/widgets/textfields/search_bar.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../common/widgets/custom_shape/primary_header_container.dart';
//
// class UStorePrimaryHeader extends StatelessWidget {
//   const UStorePrimaryHeader({
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         SizedBox(height: USizes.storePrimaryHeaderHeight + 10),
//         PrimaryHeaderContainer(
//           height: USizes.storePrimaryHeaderHeight,
//           child: UAppBar(
//             title: Text('Store', style: Theme.of(context).textTheme.headlineMedium!.apply(color: Colors.white),),
//             actions: [
//               UCartCounterIcon(),
//             ],
//
//           ),
//         ),
//
//         USearchBar(),
//       ],
//     );
//   }
// }
class UStorePrimaryHeader extends StatelessWidget {
  const UStorePrimaryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: USizes.storePrimaryHeaderHeight + 10, // FIXED HEIGHT
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [

          PrimaryHeaderContainer(
            height: USizes.storePrimaryHeaderHeight,
            child: UAppBar(
              title: Text(
                'Store',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .apply(color: Colors.white),
              ),
              actions: const [UCartCounterIcon()],
            ),
          ),

          // ✅ FIX
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: USearchBar(),
          ),
        ],
      ),
    );
  }
}
