// To parse this JSON data, do
//
//     final availableSlotsModel = availableSlotsModelFromJson(jsonString);

import 'dart:convert';

AvailableSlotsModel availableSlotsModelFromJson(String str) =>
    AvailableSlotsModel.fromJson(json.decode(str));

String availableSlotsModelToJson(AvailableSlotsModel data) =>
    json.encode(data.toJson());

class AvailableSlotsModel {
  int? statusCode;
  bool? success;
  List<AvailableSlot>? data;

  AvailableSlotsModel({
    this.statusCode,
    this.success,
    this.data,
  });

  factory AvailableSlotsModel.fromJson(Map<String, dynamic> json) =>
      AvailableSlotsModel(
        statusCode: json["status_code"],
        success: json["success"],
        data: json["data"] == null
            ? []
            : List<AvailableSlot>.from(
                json["data"]!.map((x) => AvailableSlot.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "success": success,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class AvailableSlot {
  String? doctorptr;
  Dayname? dayname;
  String? starttime;
  String? endtime;
  int? tokenno;
  bool? booked;
  DateTime? date;

  AvailableSlot({
    this.doctorptr,
    this.dayname,
    this.starttime,
    this.endtime,
    this.tokenno,
    this.booked,
    this.date,
  });

  factory AvailableSlot.fromJson(Map<String, dynamic> json) => AvailableSlot(
        doctorptr: json["doctorptr"],
        dayname: daynameValues.map[json["dayname"]],
        starttime: json["starttime"],
        endtime: json["endtime"],
        tokenno: json["tokenno"],
        booked: json["booked"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
      );

  Map<String, dynamic> toJson() => {
        "doctorptr": doctorptr,
        "dayname": daynameValues.reverse[dayname],
        "starttime": starttime,
        "endtime": endtime,
        "tokenno": tokenno,
        "booked": booked,
        "date": date?.toIso8601String(),
      };
}

// ignore: constant_identifier_names
enum Dayname { FRIDAY }

final daynameValues = EnumValues({"Friday": Dayname.FRIDAY});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
