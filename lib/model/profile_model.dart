// To parse this JSON data, do
//
//     final profileModel = profileModelFromJson(jsonString);

import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'profile_model.g.dart';

ProfileModel profileModelFromJson(String str) =>
    ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

@JsonSerializable()
class ProfileModel {
  @JsonKey(name: "statusCode")
  final int? statusCode;
  @JsonKey(name: "message")
  final String? message;
  @JsonKey(name: "mode")
  final String? mode;
  @JsonKey(name: "id")
  final String? id;
  @JsonKey(name: "Type")
  final String? type;
  @JsonKey(name: "Dt")
  final DateTime? dt;
  @JsonKey(name: "Tm")
  final DateTime? tm;
  @JsonKey(name: "Title")
  final dynamic title;
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "Lname")
  final String? lname;
  @JsonKey(name: "Gender")
  final String? gender;
  @JsonKey(name: "AgeDay")
  final int? ageDay;
  @JsonKey(name: "AgeMonth")
  final int? ageMonth;
  @JsonKey(name: "AgeYear")
  final int? ageYear;
  @JsonKey(name: "Dob")
  final DateTime? dob;
  @JsonKey(name: "Address1")
  final dynamic address1;
  @JsonKey(name: "Address2")
  final dynamic address2;
  @JsonKey(name: "LandMark")
  final dynamic landMark;
  @JsonKey(name: "City")
  final dynamic city;
  @JsonKey(name: "Phone")
  final dynamic phone;
  @JsonKey(name: "CountryCodeMob1")
  final String? countryCodeMob1;
  @JsonKey(name: "Mobile1")
  final String? mobile1;
  @JsonKey(name: "CountryCodeMob2")
  final String? countryCodeMob2;
  @JsonKey(name: "Mobile2")
  final String? mobile2;
  @JsonKey(name: "Email")
  final String? email;
  @JsonKey(name: "Referralno")
  final dynamic referralno;
  @JsonKey(name: "wallet_activated")
  final bool? walletActivated;
  @JsonKey(name: "Firmid")
  final int? firmid;
  @JsonKey(name: "Finyearid")
  final dynamic finyearid;
  @JsonKey(name: "Username")
  final String? username;
  @JsonKey(name: "Password")
  final dynamic password;
  @JsonKey(name: "Opno")
  final dynamic opno;
  @JsonKey(name: "PackageTypeValue")
  final dynamic packageTypeValue;
  @JsonKey(name: "PackageType")
  final dynamic packageType;
  @JsonKey(name: "zip")
  final dynamic zip;
  @JsonKey(name: "Active")
  final String? active;
  @JsonKey(name: "User")
  final String? user;
  @JsonKey(name: "Updttm")
  final DateTime? updttm;
  @JsonKey(name: "branch_id")
  final int? branchId;
  @JsonKey(name: "user_group")
  final dynamic userGroup;
  @JsonKey(name: "firm")
  final Firm? firm;
  @JsonKey(name: "calculatedAge")
  final int? calculatedAge;
  ProfileModel(
      {this.statusCode,
      this.message,
      this.mode,
      this.id,
      this.type,
      this.dt,
      this.tm,
      this.title,
      this.name,
      this.lname,
      this.gender,
      this.ageDay,
      this.ageMonth,
      this.ageYear,
      this.dob,
      this.address1,
      this.address2,
      this.landMark,
      this.city,
      this.phone,
      this.countryCodeMob1,
      this.mobile1,
      this.countryCodeMob2,
      this.mobile2,
      this.email,
      this.referralno,
      this.walletActivated,
      this.firmid,
      this.finyearid,
      this.username,
      this.password,
      this.opno,
      this.packageTypeValue,
      this.packageType,
      this.zip,
      this.active,
      this.user,
      this.updttm,
      this.branchId,
      this.userGroup,
      this.firm,
      this.calculatedAge});

  ProfileModel copyWith(
          {int? statusCode,
          String? message,
          String? mode,
          String? id,
          String? type,
          DateTime? dt,
          DateTime? tm,
          dynamic title,
          String? name,
          String? lname,
          String? gender,
          int? ageDay,
          int? ageMonth,
          int? ageYear,
          DateTime? dob,
          dynamic address1,
          dynamic address2,
          dynamic landMark,
          dynamic city,
          dynamic phone,
          String? countryCodeMob1,
          String? mobile1,
          String? countryCodeMob2,
          String? mobile2,
          String? email,
          dynamic referralno,
          dynamic walletActivated,
          int? firmid,
          dynamic finyearid,
          String? username,
          dynamic password,
          dynamic opno,
          dynamic packageTypeValue,
          dynamic packageType,
          dynamic zip,
          String? active,
          String? user,
          DateTime? updttm,
          int? branchId,
          dynamic userGroup,
          Firm? firm,
          int? calculatedAge}) =>
      ProfileModel(
          statusCode: statusCode ?? this.statusCode,
          message: message ?? this.message,
          mode: mode ?? this.mode,
          id: id ?? this.id,
          type: type ?? this.type,
          dt: dt ?? this.dt,
          tm: tm ?? this.tm,
          title: title ?? this.title,
          name: name ?? this.name,
          lname: lname ?? this.lname,
          gender: gender ?? this.gender,
          ageDay: ageDay ?? this.ageDay,
          ageMonth: ageMonth ?? this.ageMonth,
          ageYear: ageYear ?? this.ageYear,
          dob: dob ?? this.dob,
          address1: address1 ?? this.address1,
          address2: address2 ?? this.address2,
          landMark: landMark ?? this.landMark,
          city: city ?? this.city,
          phone: phone ?? this.phone,
          countryCodeMob1: countryCodeMob1 ?? this.countryCodeMob1,
          mobile1: mobile1 ?? this.mobile1,
          countryCodeMob2: countryCodeMob2 ?? this.countryCodeMob2,
          mobile2: mobile2 ?? this.mobile2,
          email: email ?? this.email,
          referralno: referralno ?? this.referralno,
          walletActivated: walletActivated ?? this.walletActivated,
          firmid: firmid ?? this.firmid,
          finyearid: finyearid ?? this.finyearid,
          username: username ?? this.username,
          password: password ?? this.password,
          opno: opno ?? this.opno,
          packageTypeValue: packageTypeValue ?? this.packageTypeValue,
          packageType: packageType ?? this.packageType,
          zip: zip ?? this.zip,
          active: active ?? this.active,
          user: user ?? this.user,
          updttm: updttm ?? this.updttm,
          branchId: branchId ?? this.branchId,
          userGroup: userGroup ?? this.userGroup,
          firm: firm ?? this.firm,
          calculatedAge: calculatedAge ?? this.calculatedAge);

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);

  /// Age in years to display/use for booking.
  ///
  /// The profile API does not always return [calculatedAge], so fall back to
  /// computing it from [dob] and finally the stored [ageYear].
  int? get effectiveAge {
    if (calculatedAge != null) return calculatedAge;

    if (dob != null) {
      final now = DateTime.now();
      int age = now.year - dob!.year;
      if (now.month < dob!.month ||
          (now.month == dob!.month && now.day < dob!.day)) {
        age--;
      }
      if (age >= 0) return age;
    }

    return ageYear;
  }
}

