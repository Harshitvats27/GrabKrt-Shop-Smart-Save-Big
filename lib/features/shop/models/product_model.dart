import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_application/features/shop/models/product_attribute_model.dart';
import 'package:e_commerce_application/features/shop/models/product_variation_model.dart';

import 'brand_model.dart';

class ProductModel {
  String id;
  int stock;
  String? sku;
  double price;
  String title;
  DateTime? date;
  double salePrice;
  String thumbnail;
  bool? isFeatured;
  BrandModel? brand;
  String? description;
  String? categoryId;
  List<String>? images;
  String productType;
  List<ProductAttributeModel>? productAttributes;
  List<ProductVariationModel>? productVariations;

  ProductModel({required this.id,
    required this.title,
    required this.stock,
    required this.price,
    required this.thumbnail,
    required this.productType,
    this.sku,
    this.brand,
    this.date,
    this.images,
    this.salePrice = 0.0,
    this.isFeatured,
    this.productVariations,
    this.description,
    this.productAttributes,
    this.categoryId});

  static ProductModel empty() =>
      ProductModel(id: '',
          title: '',
          stock: 0,
          price: 0,
          thumbnail: '',
          productType: '');

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'title': title,
      'stock': stock,
      'price': price,
      'images': images ?? [],
      'thumbnail': thumbnail,
      'salePrice': salePrice,
      'isFeatured': isFeatured,
      'categoryId': categoryId,
      'brand': brand?.toJson(),
      'description': description,
      'productType': productType,
      'productAttributes': productAttributes != null ? productAttributes!.map((
          e) => e.toJson()).toList() : [],
      'productVariations': productVariations != null ? productVariations!.map((
          e) => e.toJson()).toList() : [],
      'date': date
    };
  }

  // factory ProductModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
  //   // if (document.data()!.isEmpty && document.data() == null) return ProductModel.empty();
  //   if (document.data() == null) return ProductModel.empty();
  //
  //
  //   final data = document.data()!;
  //   return ProductModel(
  //       id: document.id,
  //       title: data['title'] ?? '',
  //       stock: data['stock'] ?? 0,
  //       price: double.parse((data['price'] ?? 0.0).toString()),
  //       thumbnail: data['thumbnail'] ?? '',
  //       productType: data['productType'] ?? '',
  //       sku: data['sku'] ?? '',
  //       salePrice: double.parse((data['salePrice'] ?? 0.0).toString()),
  //       isFeatured: data['isFeatured'] ?? false,
  //       brand: BrandModel.fromJson(data['brand']),
  //       description: data['description'] ?? '',
  //       categoryId: data['categoryId'] ?? '',
  //       images: data['images'] != null ? List<String>.from(data['images']) : [],
  //       productAttributes:
  //       (data['productAttributes'] as List<dynamic>).map((e) => ProductAttributeModel.fromJson(e)).toList(),
  //       productVariations:
  //       (data['productVariations'] as List<dynamic>).map((e) => ProductVariationModel.fromJson(e)).toList(),
  //       date: data['date'] != null ? (data['date'] as Timestamp).toDate() : null
  //   );
  // }
  // factory ProductModel.fromSnapshot(
  //     DocumentSnapshot<Map<String, dynamic>> document) {
  //
  //   final data = document.data();
  //   if (data == null) return ProductModel.empty();
  //
  //   return ProductModel(
  //     id: document.id,
  //     title: data['title'] ?? '',
  //     stock: data['stock'] ?? 0,
  //     price: double.parse((data['price'] ?? 0).toString()),
  //     thumbnail: data['thumbnail'] ?? '',
  //     productType: data['productType'] ?? '',
  //     sku: data['sku'],
  //     salePrice: double.parse((data['salePrice'] ?? 0).toString()),
  //     isFeatured: data['isFeatured'] ?? false,
  //
  //     brand: data['brand'] is Map<String, dynamic>
  //         ? BrandModel.fromJson(data['brand'])
  //         : null,
  //
  //     description: data['description'],
  //     categoryId: data['categoryId'],
  //
  //     images: data['images'] is List
  //         ? List<String>.from(data['images'])
  //         : [],
  //
  //     productAttributes: data['productAttributes'] is List
  //         ? (data['productAttributes'] as List)
  //         .map((e) => ProductAttributeModel.fromJson(e))
  //         .toList()
  //         : [],
  //
  //     productVariations: data['productVariations'] is List
  //         ? (data['productVariations'] as List)
  //         .map((e) => ProductVariationModel.fromJson(e))
  //         .toList()
  //         : [],
  //
  //     date: data['date'] is Timestamp
  //         ? (data['date'] as Timestamp).toDate()
  //         : null,
  //   );
  // }


  //
  // factory ProductModel.fromSnapshot(
  //     DocumentSnapshot<Map<String, dynamic>> document) {
  //
  //   final data = document.data();
  //   if (data == null) return ProductModel.empty();
  //
  //   return ProductModel(
  //     id: document.id,
  //     title: data['title'] ?? '',
  //     stock: (data['stock'] ?? 0).toInt(),
  //     description: data['description'] ?? '',
  //     price: double.parse((data['price'] ?? 0).toString()),
  //     thumbnail: data['thumbnail'] ?? '',
  //     productType: data['productType'] ?? '',
  //     salePrice: double.parse((data['salePrice'] ?? 0).toString()),
  //     brand: data['brand'] is Map<String, dynamic>
  //         ? BrandModel.fromJson(data['brand'])
  //         : null,
  //     // ✅ ADD IT HERE ⬇️
  //     productVariations: data['productVariations'] is List
  //         ? (data['productVariations'] as List)
  //         .where((e) => e is Map) // ✅ invalid hata de
  //         .map((e) => ProductVariationModel.fromJson(
  //       Map<String, dynamic>.from(e),
  //     ))
  //         .toList()
  //         : [],
  //     // keep other fields as they are
  //     images: data['images'] is List
  //         ? List<String>.from(data['images'])
  //         : [],
  //
  //     isFeatured: data['isFeatured'] ?? false,
  //   );
  // }
  factory ProductModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {

    final data = document.data();
    if (data == null) return ProductModel.empty();

    return ProductModel(
      id: document.id,
      sku: data['sku'], // Ensure SKU is mapped
      title: data['title'] ?? '',
      stock: int.tryParse((data['stock'] ?? 0).toString()) ?? 0, // Safer conversion
      description: data['description'] ?? '',
      price: double.parse((data['price'] ?? 0).toString()),
      thumbnail: data['thumbnail'] ?? '',
      productType: data['productType'] ?? '',
      salePrice: double.parse((data['salePrice'] ?? 0).toString()),
      categoryId: data['categoryId'] ?? '',

      brand: data['brand'] != null
          ? BrandModel.fromJson(data['brand'])
          : null,

      // ✅ ADD ATTRIBUTES HERE (Crucial to prevent your current crash)
      productAttributes: data['productAttributes'] is List
          ? (data['productAttributes'] as List)
          .map((e) => ProductAttributeModel.fromJson(Map<String, dynamic>.from(e)))
          .toList()
          : [],

      // ✅ YOUR VARIATION LOGIC (Corrected for type safety)
      productVariations: data['productVariations'] is List
          ? (data['productVariations'] as List)
          .map((e) => ProductVariationModel.fromJson(Map<String, dynamic>.from(e)))
          .toList()
          : [],

      images: data['images'] is List ? List<String>.from(data['images']) : [],
      isFeatured: data['isFeatured'] ?? false,
    );
  }
  factory ProductModel.fromQuerySnapshot(
      QueryDocumentSnapshot<Object?> document) {
    final data = document.data() as Map<String, dynamic>;
    // ✅ DEBUG YAHAN DAAL
    print("PRODUCT ID: ${document.id}");
    print("RAW VARIATIONS: ${data['productVariations']}");
    print("TYPE: ${data['productVariations'].runtimeType}");

    return ProductModel(
      id: document.id,
      title: data['title'] ?? '',
      stock: (data['stock'] ?? 0).toInt(),
      price: double.parse((data['price'] ?? 0).toString()),
      thumbnail: (data['thumbnail'] != null && data['thumbnail'].toString().isNotEmpty)
          ? data['thumbnail']
          : 'https://via.placeholder.com/150',

      productType: data['productType'] ?? '',
      sku: data['sku'],
      salePrice: double.parse((data['salePrice'] ?? 0).toString()),
      isFeatured: data['isFeatured'] ?? false,

      brand: data['brand'] != null
          ? BrandModel.fromJson(data['brand'])
          : null,

      description: data['description'],
      categoryId: data['categoryId'],

      images: data['images'] != null
          ? List<String>.from(data['images'])
          : [],

      productAttributes: data['productAttributes'] != null
          ? (data['productAttributes'] as List<dynamic>)
          .map((e) => ProductAttributeModel.fromJson(e))
          .toList()
          : [],

      productVariations: data['productVariations'] is List
          ? (data['productVariations'] as List)
          .map((e) => ProductVariationModel.fromJson(
        Map<String, dynamic>.from(e),
      ))
          .toList()
          : [],

      date: data['date'] != null
          ? (data['date'] as Timestamp).toDate()
          : null,
    );
  }
}