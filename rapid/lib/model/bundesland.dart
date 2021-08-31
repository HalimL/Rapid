import 'package:json_annotation/json_annotation.dart';

part 'bundesland.g.dart';

@JsonSerializable()
class Bundesland {
  String name;

  Bundesland({required this.name});

  factory Bundesland.fromJson(Map<String, dynamic> json) =>
      _$BundeslandFromJson(json);

  Map<String, dynamic> toJson() => _$BundeslandToJson(this);
}
