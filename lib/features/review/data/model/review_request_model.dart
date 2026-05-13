class AddReviewRequestModel {
  final String doctorId;
  final String patientId;
  final int rating;
  final String comment;

  const AddReviewRequestModel({
    required this.doctorId,
    required this.patientId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() => {
    'doctorId': doctorId,
    'patientId': patientId,
    'rating': rating,
    'comment': comment,
  };
}
