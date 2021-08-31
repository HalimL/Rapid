import 'package:json_annotation/json_annotation.dart';

part 'rapid_test.g.dart';

@JsonSerializable()
class RapidTest {
  String? testKitUID;
  String? userID;
  String? testKitStage;
  String? imagePath;
  String? label;
  int? barCode;
  bool? validBarCode;
  String? created;
  bool? completed;
  bool? predicting;
  int? timestamp;

  RapidTest(
      {this.testKitUID,
      this.userID,
      this.testKitStage,
      this.imagePath,
      this.label,
      this.barCode,
      this.validBarCode,
      this.created,
      this.completed,
      this.predicting,
      this.timestamp});

  factory RapidTest.fromJson(Map<String, dynamic> json) =>
      _$RapidTestFromJson(json);

  Map<String, dynamic> toJson() => _$RapidTestToJson(this);
}
