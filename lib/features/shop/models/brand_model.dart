import 'package:cloud_firestore/cloud_firestore.dart';

class BrandModel{
  String id;
  String name;
  String image;
  bool? isFeatured;
  int? productsCount;


  BrandModel({
    required this.id,
    required this.image,
    required this.name,
    this.isFeatured,
    this.productsCount
  });

  /// Empty Helper Function
  static BrandModel empty() => BrandModel(id: '', image: '', name: '');

  /// Convert Model to Json/Map
  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'name': name,
      'image': image,
      'isFeatured': isFeatured,
      'productCount' : productsCount
    };
  }


  factory BrandModel.fromJson(Map<String, dynamic> document) {
    final data = document;
    if (data.isEmpty) return BrandModel.empty();
    return BrandModel(
      id: data['id']?.toString() ?? '', // Safe string
      image: data['image']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      isFeatured: data['isFeatured'] ?? false, // Default false agar null ho
      productsCount: int.tryParse((data['productCount'] ?? 0).toString()) ?? 0, // Safe int conversion
    );
  }

  factory BrandModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      Map<String, dynamic> data = document.data()!;
      return BrandModel(
        id: document.id, // Hamesha document.id use karein
        image: data['image']?.toString() ?? '',
        name: data['name']?.toString() ?? '',
        isFeatured: data['isFeatured'] ?? false,
        productsCount: int.tryParse((data['productCount'] ?? 0).toString()) ?? 0,
      );
    } else {
      return BrandModel.empty();
    }
  }
}