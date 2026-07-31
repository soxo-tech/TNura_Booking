// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
    statusCode: (json['statusCode'] as num?)?.toInt(),
    message: json['message'] as String?,
    mode: json['mode'] as String?,
    id: parseString(json['id']),
    type: json['Type'] as String?,
    dt: json['Dt'] == null ? null : DateTime.parse(json['Dt'] as String),
    tm: json['Tm'] == null ? null : DateTime.parse(json['Tm'] as String),
    title: json['Title'],
    name: json['name'] as String?,
    lname: json['Lname'] as String?,
    gender: json['Gender'] as String?,
    ageDay: (json['AgeDay'] as num?)?.toInt(),
    ageMonth: (json['AgeMonth'] as num?)?.toInt(),
    ageYear: (json['AgeYear'] as num?)?.toInt(),
    dob: json['Dob'] == null ? null : DateTime.parse(json['Dob'] as String),
    address1: json['Address1'],
    address2: json['Address2'],
    landMark: json['LandMark'],
    city: json['City'],
    phone: json['Phone'],
    countryCodeMob1: json['CountryCodeMob1'] as String?,
    mobile1: json['Mobile1'] as String?,
    countryCodeMob2: json['CountryCodeMob2'] as String?,
    mobile2: json['Mobile2'] as String?,
    email: json['Email'] as String?,
    referralno: json['Referralno'],
    walletActivated: json['wallet_activated'] as bool?,
    firmid: (json['Firmid'] as num?)?.toInt(),
    finyearid: json['Finyearid'],
    username: json['Username'] as String?,
    password: json['Password'],
    opno: json['Opno'],
    packageTypeValue: json['PackageTypeValue'],
    packageType: json['PackageType'],
    zip: json['zip'],
    active: json['Active'] as String?,
    user: json['User'] as String?,
    updttm: json['Updttm'] == null
        ? null
        : DateTime.parse(json['Updttm'] as String),
    branchId: (json['branch_id'] as num?)?.toInt(),
    userGroup: json['user_group'],
    firm: json['firm'] == null
        ? null
        : Firm.fromJson(json['firm'] as Map<String, dynamic>),
    calculatedAge: (json['calculatedAge'] as num?)?.toInt());

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'message': instance.message,
      'mode': instance.mode,
      'id': instance.id,
      'Type': instance.type,
      'Dt': instance.dt?.toIso8601String(),
      'Tm': instance.tm?.toIso8601String(),
      'Title': instance.title,
      'name': instance.name,
      'Lname': instance.lname,
      'Gender': instance.gender,
      'AgeDay': instance.ageDay,
      'AgeMonth': instance.ageMonth,
      'AgeYear': instance.ageYear,
      'Dob': instance.dob?.toIso8601String(),
      'Address1': instance.address1,
      'Address2': instance.address2,
      'LandMark': instance.landMark,
      'City': instance.city,
      'Phone': instance.phone,
      'CountryCodeMob1': instance.countryCodeMob1,
      'Mobile1': instance.mobile1,
      'CountryCodeMob2': instance.countryCodeMob2,
      'Mobile2': instance.mobile2,
      'Email': instance.email,
      'Referralno': instance.referralno,
      'wallet_activated': instance.walletActivated,
      'Firmid': instance.firmid,
      'Finyearid': instance.finyearid,
      'Username': instance.username,
      'Password': instance.password,
      'Opno': instance.opno,
      'PackageTypeValue': instance.packageTypeValue,
      'PackageType': instance.packageType,
      'zip': instance.zip,
      'Active': instance.active,
      'User': instance.user,
      'Updttm': instance.updttm?.toIso8601String(),
      'branch_id': instance.branchId,
      'user_group': instance.userGroup,
      'firm': instance.firm,
      'calculatedAge': instance.calculatedAge,
    };

Firm _$FirmFromJson(Map<String, dynamic> json) => Firm(
      fCode: json['f_code'] as String?,
      fDesc: json['f_desc'] as String?,
      fShortname: json['f_shortname'] as String?,
      fGroup: json['f_group'],
      fAddressid: json['f_addressid'] as String?,
      fRemarks: json['f_remarks'],
      fSlno: json['f_slno'],
      fActive: json['f_active'] as String?,
      fOtherdetails1: json['f_otherdetails1'] as String?,
    );

Map<String, dynamic> _$FirmToJson(Firm instance) => <String, dynamic>{
      'f_code': instance.fCode,
      'f_desc': instance.fDesc,
      'f_shortname': instance.fShortname,
      'f_group': instance.fGroup,
      'f_addressid': instance.fAddressid,
      'f_remarks': instance.fRemarks,
      'f_slno': instance.fSlno,
      'f_active': instance.fActive,
      'f_otherdetails1': instance.fOtherdetails1,
    };
String? parseString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}
