// To parse this JSON data, do
//
//     final branchesModel = branchesModelFromJson(jsonString);

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'branches_model.g.dart';

BranchesModel branchesModelFromJson(String str) =>
    BranchesModel.fromJson(json.decode(str));

String branchesModelToJson(BranchesModel data) => json.encode(data.toJson());

@JsonSerializable()
class BranchesModel {
  @JsonKey(name: "statusCode")
  final int? statusCode;
  @JsonKey(name: "message")
  final String? message;
  @JsonKey(name: "success")
  final bool? success;
  @JsonKey(name: "result")
  final List<BranchResult>? result;

  BranchesModel({
    this.statusCode,
    this.message,
    this.success,
    this.result,
  });

  BranchesModel copyWith({
    int? statusCode,
    String? message,
    bool? success,
    List<BranchResult>? result,
  }) =>
      BranchesModel(
        statusCode: statusCode ?? this.statusCode,
        message: message ?? this.message,
        success: success ?? this.success,
        result: result ?? this.result,
      );

  factory BranchesModel.fromJson(Map<String, dynamic> json) =>
      _$BranchesModelFromJson(json);

  Map<String, dynamic> toJson() => _$BranchesModelToJson(this);
}

@JsonSerializable()
class BranchResult {
  @JsonKey(name: "code")
  final String? code;
  @JsonKey(name: "description")
  final String? description;
  @JsonKey(name: "addressptr")
  final String? addressptr;
  @JsonKey(name: "firmptr")
  final String? firmptr;
  @JsonKey(name: "active")
  final String? active;
  @JsonKey(name: "issync")
  final dynamic issync;
  @JsonKey(name: "dt")
  final dynamic dt;
  @JsonKey(name: "otherdet1")
  final String? otherdet1;

  BranchResult({
    this.code,
    this.description,
    this.addressptr,
    this.firmptr,
    this.active,
    this.issync,
    this.dt,
    this.otherdet1,
  });

  BranchResult copyWith({
    String? code,
    String? description,
    String? addressptr,
    String? firmptr,
    String? active,
    dynamic issync,
    dynamic dt,
    String? otherdet1,
  }) =>
      BranchResult(
        code: code ?? this.code,
        description: description ?? this.description,
        addressptr: addressptr ?? this.addressptr,
        firmptr: firmptr ?? this.firmptr,
        active: active ?? this.active,
        issync: issync ?? this.issync,
        dt: dt ?? this.dt,
        otherdet1: otherdet1 ?? this.otherdet1,
      );

  factory BranchResult.fromJson(Map<String, dynamic> json) =>
      _$BranchResultFromJson(json);

  Map<String, dynamic> toJson() => _$BranchResultToJson(this);
}
