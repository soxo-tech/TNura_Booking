import 'dart:convert';

List<PackagesListModel> packagesListModelFromJson(String str) =>
    List<PackagesListModel>.from(json.decode(str).map((x) => x));

String packagesListModelToJson(List<PackagesListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x)));

class PackagesListModel {
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
  String? itmOtherdet1;
  String? itmOtherdet2;
  String? itmOtherdet3;
  final List<Question>? questions;
  List<Map<String, dynamic>>? packageDetails;
  String? itmMobdesc;
  dynamic itmSlotdoctorptr;
  String? itmLanguageString;
  String? itmOtherdetail;
  String? irId;
  String? irItemptr;
  String? irRatecatptr;
  int? irRate;

  PackagesListModel({
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
    this.packageDetails,
    this.questions,
    this.itmMobdesc,
    this.itmSlotdoctorptr,
    this.itmLanguageString,
    this.itmOtherdetail,
    this.irId,
    this.irItemptr,
    this.irRatecatptr,
    this.irRate,
  });

  factory PackagesListModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> decodedOtherDet3 = {};
    try {
      if (json["otherDetails3"] != null &&
          json["otherDetails3"].toString().trim().isNotEmpty) {
        decodedOtherDet3 = jsonDecode(json["otherDetails3"]);
      }
    } catch (e) {
      print("Error decoding otherDetails3: $e");
      decodedOtherDet3 = {};
    }
    return PackagesListModel(
      itmCode: json["code"],
      itmDesc: json["description"],
      itmShortnm: json["shortName"],
      itmTime: json["time"],
      itmDeptptr: json["itm_deptptr"],
      itmGroupptr: json["itm_groupptr"],
      itmTaxptr: json["itm_taxptr"],
      itmTaxinclusive: json["itm_taxinclusive"],
      itmDrcutsmode: json["itm_drcutsmode"],
      itmRefcutsmode: json["itm_refcutsmode"],
      itmIsfixedrate: json["itm_isfixedrate"],
      itmCost: json["itm_cost"],
      itmPackage: json["itm_package"],
      itmSlno: json["itm_slno"],
      itmActive: json["itm_active"],
      itmRemarks: json["itm_remarks"],
      cngdDt: json["cngd_dt"],
      itmDisper: json["itm_disper"],
      itmDescml: json["itm_descml"],
      itmGender: json["gender"],
      itmShortdetails: json["shortDetails"],
      itmDetails: json["details"],
      itmEligibility: json["eligibility"],
      itmOtherdet1: json["otherDetails1"],
      itmOtherdet2: json["otherDetails2"],
      itmOtherdet3: json["otherDetails3"],
      questions: (decodedOtherDet3.containsKey("Questions") &&
              decodedOtherDet3["Questions"] is List)
          ? (decodedOtherDet3["Questions"] as List)
              .map((e) => Question.fromJson(e))
              .toList()
          : [],

      // 3. SAFE PARSING FOR PACKAGE DETAILS
      packageDetails: (decodedOtherDet3.containsKey("PackageDetails") &&
              decodedOtherDet3["PackageDetails"] is List)
          ? (decodedOtherDet3["PackageDetails"] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList()
          : [],
      itmMobdesc: json["mobileDescription"],
      itmSlotdoctorptr: json["slotDoctorPointer"],
      itmLanguageString: json["itm_language_string"],
      itmOtherdetail: json["itm_otherdetail"],
      irId: json["ir_id"],
      irItemptr: json["ir_itemptr"],
      irRatecatptr: json["ir_ratecatptr"],
      irRate: json["rate"],
    );
  }

  Map<String, dynamic> toJson() => {
        "code": itmCode,
        "description": itmDesc,
        "shortName": itmShortnm,
        "time": itmTime,
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
        "gender": itmGender,
        "shortDetails": itmShortdetails,
        "details": itmDetails,
        "eligibility": itmEligibility,
        "otherDetails1": itmOtherdet1,
        "otherDetails2": itmOtherdet2,
        "otherDetails3": itmOtherdet3,
        "mobileDescription": itmMobdesc,
        "slotDoctorPointer": itmSlotdoctorptr,
        "itm_language_string": itmLanguageString,
        "itm_otherdetail": itmOtherdetail,
        "ir_id": irId,
        "ir_itemptr": irItemptr,
        "ir_ratecatptr": irRatecatptr,
        "rate": irRate,
      };
}

class QuestionsModel {
  List<Question>? questions;

  QuestionsModel({this.questions});

  factory QuestionsModel.fromJson(Map<String, dynamic> json) {
    return QuestionsModel(
      questions: json["Questions"] != null
          ? (json["Questions"] as List<dynamic>)
              .map((e) => Question.fromJson(e))
              .toList()
          : [], // Return an empty list if null
    );
  }
}

class Question {
  String question;

  Question({required this.question});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json["question"] ?? "", // Default to empty string
    );
  }
}

class PackageDetailsModel {
  String item;
  String details;

  PackageDetailsModel({required this.item, required this.details});

  factory PackageDetailsModel.fromJson(Map<String, dynamic> json) {
    return PackageDetailsModel(
      item: json["item"] ?? "",
      details: json["Details"] ?? "",
    );
  }
}
