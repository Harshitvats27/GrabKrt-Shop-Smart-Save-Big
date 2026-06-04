import 'package:e_commerce_application/common/data/repositories/authentication_repository.dart';
import 'package:e_commerce_application/features/shop/models/product_variation_model.dart';
import 'package:e_commerce_application/utils/constants/enums.dart';
import 'package:e_commerce_application/utils/constants/key.dart';
import 'package:e_commerce_application/utils/pop_ups/snackbar_helpers.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../models/cart_item_model.dart';
import '../../models/product_model.dart';
import '../controller/variation_controller.dart';

class CartController extends GetxController {
  static CartController get instance => Get.find();

  // variables
  // final _storage = GetStorage(
  //   AuthenticationReposiotory.instance.currentUser!.uid,
  // );
  RxInt noOfCartItems = 0.obs;
  RxDouble totalCartPrice = 0.0.obs;
  RxInt productQuantityInCart = 0.obs;
  RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final variationController = VariationController.instance;


// CartController(){
//   loadCartItems();
// }

  late GetStorage _storage;

  @override
  void onInit() {
    super.onInit();

    AuthenticationReposiotory.instance.authState.listen((user) async {
      final userId = user?.uid ?? '';

      if (userId.isNotEmpty) {
        await GetStorage.init(userId);   // 🔥 THIS WAS MISSING
        _storage = GetStorage(userId);
      } else {
        _storage = GetStorage();
      }

      loadCartItems();
    });
  }



  void loadCartItems(){
    List<dynamic>? storedCartItems = _storage.read(UKeys.cartItemsKey);
    if (storedCartItems != null) {
      cartItems.assignAll(storedCartItems.map((item) => CartItemModel.fromJson(item as Map<String, dynamic>)));
      updateCartTotals();
    }
  }


  // Add Items in the cart
  void addToCart(ProductModel product) {
    // check quantity of the product
    if (productQuantityInCart < 1) {
      USnackBarHelpers.customToast(message: 'Select Quantity');
      return;
    }
    // Check variation of the product if it is a variable product
    if (product.productType == ProductType.variable.toString() &&
        variationController.selectedVariation.value.id.isEmpty) {
      USnackBarHelpers.customToast(message: 'Select Variation');
      return;
    }
    // Out of Stock
    if (product.productType == ProductType.variable.toString()) {
      if (variationController.selectedVariation.value.stock < 1) {
        USnackBarHelpers.warningSnackBar(
          message: 'This variation is out of Stock',
          title: 'Out of Stock',
        );
        return;
      }
    } else {
      if (product.stock < 1) {
        USnackBarHelpers.warningSnackBar(
          message: 'This product is Out of Stock',
          title: 'Out of Stock',
        );
      }
    }
    CartItemModel selectedCartItem = convertToCartItem(
      product,
      productQuantityInCart.value,
    );
    // Check if already added in the cart
    int index = cartItems.indexWhere(
      (cartItem) =>
          cartItem.productId == selectedCartItem.productId &&
          selectedCartItem.variationId == cartItem.variationId,
    );
    if (index >= 0) {
      cartItems[index].quantity = selectedCartItem.quantity;
    } else {
      cartItems.add(selectedCartItem);
    }
    updateCart();
    // show success message
    USnackBarHelpers.customToast(
      message: 'Your product has been added to the cart',
    );
  }

  void addOneToCart(CartItemModel item) {
    int index = cartItems.indexWhere(
      (cartItem) =>
          item.productId == cartItem.productId &&
          item.variationId == cartItem.variationId,
    );
    if (index >= 0) {
      cartItems[index].quantity += 1;
    } else {
      cartItems.add(item);
    }
    updateCart();
  }

