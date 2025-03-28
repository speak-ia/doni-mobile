import 'package:latlong2/latlong.dart';

class UserModel {
  final String uid; 
  final String fullname;
  final String email;
  final String phone;
  final String? photoUrl;
  final LatLng? location;

  UserModel({
    required this.uid,
    required this.fullname,
    required this.email,
    required this.phone,
    this.photoUrl,
    this.location,
  });

  factory UserModel.fromDocument(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId, 
      fullname: data['fullname'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      photoUrl: data['photoUrl'],
      location: data['location'] != null
          ? LatLng(
              data['location']['latitude'],
              data['location']['longitude'],
            )
          : null,
    );
  }
}