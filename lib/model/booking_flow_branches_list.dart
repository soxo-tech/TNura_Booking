// To parse this JSON data, do
//
//     final bookingFlowBranchesList = bookingFlowBranchesListFromJson(jsonString);

import 'dart:convert';

BookingFlowBranchesList bookingFlowBranchesListFromJson(String str) =>
    BookingFlowBranchesList.fromJson(json.decode(str));

String bookingFlowBranchesListToJson(BookingFlowBranchesList data) =>
    json.encode(data.toJson());

class BookingFlowBranchesList {
  int? statusCode;
  String? message;
  bool? success;
  List<BookingBranches>? result;

  BookingFlowBranchesList({
    this.statusCode,
    this.message,
    this.success,
    this.result,
  });

  factory BookingFlowBranchesList.fromJson(Map<String, dynamic> json) =>
      BookingFlowBranchesList(
        statusCode: json["statusCode"],
        message: json["message"],
        success: json["success"],
        result: json["result"] == null
            ? []
            : List<BookingBranches>.from(
                json["result"]!.map((x) => BookingBranches.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "message": message,
        "success": success,
        "result": result == null
            ? []
            : List<dynamic>.from(result!.map((x) => x.toJson())),
      };
}

class BookingBranches {
  String? brCode;
  String? brDesc;
  String? brAddptr;
  String? brFirmptr;
  String? brActive;
  dynamic brIssync;
  dynamic cngdDt;
  String? brOtherdet1;
  Map<String, String?>? address;

  BookingBranches({
    this.brCode,
    this.brDesc,
    this.brAddptr,
    this.brFirmptr,
    this.brActive,
    this.brIssync,
    this.cngdDt,
    this.brOtherdet1,
    this.address,
  });

  factory BookingBranches.fromJson(Map<String, dynamic> json) =>
      BookingBranches(
        brCode: json["br_code"],
        brDesc: json["br_desc"],
        brAddptr: json["br_addptr"],
        brFirmptr: json["br_firmptr"],
        brActive: json["br_active"],
        brIssync: json["br_issync"],
        cngdDt: json["cngd_dt"],
        brOtherdet1: json["br_otherdet1"],
        address: Map.from(json["address"]!)
            .map((k, v) => MapEntry<String, String?>(k, v)),
      );

  Map<String, dynamic> toJson() => {
        "br_code": brCode,
        "br_desc": brDesc,
        "br_addptr": brAddptr,
        "br_firmptr": brFirmptr,
        "br_active": brActive,
        "br_issync": brIssync,
        "cngd_dt": cngdDt,
        "br_otherdet1": brOtherdet1,
        "address":
            Map.from(address!).map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}
