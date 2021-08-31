import 'package:json_annotation/json_annotation.dart';

part 'firebase_user.g.dart';

@JsonSerializable()
class FirebaseUser {
  String? uid;
  String firstName;
  String lastName;
  String email;
  String? postalCode;
  String? city;
  String? bundesland;
  String? imagePath;
  String? testKitUID;
  bool isDeutschlandUpdates;

  FirebaseUser({
    this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.postalCode,
    this.city,
    this.bundesland,
    this.imagePath,
    this.testKitUID,
    required this.isDeutschlandUpdates,
  });

  factory FirebaseUser.fromJson(Map<String, dynamic> json) =>
      _$FirebaseUserFromJson(json);

  Map<String, dynamic> toJson() => _$FirebaseUserToJson(this);
}
