// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rapid_test.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RapidTest _$RapidTestFromJson(Map<String, dynamic> json) {
  return RapidTest(
      testKitUID: json['testKitUID'] as String,
      testKitStage: json['testKitStage'] as String,
      userID: json['userID'] as String,
      imagePath: json['imagePath'] as String,
      label: json['label'] as String?,
      barCode: json['barCode'] as int?,
      validBarCode: json['validBarCode'] as bool?,
      created: json['created'] as String?,
      completed: json['completed'] as bool?,
      predicting: json['predicting'] as bool?,
      timestamp: json['timestamp'] as int);
}

Map<String, dynamic> _$RapidTestToJson(RapidTest instance) => <String, dynamic>{
      'testKitUID': instance.testKitUID,
      'testKitStage': instance.testKitStage,
      'userID': instance.userID,
      'imagePath': instance.imagePath,
      'label': instance.label,
      'barCode': instance.barCode,
      'validBarCode': instance.validBarCode,
      'created': instance.created,
      'predicting': instance.predicting,
      'timestamp': instance.timestamp,
    };
