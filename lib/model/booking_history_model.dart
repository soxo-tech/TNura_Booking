// To parse this JSON data, do
//
//     final bookinghistoryModel = bookinghistoryModelFromJson(jsonString);

import 'dart:convert';

BookinghistoryModel bookinghistoryModelFromJson(String str) =>
    BookinghistoryModel.fromJson(json.decode(str));

String bookinghistoryModelToJson(BookinghistoryModel data) =>
    json.encode(data.toJson());

class BookinghistoryModel {
  int? statusCode;
  bool? success;
  String? message;
  List<Result>? result;

  BookinghistoryModel({
    this.statusCode,
    this.success,
    this.message,
    this.result,
  });

  factory BookinghistoryModel.fromJson(Map<String, dynamic> json) =>
      BookinghistoryModel(
        statusCode: json["statusCode"],
        success: json["success"],
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(json["result"]!.map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "success": success,
        "message": message,
        "result": result == null
            ? []
            : List<dynamic>.from(result!.map((x) => x.toJson())),
      };
}

class Result {
  String? daId;
  String? daDoctorptr;
  DateTime? daDate;
  dynamic daOpno;
  String? daLname;
  String? daFname;
  dynamic daAdd1;
  dynamic daAdd2;
  dynamic daPlace;
  dynamic daPhone;
  String? daMobile;
  int? daTokenno;
  String? daAptime;
  dynamic daRemarks;
  dynamic daUserid;
  String? daUser;
  DateTime? daTime;
  String? daCanflg;
  dynamic daCanuser;
  dynamic daCanuserid;
  dynamic daCantime;
  dynamic daTitle;
  dynamic daVisitstatus;
  String? daVisitid;
  dynamic daMode;
  String? daPaystatus;
  String? daReferencetype;
  String? daReferenceid;
  String? daBkstatus;
  dynamic daBkstatususer;
  DateTime? daBkstatusdttm;
  dynamic daPackagetype;
  String? daPackagetypevalue;
  dynamic daNewopno;
  int? daBillvalue;
  dynamic daCouponvalue;
  dynamic daCouponno;
  String? daDelivarymode;
  DateTime? daDelivarydttm;
  dynamic daDelivaryaddressid;
  dynamic daZip;
  dynamic daLandmark;
  String? daQuestfilled;
  String? daConsentfilled;
  dynamic daQuestmailsendstatus;
  dynamic daConsentmailsendstatus;
  dynamic daFitkitmailsendstatus;
  dynamic daFitkitstatus;
  dynamic daBillid;
  dynamic daReportmailsendstatus;
  dynamic daPhyverified;
  dynamic daRptuploaded;
  dynamic daPhyrptstatus;
  dynamic daRptstatus;
  String? daEmail;
  String? daGender;
  dynamic daDob;
  dynamic daReportmailsenddttm;
  dynamic daCanremarks;
  dynamic daSourcetype;
  dynamic daReferrerptr;
  dynamic daFirmptr;
  dynamic daBranchptr;
  dynamic daSamplestatus;
  dynamic daCorporateptr;
  dynamic daCorporateinfo;
  String? daOtherdetails1;
  dynamic daUpdateduserid;
  dynamic daUpdatedtime;
  dynamic daConsentscannedstatus;
  dynamic daCountry;
  dynamic daReftypeptr;
  List<AddOnPackageDetails>? addOnPackageDetails;
  dynamic addOnPackageTotal;
  PackageDetails? packageDetails;
  int? age;

