import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';



import '../../features/shop/models/product_model.dart';
import '../../utils/constants/key.dart';
import '../../utils/exception/firebase_exception.dart';
import '../../utils/exception/format_exception.dart';
import '../../utils/exception/platform_exception.dart';

class ProductRepository extends GetxController {
  static ProductRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
 // final _cloudinaryServices = Get.put(CloudinaryServices());

  /// [Upload] - Function to upload list of products to Firebase
  // Future<void> uploadProducts(List<ProductModel> products) async {
  //   try {
  //     for (ProductModel product in products) {
  //       final Map<String, String> uploadedImageMap = {}; // 'assets/products/productImage4' : 'https:cloudinary'
  //
  //       // upload thumbnail to cloudinary
  //       File thumbnailFile = await UHelperFunctions.assetToFile(product.thumbnail);
  //       dio.Response response = await _cloudinaryServices.uploadImage(thumbnailFile, UKeys.productsFolder);
  //       if (response.statusCode == 200) {
  //         String url = response.data['url'];
  //         uploadedImageMap[product.thumbnail] = url;
  //         product.thumbnail = url;
  //       }
  //
  //       // upload product images
  //       if (product.images != null && product.images!.isNotEmpty) {
  //         List<String> imageUrls = [];
  //
  //         for (String image in product.images!) {
  //           // upload image to cloudinary
  //           File imageFile = await UHelperFunctions.assetToFile(image);
  //           dio.Response response = await _cloudinaryServices.uploadImage(imageFile, UKeys.productsFolder);
  //           if (response.statusCode == 200) {
  //             imageUrls.add(response.data['url']);
  //           }
  //         }
  //
  //         // upload product variation images
  //         if (product.productVariations != null && product.productVariations!.isNotEmpty) {
  //           for (int i = 0; i < product.images!.length; i++) {
  //             uploadedImageMap[product.images![i]] = imageUrls[i];
  //           }
  //
  //           for (final variation in product.productVariations!) {
  //             final match = uploadedImageMap.entries.firstWhere(
  //                   (entry) => entry.key == variation.image,
  //               orElse: () => const MapEntry('', ''),
  //             );
  //             if (match.key.isNotEmpty) {
  //               variation.image = match.value;
  //             }
  //           }
  //         }
  //
  //         product.images!.clear();
  //         product.images!.assignAll(imageUrls);
  //       }
  //
  //       // upload product to Fire store
  //       await _db.collection(UKeys.productsCollection).doc(product.id).set(product.toJson());
  //
  //       debugPrint('Product ${product.id} uploaded');
  //     }
  //   } on FirebaseException catch (e) {
  //     throw UFirebaseException(e.code).message;
  //   } on FormatException catch (_) {
  //     throw UFormatException();
  //   } on PlatformException catch (e) {
  //     throw UPlatformException(e.code).message;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  /// [Fetch] - Function to fetch list of products from Firebase
  Future<List<ProductModel>> fetchAllProducts() async {
    try {
      final query = await _db.collection(UKeys.productsCollection).get();

      if (query.docs.isNotEmpty) {
        List<ProductModel> products = query.docs.map((document) => ProductModel.fromSnapshot(document)).toList();
        return products;
      }

      return [];
    } on FirebaseException catch (e) {
      throw UFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw UFormatException();
    } on PlatformException catch (e) {
      throw UPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// [Fetch] - Function to fetch single products from Firebase
  Future<ProductModel> fetchSingleProduct(String productId) async {
    try {
      final query = await _db.collection(UKeys.productsCollection).doc(productId).get();

      if (query.id.isNotEmpty) {
        ProductModel product = ProductModel.fromSnapshot(query);
        return product;
      }

      return ProductModel.empty();
    } on FirebaseException catch (e) {
      throw UFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw UFormatException();
    } on PlatformException catch (e) {
      throw UPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// [Fetch] - Function to fetch list of products from Firebase
  Future<List<ProductModel>> fetchFeaturedProducts() async {
    try {
      final query = await _db.collection(UKeys.productsCollection).where('isFeatured', isEqualTo: true).limit(10).get();

      if (query.docs.isNotEmpty) {
        List<ProductModel> products = query.docs.map((document) => ProductModel.fromSnapshot(document)).toList();
        return products;
      }

      return [];
    } on FirebaseException catch (e) {
      throw UFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw UFormatException();
    } on PlatformException catch (e) {
      throw UPlatformException(e.code).message;
    } catch (e) {
      debugPrint('Error while getting featured products:$e');
      throw 'Something went wrong. Please try again';
    }
  }

  //
  // Future<List<ProductModel>> fetchFeaturedProducts() async {
  //   try {
  //     debugPrint('🔍 Fetching featured products...');
  //
  //     final query = await _db
  //         .collection(UKeys.productsCollection)
  //         .where('isFeatured', isEqualTo: true)
  //         .limit(4)
  //         .get();
  //
  //     debugPrint('📦 Total docs fetched: ${query.docs.length}');
  //
  //     if (query.docs.isEmpty) {
  //       debugPrint('⚠️ No featured products found');
  //       return [];
  //     }
  //
  //     for (var doc in query.docs) {
  //       debugPrint('-----------------------------');
  //       debugPrint('📄 Document ID: ${doc.id}');
  //       debugPrint('📄 Raw Data: ${doc.data()}');
  //       debugPrint('📄 Data Types:');
  //
  //       doc.data().forEach((key, value) {
  //         debugPrint('   $key → ${value.runtimeType}');
  //       });
  //     }
  //
  //     // TEMP: return empty to avoid model crash
  //     return [];
  //
  //   } on FirebaseException catch (e) {
  //     debugPrint('🔥 FirebaseException: ${e.code}');
  //     rethrow;
  //   } catch (e) {
  //     debugPrint('🔥 Unknown Error: $e');
  //     rethrow;
  //   }
  // }

  /// [Fetch] - Function to fetch all list of products from Firebase
  Future<List<ProductModel>> fetchAllFeaturedProducts() async {
    try {
      final query = await _db.collection(UKeys.productsCollection).where('isFeatured', isEqualTo: true).get();

      if (query.docs.isNotEmpty) {
        List<ProductModel> products = query.docs.map((document) => ProductModel.fromSnapshot(document)).toList();
        return products;
      }

      return [];
    } on FirebaseException catch (e) {
      throw UFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw UFormatException();
    } on PlatformException catch (e) {
      throw UPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// [Fetch] - Function to fetch all list of products from Firebase
  Future<List<ProductModel>> fetchProductsByQuery(Query query) async {
    try {
      final querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        List<ProductModel> products =
        querySnapshot.docs.map((document) => ProductModel.fromQuerySnapshot(document)).toList();
        return products;
      }

      return [];
    } on FirebaseException catch (e) {
      throw UFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw UFormatException();
    } on PlatformException catch (e) {
      throw UPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// [Fetch] - Function to fetch all list of brand specific products
  Future<List<ProductModel>> getProductsForBrand({required String brandId, int limit = -1}) async {
    try {
      final query = limit == -1
          ? await _db.collection(UKeys.productsCollection).where('brand.id', isEqualTo: brandId).get()
          : await _db.collection(UKeys.productsCollection).where('brand.id', isEqualTo: brandId).limit(limit).get();

      if (query.docs.isNotEmpty) {
        List<ProductModel> products = query.docs.map((document) => ProductModel.fromSnapshot(document)).toList();
        return products;
      }

      return [];
    } on FirebaseException catch (e) {
      throw UFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw UFormatException();
    } on PlatformException catch (e) {
      throw UPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// [Fetch] - Function to fetch all list of category specific products
  // Future<List<ProductModel>> getProductsForCategory({required String categoryId, int limit = 4}) async {
  //   try {
  //     final productCategoryQuery = limit == -1
  //         ? await _db.collection(UKeys.productCategoryCollection).where('categoryId', isEqualTo: categoryId).get()
  //         : await _db.collection(UKeys.productCategoryCollection).where('categoryId', isEqualTo: categoryId).limit(limit).get();
  //
  //     List<String> productIds = productCategoryQuery.docs.map((doc) => doc['productId'] as String).toList();
  //
  //     final productQuery = await _db.collection(UKeys.productsCollection).where(FieldPath.documentId, whereIn: productIds).get();
  //
  //     List<ProductModel> products = productQuery.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
  //
  //     return products;
  //   } on FirebaseException catch (e) {
  //     throw UFirebaseException(e.code).message;
  //   } on FormatException catch (_) {
  //     throw UFormatException();
  //   } on PlatformException catch (e) {
  //     throw UPlatformException(e.code).message;
  //   } catch (e) {
  //     throw 'Something went wrong. Please try again';
  //   }
  // }
  Future<List<ProductModel>> getProductsForCategory({required String categoryId, int limit = 4}) async {
    try {
      // 1. Fetch relations from ProductCategory collection
      final productCategoryQuery = limit == -1
          ? await _db.collection(UKeys.productCategoryCollection).where('categoryId', isEqualTo: categoryId).get()
          : await _db.collection(UKeys.productCategoryCollection).where('categoryId', isEqualTo: categoryId).limit(limit).get();

      // 2. Extract Product IDs
      List<String> productIds = productCategoryQuery.docs.map((doc) => doc['productId'] as String).toList();

      // Agar koi product nahi mila toh khali list return kardo
      if (productIds.isEmpty) return [];

      List<ProductModel> products = [];

      // 🔥 CRITICAL FIX: Firebase 'whereIn' supports max 10 items.
      // Isliye hum IDs ko 10-10 ke chunks (hisse) mein baant rahe hain.
      for (int i = 0; i < productIds.length; i += 10) {
        // 10 items ka ek tukda nikalo
        int end = (i + 10 < productIds.length) ? i + 10 : productIds.length;
        List<String> chunk = productIds.sublist(i, end);

        // Chunk wale products fetch karo
        final productQuery = await _db
            .collection(UKeys.productsCollection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        // Unko main list mein add kardo
        products.addAll(productQuery.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList());
      }

      return products;

    } on FirebaseException catch (e) {
      throw UFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw UFormatException();
    } on PlatformException catch (e) {
      throw UPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
  /// [Fetch] - Function to fetch list of favourite products from Firebase
  Future<List<ProductModel>> getFavouriteProducts(List<String> productsIds) async {
    try {
      final query = await _db.collection(UKeys.productsCollection).where(FieldPath.documentId, whereIn: productsIds).get();

      if (query.docs.isNotEmpty) {
        List<ProductModel> products = query.docs.map((document) => ProductModel.fromSnapshot(document)).toList();
        return products;
      }

      return [];
    } on FirebaseException catch (e) {
      throw UFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw UFormatException();
    } on PlatformException catch (e) {
      throw UPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

}


