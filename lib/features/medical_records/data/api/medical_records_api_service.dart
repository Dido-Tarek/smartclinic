import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:smartclinic/features/medical_records/data/model/medical_records_response.dart';

part 'medical_records_api_service.g.dart';

@RestApi(baseUrl: "http://smartclinicccc.runasp.net/")
abstract class MedicalRecordsApiService {
  factory MedicalRecordsApiService(Dio dio, {String baseUrl}) =
      _MedicalRecordsApiService;

  @POST("api/MedicalRecords/add")
  @MultiPart()
  Future<UploadRecordResponse> uploadMedicalRecord({
    // نستخدم @Part و MultipartFile لضمان رفع الملف بشكل سليم كـ binary
    @Part(name: "File") required MultipartFile file,
    @Part(name: "Title") required String title,
    @Part(name: "Description") required String description,
    @Part(name: "PatientId") required String patientId,
    // الـ AppointmentId في السواجر integer($int32)
    @Part(name: "AppointmentId") int? appointmentId,
    // الـ DoctorId في السواجر string
    @Part(name: "DoctorId") String? doctorId,
  });

  // إضافة دالة الـ GET الموجودة في أسفل صورة السواجر لجلب السجلات
  @GET("api/MedicalRecords/patient-records/{patientId}")
  Future<List<UploadRecordResponse>> getPatientRecords(
    @Path("patientId") String patientId,
  );
}
