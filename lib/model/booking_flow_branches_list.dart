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
  String? code;
  String? desc;
  String? brAddptr;
  String? firmptr;
  String? active;
  dynamic issync;
  dynamic dt;
  String? otherdet1;
  Map<String, String?>? address;

  BookingBranches({
    this.code,
    this.desc,
    this.brAddptr,
    this.firmptr,
    this.active,
    this.issync,
    this.dt,
    this.otherdet1,
    this.address,
  });

  factory BookingBranches.fromJson(Map<String, dynamic> json) =>
      BookingBranches(
        code: json["code"],
        desc: json["description"],
        brAddptr: json["br_addptr"],
        firmptr: json["firm_ptr"],
        active: json["active"],
        issync: json["issync"],
        dt: json["dt"],
        otherdet1: json["otherdet1"],
        address: Map.from(json["address"]!)
            .map((k, v) => MapEntry<String, String?>(k, v)),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "description": desc,
        "br_addptr": brAddptr,
        "firm_ptr": firmptr,
        "active": active,
        "issync": issync,
        "dt": dt,
        "otherdet1": otherdet1,
        "address":
            Map.from(address!).map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}
