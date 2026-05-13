import 'package:dio/dio.dart';
import 'package:smartclinic/features/prescriptions/data/model/prescription_request_model.dart';
import 'package:smartclinic/features/prescriptions/data/model/prescriptions_resoponse_model.dart';

class PrescriptionsApiService {
  final Dio _dio;

  PrescriptionsApiService(this._dio);

  static const String _addEndpoint = '/api/Prescriptions/add';
  static const String _getByIdEndpoint = '/api/Prescriptions/get';
  static const String _myPrescriptionsEndpoint =
      '/api/Prescriptions/my-prescriptions';

  // ── POST /api/Prescriptions/add ───────────────────────────────────────────
  Future<AddPrescriptionResponseModel> addPrescription(
    AddPrescriptionRequestModel request,
  ) async {
    final response = await _dio.post(_addEndpoint, data: request.toJson());
    return PrescriptionModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ── GET /api/Prescriptions/get/{id} ──────────────────────────────────────
  Future<GetPrescriptionByIdResponseModel> getPrescriptionById(int id) async {
    final response = await _dio.get('$_getByIdEndpoint/$id');
    return PrescriptionModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ── GET /api/Prescriptions/my-prescriptions ───────────────────────────────
  Future<MyPrescriptionsResponseModel> getMyPrescriptions() async {
    final response = await _dio.get(_myPrescriptionsEndpoint);

    // Handle both wrapped { prescriptions: [...] } and raw [...] responses
    if (response.data is List) {
      return MyPrescriptionsResponseModel.fromList(
        response.data as List<dynamic>,
      );
    }
    return MyPrescriptionsResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
