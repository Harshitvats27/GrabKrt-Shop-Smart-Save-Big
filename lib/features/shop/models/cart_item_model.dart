class CartItemModel {
  String productId;
  String title;
  double price;
  String? image;
  int quantity;
  String variationId;
  String? brandName;
  String? vendorId; // 🔥 Ye raha tera multi-vendor master key
  Map<String, dynamic>? selectedVariation;

  CartItemModel({
    required this.productId,
    required this.quantity,
    this.variationId = '',
    this.image,
    this.price = 0.0,
    this.title = '',
    this.brandName,
    this.vendorId,
    this.selectedVariation,
  });

  /// Empty Cart
  static CartItemModel empty() => CartItemModel(productId: '', quantity: 0);

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'image': image,
      'quantity': quantity,
      'variationId': variationId,
      'brandName': brandName,
      'selectedVariation': selectedVariation,
      'uploadedBy': vendorId, // 🚀 Firebase mein 'uploadedBy' banke save hoga
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId'] ?? '',
      title: json['title'] ?? '',
      price: double.parse((json['price'] ?? 0.0).toString()), // Safe parsing
      image: json['image'],
      quantity: json['quantity'] ?? 0,
      variationId: json['variationId'] ?? '',
      brandName: json['brandName'],
      vendorId: json['uploadedBy'], // 🚀 Firebase se 'uploadedBy' read hoke vendorId banega
      selectedVariation: json['selectedVariation'] != null
          ? Map<String, dynamic>.from(json['selectedVariation'])
          : null,
    );
  }
}