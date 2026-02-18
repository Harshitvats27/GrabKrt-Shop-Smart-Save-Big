import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String id;
  String name;
  String image;
  String parentId;
  bool isFeatured;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    this.parentId = '',
    this.isFeatured = false,
  });

  static CategoryModel empty() =>
      CategoryModel(id: '', name: '', image: '', isFeatured: false);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'parentId': parentId,
      'isFeatured': isFeatured,
    };
  }

  // map json oriented document snapshot from firebase to user model
  factory CategoryModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data == null) return CategoryModel.empty();

    return CategoryModel(
      id: document.id,
      name: data['name']?.toString() ?? '',
      image: data['image'] ?? '',
      // Force convert whatever is in parentId to a String, fallback to empty string
      parentId: (data['parentId'] == null) ? '' : data['parentId'].toString(),
      isFeatured: data['isFeatured'] ?? false,
    );
  }
}
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class CategoryModel {
//   final String id;
//   final String name;
//   final String image;
//   final String parentId;
//   final bool isFeatured;
//
//   CategoryModel({
//     required this.id,
//     required this.name,
//     required this.image,
//     required this.parentId,
//     required this.isFeatured,
//   });
//
//   factory CategoryModel.empty() => CategoryModel(
//     id: '',
//     name: '',
//     image: '',
//     parentId: '',
//     isFeatured: false,
//   );
//
//   factory CategoryModel.fromSnapshot(
//       DocumentSnapshot<Map<String, dynamic>> doc) {
//     final data = doc.data();
//
//     if (data == null) return CategoryModel.empty();
//
//     return CategoryModel(
//       id: doc.id,
//       name: data['name']?.toString() ?? '',
//       image: data['image']?.toString() ?? '',
//       parentId: data['parentId']?.toString() ?? '',
//       isFeatured: data['isFeatured'] == true,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'name': name,
//     'image': image,
//     'parentId': parentId,
//     'isFeatured': isFeatured,
//   };
// }
