// ── DELETE /api/ClinicAdmin/remove-doctor ─────────────────────────────────────
// Both params are query params — no body needed
class RemoveDoctorRequestModel {
  final int clinicId;
  final String doctorId;

  const RemoveDoctorRequestModel({
    required this.clinicId,
    required this.doctorId,
  });

  Map<String, dynamic> toQueryParams() => {
    'clinicId': clinicId,
    'doctorId': doctorId,
  };
}