@JsonSerializable()
class Firm {
  @JsonKey(name: "f_code")
  final String? fCode;
  @JsonKey(name: "f_desc")
  final String? fDesc;
  @JsonKey(name: "f_shortname")
  final String? fShortname;
  @JsonKey(name: "f_group")
  final dynamic fGroup;
  @JsonKey(name: "f_addressid")
  final String? fAddressid;
  @JsonKey(name: "f_remarks")
  final dynamic fRemarks;
  @JsonKey(name: "f_slno")
  final dynamic fSlno;
  @JsonKey(name: "f_active")
  final String? fActive;
  @JsonKey(name: "f_otherdetails1")
  final String? fOtherdetails1;

  Firm({
    this.fCode,
    this.fDesc,
    this.fShortname,
    this.fGroup,
    this.fAddressid,
    this.fRemarks,
    this.fSlno,
    this.fActive,
    this.fOtherdetails1,
  });

  Firm copyWith({
    String? fCode,
    String? fDesc,
    String? fShortname,
    dynamic fGroup,
    String? fAddressid,
    dynamic fRemarks,
    dynamic fSlno,
    String? fActive,
    String? fOtherdetails1,
  }) =>
      Firm(
        fCode: fCode ?? this.fCode,
        fDesc: fDesc ?? this.fDesc,
        fShortname: fShortname ?? this.fShortname,
        fGroup: fGroup ?? this.fGroup,
        fAddressid: fAddressid ?? this.fAddressid,
        fRemarks: fRemarks ?? this.fRemarks,
        fSlno: fSlno ?? this.fSlno,
        fActive: fActive ?? this.fActive,
        fOtherdetails1: fOtherdetails1 ?? this.fOtherdetails1,
      );

  factory Firm.fromJson(Map<String, dynamic> json) => _$FirmFromJson(json);

  Map<String, dynamic> toJson() => _$FirmToJson(this);
}
