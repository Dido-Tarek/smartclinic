import 'package:flutter_test/flutter_test.dart';
import 'package:smartclinic/core/utils/doctor_image_resolver.dart';

void main() {
  group('Doctor image resolution', () {
    test('prefers the doctor profile image when the appointment image is missing', () {
      final resolved = resolveDoctorImageSource(
        appointmentImage: null,
        profileImage: 'https://example.com/doctor-profile.png',
      );

      expect(resolved, 'https://example.com/doctor-profile.png');
    });

    test('uses the appointment image when it is already present', () {
      final resolved = resolveDoctorImageSource(
        appointmentImage: 'https://example.com/appointment-doctor.png',
        profileImage: null,
      );

      expect(resolved, 'https://example.com/appointment-doctor.png');
    });
  });
}
