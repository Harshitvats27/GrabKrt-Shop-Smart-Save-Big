import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  String imageUrl;
  final String targetScreen;
  bool active;
  final String phoneNumber;

  BannerModel({
    required this.imageUrl,
    required this.targetScreen,
    required this.active,
    this.phoneNumber='',

  });

  static BannerModel empty() => BannerModel(imageUrl: '', targetScreen: '', active: false,phoneNumber: '');

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'targetScreen': targetScreen,
      'active': active,
      'phoneNumber': phoneNumber,
    };
  }

  factory BannerModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.data() != null) {
      Map<String, dynamic> data = snapshot.data()!;
      return BannerModel(
        imageUrl: data['imageUrl'] ?? '',
        targetScreen: data['targetScreen'] ?? '',
        active: data['active'] ?? false,
        phoneNumber: data['phoneNumber'] ?? '',

        // 🔥 Fixed: Boolean check
      );
    } else {
      return BannerModel.empty();
    }
  }
}