import 'package:e_commerce_application/utils/constants/enums.dart';
import 'package:e_commerce_application/utils/pop_ups/snackbar_helpers.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../data/repositories/product_repository.dart';
import '../../models/product_model.dart';
import '../../models/product_variation_model.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();
  Rx<ProductVariationModel?> selectedVariation = Rx<ProductVariationModel?>(null);

  RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    getFeaturedProducts();
    super.onInit();
  }

  final _productRepository = Get.put(ProductRepository());

  // Function to get only 4 featured products
  Future<void> getFeaturedProducts() async {
    try {
      // start loading
      isLoading.value = true;

      // fetch featured products
      List<ProductModel> featuredProducts = await _productRepository
          .fetchFeaturedProducts();
      this.featuredProducts.assignAll(featuredProducts);
    } catch (e) {
      USnackBarHelpers.errorSnackBar(title: 'Failed', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Function to get products
  Future<List<ProductModel>> getAllFeaturedProducts() async {
    try {


      // fetch featured products
      List<ProductModel> featuredProducts = await _productRepository
          .fetchAllFeaturedProducts();
    return featuredProducts;
    } catch (e) {
      USnackBarHelpers.errorSnackBar(title: 'Failed', message: e.toString());
      return [];
    }
  }

  // calculate Sale Precentge
  String? calculateSalePercentage(double originalPrice, double? salePrice) {
    if (salePrice == null || salePrice <= 0.0) {
      return null;
    }
    if (originalPrice <= 0.0) {
      return null;
    }
    double percentage = ((originalPrice - salePrice) / originalPrice) * 100; return '${percentage.toStringAsFixed(1)}';
  }

  // String getProductprices(ProductModel product){
  //   double smallestPrice=double.infinity;
  //   double largestPrice=0.0;
  //
  //   if(product.productType==ProductType.single.toString()){
  //     return product.salePrice>0?product.salePrice.toString():product.price.toString();
  //   }
  //   if(product.price<smallestPrice){
  //     smallestPrice=product.price;
  //   }else {
  //     for (final variation in product.productVariations!) {
  //       double variationPrice = variation.salePrice > 0
  //           ? variation.salePrice
  //           : variation.price;
  //       if (variationPrice < smallestPrice) {
  //         smallestPrice = variationPrice;
  //       }
  //       if (variationPrice > largestPrice) {
  //         largestPrice = variationPrice;
  //       }
  //     }
  //
  //     if (smallestPrice.isEqual(largestPrice)) {
  //       return largestPrice.toString();
  //     } else {
  //       return '${largestPrice.toStringAsFixed(0)} - ${smallestPrice
  //           .toStringAsFixed(0)}';
  //     }
  //   }
  //
  // }
  String getProductPrices(ProductModel product) {

    final variation = selectedVariation.value;

    // 🔥 DEBUG START
    print("========== PRICE DEBUG ==========");
    print("Product Type: ${product.productType}");
    print("Selected Variation: $variation");

    // ✅ IF VARIATION SELECTED
    if (variation != null) {
      final price = variation.salePrice > 0
          ? variation.salePrice
          : variation.price;

      print("👉 USING VARIATION PRICE: $price");
      print("================================");

      return price.toStringAsFixed(0);
    }

    // ✅ SINGLE PRODUCT
    if (product.productType == ProductType.single.toString()) {
      final price = product.salePrice > 0
          ? product.salePrice
          : product.price;

      print("👉 USING SINGLE PRODUCT PRICE: $price");
      print("================================");

      return price.toStringAsFixed(0);
    }

    // ✅ VARIABLE PRODUCT RANGE
    double smallestPrice = double.infinity;
    double largestPrice = 0.0;

    if (product.productVariations == null ||
        product.productVariations!.isEmpty) {

      print("❌ NO VARIATIONS FOUND");
      print("================================");

      return product.price.toStringAsFixed(0);
    }

    for (final v in product.productVariations!) {

      final variationPrice = v.salePrice > 0
          ? v.salePrice
          : v.price;

      print("Loop Variation Price: $variationPrice");

      if (variationPrice < smallestPrice) smallestPrice = variationPrice;
      if (variationPrice > largestPrice) largestPrice = variationPrice;
    }

    print("👉 RANGE: $smallestPrice - $largestPrice");
    print("================================");

    if (smallestPrice == largestPrice) {
      return largestPrice.toStringAsFixed(0);
    }

    return '${smallestPrice.toStringAsFixed(0)} - ${largestPrice.toStringAsFixed(0)}';
  }

  String getProductStockStatus(int stock){
    return stock>0?'In Stock':'Out of Stock';
  }

  Future<List<ProductModel>> getAllProducts()async{
    try{
      List<ProductModel> products = await _productRepository.fetchAllProducts();
      return products;
    }catch(e){
      USnackBarHelpers.errorSnackBar(title: 'Error', message: e.toString());
      return [];
    }

  }

}


