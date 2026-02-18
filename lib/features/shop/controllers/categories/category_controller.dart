import 'package:e_commerce_application/data/repositories/product_repository.dart';
import 'package:e_commerce_application/utils/pop_ups/snackbar_helpers.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../../data/repositories/category/category_repository.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();
  final _repository = Get.put(CategoryRepository());
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  RxList<CategoryModel> featuredCategories = <CategoryModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  // Future<void> fetchCategories() async {
  //   try {
  //     isLoading.value = true;
  //     final data = await CategoryRepository.instance.fetchCategories();
  //     categories.assignAll(data);
  //   } catch (e) {
  //     // optional snackbar
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      List<CategoryModel> data = await CategoryRepository.instance
          .fetchCategories();
      categories.assignAll(data);
      featuredCategories.assignAll(
        data.where(
          (element) => element.isFeatured == true && element.parentId.isEmpty,
        ),
      );
    } catch (e) {
      print("🔥 ASLI ERROR YAHAN HAI: $e");
      USnackBarHelpers.errorSnackBar(title: 'Error', message: e.toString());
    }finally {isLoading.value = false;}
  }

  Future<List<ProductModel>> getCategoryProducts({required String categoryId,int limit=4}) async {

    try{
      final products =ProductRepository.instance.getProductsForCategory(categoryId: categoryId,limit: limit);
      return products;
    }catch(e){
      USnackBarHelpers.errorSnackBar(title: 'Error', message: e.toString());
      return [];
    }

  }


  Future<List<CategoryModel>> getSubCategories(String categoryId)async{


    try{
      final subCategories =await _repository.getSubCategories(categoryId);
      return subCategories;
    }catch(e){
      USnackBarHelpers.errorSnackBar(title: 'Error', message: e.toString());
      return [];
    }
  }


}
