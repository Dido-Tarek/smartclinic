import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/clinic/data/model/add_clinic_request_model.dart';
import 'package:smartclinic/features/clinic/data/model/add_clinic_response_model.dart';

abstract class FacilityRepo {
  /// إضافة عيادة جديدة مع كافة التفاصيل القانونية والمالية والموقع الجغرافي
  Future<ApiResult<AddClinicResponseModel>> addNewClinic(
    AddClinicRequestModel addClinicRequestModel,
  );
}