  // Convert the Product model to CartItemModel with given Quantity
  // Convert the Product model to CartItemModel with given Quantity
  CartItemModel convertToCartItem(ProductModel product, int quantity) {
    if (product.productType == ProductType.single.toString()) {
      variationController.resetSelectedAttributes();
    }
    ProductVariationModel variation =
        variationController.selectedVariation.value;
    bool isVariation = variation.id.isNotEmpty;
    String image = isVariation ? variation.image : product.thumbnail;
    double price = isVariation
        ? variation.salePrice > 0.0
        ? variation.salePrice
        : variation.price
        : product.salePrice > 0.0
        ? product.salePrice
        : product.price;

    print("====================================");
    print("🟢 STEP 1: Converting Product to Cart Item");
    print("🛍️ Product Name: ${product.title}");
    print("🏪 Original Vendor ID (uploadedBy): ${product.uploadedBy}");

    // 🔥 Phele variable mein store kar
    CartItemModel cartItem = CartItemModel(
      productId: product.id,
      title: product.title,
      price: price,
      image: image,
      quantity: quantity,
      variationId: variation.id,
      vendorId: product.uploadedBy,
      brandName: product.brand != null ? product.brand!.name : '',
      selectedVariation: isVariation ? variation.attributeValues : null,
    );

    // 🔥 Phir logs print kar (cartItems nahi, cartItem.toJson() likhna hai)
    print("🔵 STEP 2: Cart Item Successfully Created!");
    print("🛒 Cart Item JSON Data ready for storage:");
    print(cartItem.toJson());
    print("====================================");

    // 🔥 Sabse last mein return kar
    return cartItem;
  }
  void updateCart() {
    updateCartTotals();
    saveCartItems();
    cartItems.refresh();
  }

  void updateCartTotals() {
    double calculateTotalPrice = 0.0;
    int calculateNoOfItems = 0;
    for (final item in cartItems) {
      calculateTotalPrice += (item.price) * item.quantity.toDouble();
      calculateNoOfItems += item.quantity;
    }
    totalCartPrice.value = calculateTotalPrice;
    noOfCartItems.value = calculateNoOfItems;
  }

  // save cart items to local storage
  void saveCartItems() {
    List<Map<String, dynamic>> cartItemsList = cartItems
        .map((item) => item.toJson())
        .toList();
    _storage.write(UKeys.cartItemsKey, cartItemsList);
  }

  void removeOneFromCart(CartItemModel item) {
    int index = cartItems.indexWhere(
      (cartItem) =>
          item.productId == cartItem.productId &&
          item.variationId == cartItem.variationId,
    );
    if (index >= 0) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity -= 1;
      } else {
        cartItems[index].quantity == 1
            ? removeFromCartDialog(index)
            : cartItems.removeAt(index);
      }
    }
    updateCart();
  }

  removeFromCartDialog(int index) {
    Get.defaultDialog(
      title: 'Remove product',
      middleText: 'Are you sure you want to remove this product from cart?',
      onConfirm: () {
        cartItems.removeAt(index);
        updateCart();
        USnackBarHelpers.customToast(message: 'Product removed from cart');
        Get.back();
      },
      onCancel: () {},
    );
  }

  int getProductQuantityInCart(String productId) {
    final itemQuantity = cartItems
        .where((cartItem) => cartItem.productId == productId)
        .fold(0, (previousValue, element) => previousValue + element.quantity);
    return itemQuantity;
  }

  int getVariationQuantityInCart(String productId, String variationId) {
    CartItemModel cartItemModel = cartItems.firstWhere(
      (item) => item.productId == productId && item.variationId == variationId,
      orElse: () => CartItemModel.empty(),
    );
    return cartItemModel.quantity;
  }

  void clearCart() {
    productQuantityInCart.value = 0;
    cartItems.clear();
    updateCart();
  }

  void updateAlreadyAddedProduct(ProductModel product) {
    if (product.productType == ProductType.single.toString()) {
      productQuantityInCart.value = getProductQuantityInCart(product.id);
    } else {
      String variationId = variationController.selectedVariation.value.id;
      if (variationId.isNotEmpty) {
        productQuantityInCart.value = getVariationQuantityInCart(
          product.id,
          variationId,
        );
      } else {
        productQuantityInCart.value = 0;
      }
    }
  }
}
