// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FirebaseUser _$FirebaseUserFromJson(Map<String, dynamic> json) {
  return FirebaseUser(
    uid: json['uid'] as String?,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    email: json['email'] as String,
    postalCode: json['postalCode'] as String?,
    city: json['city'] as String?,
    bundesland: json['bundesland'] as String?,
    imagePath: json['imagePath'] as String?,
    testKitUID: json['testKitUID'] as String?,
    isDeutschlandUpdates: json['isDeutschlandUpdates'] as bool,
  );
}

Map<String, dynamic> _$FirebaseUserToJson(FirebaseUser instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'postalCode': instance.postalCode,
      'city': instance.city,
      'bundesland': instance.bundesland,
      'imagePath': instance.imagePath,
      'testKitUID': instance.testKitUID,
      'isDeutschlandUpdates': instance.isDeutschlandUpdates,
    };
