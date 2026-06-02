// To parse this JSON data, do
//
//     final addOnItemModel = addOnItemModelFromJson(jsonString);

import 'dart:convert';

AddOnItemModel addOnItemModelFromJson(String str) =>
    AddOnItemModel.fromJson(json.decode(str));

String addOnItemModelToJson(AddOnItemModel data) => json.encode(data.toJson());

class AddOnItemModel {
  bool? success;
  int? statusCode;
  String? message;
  List<AddOns>? data;

  AddOnItemModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory AddOnItemModel.fromJson(Map<String, dynamic> json) => AddOnItemModel(
        success: json["success"],
        statusCode: json["statusCode"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<AddOns>.from(json["data"]!.map((x) => AddOns.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "statusCode": statusCode,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class AddOns {
  String? itmCode;
  String? itmDesc;
  String? itmShortnm;
  String? itmTime;
  String? itmDeptptr;
  String? itmGroupptr;
  String? itmTaxptr;
  String? itmTaxinclusive;
  String? itmDrcutsmode;
  String? itmRefcutsmode;
  String? itmIsfixedrate;
  int? itmCost;
  String? itmPackage;
  int? itmSlno;
  String? itmActive;
  String? itmRemarks;
  dynamic cngdDt;
  int? itmDisper;
  String? itmDescml;
  String? itmGender;
  String? itmShortdetails;
  dynamic itmDetails;
  dynamic itmEligibility;
  dynamic itmOtherdet1;
  dynamic itmOtherdet2;
  dynamic itmOtherdet3;
  String? itmMobdesc;
  String? itmSlotdoctorptr;
  dynamic itmOtherdetail;
  dynamic itmOtherdet4;
  String? irId;
  String? irItemptr;
  String? irRatecatptr;
  int? irRate;

  AddOns({
    this.itmCode,
    this.itmDesc,
    this.itmShortnm,
    this.itmTime,
    this.itmDeptptr,
    this.itmGroupptr,
    this.itmTaxptr,
    this.itmTaxinclusive,
    this.itmDrcutsmode,
    this.itmRefcutsmode,
    this.itmIsfixedrate,
    this.itmCost,
    this.itmPackage,
    this.itmSlno,
    this.itmActive,
    this.itmRemarks,
    this.cngdDt,
    this.itmDisper,
    this.itmDescml,
    this.itmGender,
    this.itmShortdetails,
    this.itmDetails,
    this.itmEligibility,
    this.itmOtherdet1,
    this.itmOtherdet2,
    this.itmOtherdet3,
    this.itmMobdesc,
    this.itmSlotdoctorptr,
    this.itmOtherdetail,
    this.itmOtherdet4,
    this.irId,
    this.irItemptr,
    this.irRatecatptr,
    this.irRate,
  });

  factory AddOns.fromJson(Map<String, dynamic> json) => AddOns(
        itmCode: json["itm_code"],
        itmDesc: json["itm_desc"],
        itmShortnm: json["itm_shortnm"],
        itmTime: json["itm_time"],
        itmDeptptr: json["itm_deptptr"],
        itmGroupptr: json["itm_groupptr"],
        itmTaxptr: json["itm_taxptr"],
        itmTaxinclusive: json["itm_taxinclusive"],
        itmDrcutsmode: json["itm_drcutsmode"],
        itmRefcutsmode: json["itm_refcutsmode"],
        itmIsfixedrate: json["itm_isfixedrate"],
        itmCost: _parseInt(json["ir_rate"]),
        itmPackage: json["itm_package"],
        itmSlno: json["itm_slno"],
        itmActive: json["itm_active"],
        itmRemarks: json["itm_remarks"],
        cngdDt: json["cngd_dt"],
        itmDisper: json["itm_disper"],
        itmDescml: json["itm_descml"],
        itmGender: json["itm_gender"],
        itmShortdetails: json["itm_shortdetails"],
        itmDetails: json["itm_details"],
        itmEligibility: json["itm_eligibility"],
        itmOtherdet1: _parseDynamic(json["itm_otherdet1"]),
        itmOtherdet2: _parseDynamic(json["itm_otherdet2"]),
        itmOtherdet3: _parseDynamic(json["itm_otherdet3"]),
        itmMobdesc: json["itm_mobdesc"],
        itmSlotdoctorptr: json["itm_slotdoctorptr"],
        itmOtherdetail: _parseDynamic(json["itm_otherdetail"]),
        itmOtherdet4: _parseDynamic(json["itm_otherdet4"]),
        irId: json["ir_id"],
        irItemptr: json["ir_itemptr"],
        irRatecatptr: json["ir_ratecatptr"],
        irRate: _parseInt(json["ir_rate"]),
      );

  Map<String, dynamic> toJson() => {
        "itm_code": itmCode,
        "itm_desc": itmDesc,
        "itm_shortnm": itmShortnm,
        "itm_time": itmTime,
        "itm_deptptr": itmDeptptr,
        "itm_groupptr": itmGroupptr,
        "itm_taxptr": itmTaxptr,
        "itm_taxinclusive": itmTaxinclusive,
        "itm_drcutsmode": itmDrcutsmode,
        "itm_refcutsmode": itmRefcutsmode,
        "itm_isfixedrate": itmIsfixedrate,
        "itm_cost": itmCost,
        "itm_package": itmPackage,
        "itm_slno": itmSlno,
        "itm_active": itmActive,
        "itm_remarks": itmRemarks,
        "cngd_dt": cngdDt,
        "itm_disper": itmDisper,
        "itm_descml": itmDescml,
        "itm_gender": itmGender,
        "itm_shortdetails": itmShortdetails,
        "itm_details": itmDetails,
        "itm_eligibility": itmEligibility,
        "itm_otherdet1": itmOtherdet1,
        "itm_otherdet2": itmOtherdet2,
        "itm_otherdet3": itmOtherdet3,
        "itm_mobdesc": itmMobdesc,
        "itm_slotdoctorptr": itmSlotdoctorptr,
        "itm_otherdetail": itmOtherdetail,
        "itm_otherdet4": itmOtherdet4,
        "ir_id": irId,
        "ir_itemptr": irItemptr,
        "ir_ratecatptr": irRatecatptr,
        "ir_rate": irRate,
      };
      @override
bool operator ==(Object other) =>
    identical(this, other) ||
    other is AddOns && runtimeType == other.runtimeType && itmCode == other.itmCode;

@override
int get hashCode => itmCode.hashCode;
  static int _parseInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    if (value is double) {
      return value.toInt();
    }

    return 0;
  }

  static dynamic _parseDynamic(dynamic value) {
    if (value == null) return null;

    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is String) {
      final trimmed = value.trim();

      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        try {
          return jsonDecode(trimmed);
        } catch (_) {
          return value;
        }
      }

      return value;
    }

    return value;
  }
}
