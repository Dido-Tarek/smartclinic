import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/registeration/data/model/medical_facility_register_model.dart';
import 'package:smartclinic/features/registeration/data/model/patient_register_model.dart';

abstract class AuthRepo {
  // تسجيل مريض
  Future<ApiResult<dynamic>> registerPatient(
    PatientRegisterRequestModel patientModel,
  );

  // تسجيل منشأة طبية
  Future<ApiResult<dynamic>> registerFacility(
    MedicalFacilityRequestModel facilityModel,
  );

  // تسجيل دخول
  Future<ApiResult<dynamic>> login(String email, String password);
}
