import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/auth/data/models/facility_claim_ownership_request.dart.dart';
import 'package:smartclinic/features/registeration/data/model/medical_facility_register_model.dart';
import 'package:smartclinic/features/registeration/data/model/patient_register_model.dart';
import 'package:smartclinic/features/auth/data/models/verification_file_model.dart';

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

  Future<ApiResult<dynamic>> uploadVerificationDocs({
    required String doctorId,
    required VerificationFileModel files,
  });

  Future<ApiResult<List<dynamic>>> getPendingDoctors();

  Future<ApiResult<dynamic>> uploadFacilityCredentials({
    required bool isClaiming,
    required targetId,
    required FacilityClaimOwnershipRequest request,
  });
}
