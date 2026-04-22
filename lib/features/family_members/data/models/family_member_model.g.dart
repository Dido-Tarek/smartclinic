// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FamilyMemberModel _$FamilyMemberModelFromJson(Map<String, dynamic> json) =>
    FamilyMemberModel(
      id: (json['id'] as num?)?.toInt(),
      patientId: json['patientId'] as String,
      name: json['name'] as String,
      relation: json['relation'] as String,
      gender: json['gender'] as String,
      birthDate: json['birthDate'] as String,
      bloodType: json['bloodType'] as String,
    );

Map<String, dynamic> _$FamilyMemberModelToJson(FamilyMemberModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'name': instance.name,
      'relation': instance.relation,
      'gender': instance.gender,
      'birthDate': instance.birthDate,
      'bloodType': instance.bloodType,
    };
