String? resolveDoctorImageSource({
  required String? appointmentImage,
  required String? profileImage,
}) {
  final appointmentValue = appointmentImage?.trim();
  if (appointmentValue != null && appointmentValue.isNotEmpty) {
    return appointmentValue;
  }

  final profileValue = profileImage?.trim();
  if (profileValue != null && profileValue.isNotEmpty) {
    return profileValue;
  }

  return null;
}
