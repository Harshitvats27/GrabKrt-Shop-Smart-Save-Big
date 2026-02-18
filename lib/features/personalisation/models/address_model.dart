import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  String id;
  final String name;
  final String phoneNumber;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final DateTime? dateTime;
  bool selectedAddress;
  final double latitude;  // Added for GPS tracking [cite: 10, 36]
  final double longitude; // Added for GPS tracking [cite: 10, 36]
  final String addressType; // NEW: e.g., 'Home', 'Office', 'Other'
  AddressModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.dateTime,
    this.selectedAddress = true,
    required this.latitude,
    required this.longitude,
    required this.addressType,
  });

  /// Empty Address helper
  static AddressModel empty() => AddressModel(
    id: '',
    name: '',
    phoneNumber: '',
    street: '',
    city: '',
    state: '',
    postalCode: '',
    country: '',
    dateTime: null,
    selectedAddress: false,
    latitude: 0.0, // Fixed: must be double, not String
    longitude: 0.0, // Fixed: must be double, not String
    addressType: 'Home',
  );

  /// Convert model to JSON for Firebase [cite: 118]
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'dateTime': dateTime,
      'selectedAddress': selectedAddress,
      'latitude': latitude,
      'longitude': longitude,
      'addressType': addressType,
    };
  }

  /// Create AddressModel from Map
  factory AddressModel.fromMap(Map<String, dynamic> data) {
    return AddressModel(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      street: data['street'] as String? ?? '',
      city: data['city'] as String? ?? '',
      state: data['state'] as String? ?? '',
      postalCode: data['postalCode'] as String? ?? '',
      country: data['country'] as String? ?? '',
      selectedAddress: data['selectedAddress'] as bool? ?? false,
      dateTime: data['dateTime'] != null ? (data['dateTime'] as Timestamp).toDate() : null,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      addressType: data['addressType'] as String? ?? '',
    );
  }

  /// Create AddressModel from Firestore DocumentSnapshot [cite: 121]
  factory AddressModel.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};

    return AddressModel(
      id: snapshot.id,
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      street: data['street'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      postalCode: data['postalCode'] ?? '',
      country: data['country'] ?? '',
      selectedAddress: data['selectedAddress'] ?? false,
      dateTime: data['dateTime'] != null
          ? (data['dateTime'] as Timestamp).toDate()
          : null,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      addressType: data['addressType'] ?? 'Home',
    );
  }

  @override
  String toString() {
    return '$street, $city, $state, $postalCode, $country';
  }
}