  Result({
    this.daId,
    this.daDoctorptr,
    this.daDate,
    this.daOpno,
    this.daLname,
    this.daFname,
    this.daAdd1,
    this.daAdd2,
    this.daPlace,
    this.daPhone,
    this.daMobile,
    this.daTokenno,
    this.daAptime,
    this.daRemarks,
    this.daUserid,
    this.daUser,
    this.daTime,
    this.daCanflg,
    this.daCanuser,
    this.daCanuserid,
    this.daCantime,
    this.daTitle,
    this.daVisitstatus,
    this.daVisitid,
    this.daMode,
    this.daPaystatus,
    this.daReferencetype,
    this.daReferenceid,
    this.daBkstatus,
    this.daBkstatususer,
    this.daBkstatusdttm,
    this.daPackagetype,
    this.daPackagetypevalue,
    this.daNewopno,
    this.daBillvalue,
    this.daCouponvalue,
    this.daCouponno,
    this.daDelivarymode,
    this.daDelivarydttm,
    this.daDelivaryaddressid,
    this.daZip,
    this.daLandmark,
    this.daQuestfilled,
    this.daConsentfilled,
    this.daQuestmailsendstatus,
    this.daConsentmailsendstatus,
    this.daFitkitmailsendstatus,
    this.daFitkitstatus,
    this.daBillid,
    this.daReportmailsendstatus,
    this.daPhyverified,
    this.daRptuploaded,
    this.daPhyrptstatus,
    this.daRptstatus,
    this.daEmail,
    this.daGender,
    this.daDob,
    this.daReportmailsenddttm,
    this.daCanremarks,
    this.daSourcetype,
    this.daReferrerptr,
    this.daFirmptr,
    this.daBranchptr,
    this.daSamplestatus,
    this.daCorporateptr,
    this.daCorporateinfo,
    this.daOtherdetails1,
    this.daUpdateduserid,
    this.daUpdatedtime,
    this.daConsentscannedstatus,
    this.daCountry,
    this.daReftypeptr,
    this.addOnPackageDetails,
    this.addOnPackageTotal,
    this.packageDetails,
    this.age,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
      daId: json["da_id"],
      daDoctorptr: json["da_doctorptr"],
      daDate: json["da_date"] == null ? null : DateTime.parse(json["da_date"]),
      daOpno: json["da_opno"],
      daLname: json["da_lname"],
      daFname: json["da_fname"],
      daAdd1: json["da_add1"],
      daAdd2: json["da_add2"],
      daPlace: json["da_place"],
      daPhone: json["da_phone"],
      daMobile: json["da_mobile"],
      daTokenno: json["da_tokenno"],
      daAptime: json["da_aptime"],
      daRemarks: json["da_remarks"],
      daUserid: json["da_userid"],
      daUser: json["da_user"],
      daTime: json["da_time"] == null ? null : DateTime.parse(json["da_time"]),
      daCanflg: json["da_canflg"],
      daCanuser: json["da_canuser"],
      daCanuserid: json["da_canuserid"],
      daCantime: json["da_cantime"],
      daTitle: json["da_title"],
      daVisitstatus: json["da_visitstatus"],
      daVisitid: json["da_visitid"],
      daMode: json["da_mode"],
      daPaystatus: json["da_paystatus"],
      daReferencetype: json["da_referencetype"],
      daReferenceid: json["da_referenceid"],
      daBkstatus: json["da_bkstatus"],
      daBkstatususer: json["da_bkstatususer"],
      daBkstatusdttm: json["da_bkstatusdttm"] == null
          ? null
          : DateTime.parse(json["da_bkstatusdttm"]),
      daPackagetype: json["da_packagetype"],
      daPackagetypevalue: json["da_packagetypevalue"],
      daNewopno: json["da_newopno"],
      daBillvalue: json["da_billvalue"],
      daCouponvalue: json["da_couponvalue"],
      daCouponno: json["da_couponno"],
      daDelivarymode: json["da_delivarymode"],
      daDelivarydttm: json["da_delivarydttm"] == null
          ? null
          : DateTime.parse(json["da_delivarydttm"]),
      daDelivaryaddressid: json["da_delivaryaddressid"],
      daZip: json["da_zip"],
      daLandmark: json["da_landmark"],
      daQuestfilled: json["da_questfilled"],
      daConsentfilled: json["da_consentfilled"],
      daQuestmailsendstatus: json["Da_questmailsendstatus"],
      daConsentmailsendstatus: json["da_consentmailsendstatus"],
      daFitkitmailsendstatus: json["da_fitkitmailsendstatus"],
      daFitkitstatus: json["da_fitkitstatus"],
      daBillid: json["da_billid"],
      daReportmailsendstatus: json["da_reportmailsendstatus"],
      daPhyverified: json["da_phyverified"],
      daRptuploaded: json["da_rptuploaded"],
      daPhyrptstatus: json["da_phyrptstatus"],
      daRptstatus: json["da_rptstatus"],
      daEmail: json["da_email"],
      daGender: json["da_gender"],
      daDob: json["da_dob"],
      daReportmailsenddttm: json["da_reportmailsenddttm"],
      daCanremarks: json["da_canremarks"],
      daSourcetype: json["da_sourcetype"],
      daReferrerptr: json["da_referrerptr"],
      daFirmptr: json["da_firmptr"],
      daBranchptr: json["da_branchptr"],
      daSamplestatus: json["da_samplestatus"],
      daCorporateptr: json["da_corporateptr"],
      daCorporateinfo: json["da_corporateinfo"],
      daOtherdetails1: json["da_otherdetails1"],
      daUpdateduserid: json["da_updateduserid"],
      daUpdatedtime: json["da_updatedtime"],
      daConsentscannedstatus: json["da_consentscannedstatus"],
      daCountry: json["da_country"],
      daReftypeptr: json["da_reftypeptr"],
      addOnPackageDetails: json["addOnPackageDetails"] == null
          ? []
          : List<AddOnPackageDetails>.from(json["addOnPackageDetails"]!
              .map((x) => AddOnPackageDetails.fromJson(x))),
      addOnPackageTotal: json["addOnPackageTotal"],
      packageDetails: json["packageDetails"] == null
          ? null
          : PackageDetails.fromJson(json["packageDetails"]),
      age: json["age"]);

  Map<String, dynamic> toJson() => {
        "da_id": daId,
        "da_doctorptr": daDoctorptr,
        "da_date": daDate?.toIso8601String(),
        "da_opno": daOpno,
        "da_lname": daLname,
        "da_fname": daFname,
        "da_add1": daAdd1,
        "da_add2": daAdd2,
        "da_place": daPlace,
        "da_phone": daPhone,
        "da_mobile": daMobile,
        "da_tokenno": daTokenno,
        "da_aptime": daAptime,
        "da_remarks": daRemarks,
        "da_userid": daUserid,
        "da_user": daUser,
        "da_time": daTime?.toIso8601String(),
        "da_canflg": daCanflg,
        "da_canuser": daCanuser,
        "da_canuserid": daCanuserid,
        "da_cantime": daCantime,
        "da_title": daTitle,
        "da_visitstatus": daVisitstatus,
        "da_visitid": daVisitid,
        "da_mode": daMode,
        "da_paystatus": daPaystatus,
        "da_referencetype": daReferencetype,
        "da_referenceid": daReferenceid,
        "da_bkstatus": daBkstatus,
        "da_bkstatususer": daBkstatususer,
        "da_bkstatusdttm": daBkstatusdttm?.toIso8601String(),
        "da_packagetype": daPackagetype,
        "da_packagetypevalue": daPackagetypevalue,
        "da_newopno": daNewopno,
        "da_billvalue": daBillvalue,
        "da_couponvalue": daCouponvalue,
        "da_couponno": daCouponno,
        "da_delivarymode": daDelivarymode,
        "da_delivarydttm": daDelivarydttm?.toIso8601String(),
        "da_delivaryaddressid": daDelivaryaddressid,
        "da_zip": daZip,
        "da_landmark": daLandmark,
        "da_questfilled": daQuestfilled,
        "da_consentfilled": daConsentfilled,
        "Da_questmailsendstatus": daQuestmailsendstatus,
        "da_consentmailsendstatus": daConsentmailsendstatus,
        "da_fitkitmailsendstatus": daFitkitmailsendstatus,
        "da_fitkitstatus": daFitkitstatus,
        "da_billid": daBillid,
        "da_reportmailsendstatus": daReportmailsendstatus,
        "da_phyverified": daPhyverified,
        "da_rptuploaded": daRptuploaded,
        "da_phyrptstatus": daPhyrptstatus,
        "da_rptstatus": daRptstatus,
        "da_email": daEmail,
        "da_gender": daGender,
        "da_dob": daDob,
        "da_reportmailsenddttm": daReportmailsenddttm,
        "da_canremarks": daCanremarks,
        "da_sourcetype": daSourcetype,
        "da_referrerptr": daReferrerptr,
        "da_firmptr": daFirmptr,
        "da_branchptr": daBranchptr,
        "da_samplestatus": daSamplestatus,
        "da_corporateptr": daCorporateptr,
        "da_corporateinfo": daCorporateinfo,
        "da_otherdetails1": daOtherdetails1,
        "da_updateduserid": daUpdateduserid,
        "da_updatedtime": daUpdatedtime,
        "da_consentscannedstatus": daConsentscannedstatus,
        "da_country": daCountry,
        "da_reftypeptr": daReftypeptr,
        "addOnPackageDetails": addOnPackageDetails == null
            ? []
            : List<dynamic>.from(addOnPackageDetails!.map((x) => x.toJson())),
        "addOnPackageTotal": addOnPackageTotal,
        "packageDetails": packageDetails?.toJson(),
        "age": age,
      };
}

class AddOnPackageDetails {
  String? itemCode;
  String? description;
  dynamic rate;
  dynamic image;

  AddOnPackageDetails({
    this.itemCode,
    this.description,
    this.rate,
    this.image,
  });

  factory AddOnPackageDetails.fromJson(Map<String, dynamic> json) =>
      AddOnPackageDetails(
          itemCode: json["item_code"],
          description: json["description"],
          rate: json["rate"],
          image: json["image"]);

  Map<String, dynamic> toJson() => {
        "item_code": itemCode,
        "description": description,
        "rate": rate,
        "image": image,
      };
}

class PackageDetails {
  String? itemCode;
  String? description;
  dynamic rate;
  dynamic image;
  String? slotDoctorPtr;

  PackageDetails({
    this.itemCode,
    this.description,
    this.rate,
    this.image,
    this.slotDoctorPtr,
  });

  factory PackageDetails.fromJson(Map<String, dynamic> json) => PackageDetails(
      itemCode: json["item_code"],
      description: json["description"],
      rate: json["rate"],
      image: json["image"],
      slotDoctorPtr: json["slotDoctorPtr"]);

  Map<String, dynamic> toJson() => {
        "item_code": itemCode,
        "description": description,
        "rate": rate,
        "image": image,
        "slotDoctorPtr": slotDoctorPtr
      };
}
