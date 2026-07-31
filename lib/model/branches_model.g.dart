// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branches_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BranchesModel _$BranchesModelFromJson(Map<String, dynamic> json) =>
    BranchesModel(
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      success: json['success'] as bool?,
      result: (json['result'] as List<dynamic>?)
          ?.map((e) => BranchResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BranchesModelToJson(BranchesModel instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'message': instance.message,
      'success': instance.success,
      'result': instance.result,
    };

BranchResult _$BranchResultFromJson(Map<String, dynamic> json) => BranchResult(
      code: json['code'] as String?,
      description: json['description'] as String?,
      addressptr: json['addressptr'] as String?,
      firmptr: json['firm_ptr'] as dynamic,
      active: json['active'] as String?,
      issync: json['issync'],
      dt: json['dt'],
      otherdet1: json['otherdet1'] as String?,
    );

Map<String, dynamic> _$BranchResultToJson(BranchResult instance) =>
    <String, dynamic>{
      'code': instance.code,
      'description': instance.description,
      'addressptr': instance.addressptr,
      'firm_ptr': instance.firmptr,
      'active': instance.active,
      'issync': instance.issync,
      'dt': instance.dt,
      'otherdet1': instance.otherdet1,
    };
