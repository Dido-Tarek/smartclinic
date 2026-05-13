import 'package:equatable/equatable.dart';
import 'package:smartclinic/features/search/data/model/search_doctors_response_model.dart';

abstract class DoctorsState extends Equatable {
  const DoctorsState();

  @override
  List<Object?> get props => [];
}

// ── Shared ────────────────────────────────────────────────────────────────────

class DoctorsInitial extends DoctorsState {
  const DoctorsInitial();
}

// ── Search doctors ────────────────────────────────────────────────────────────

class SearchDoctorsLoading extends DoctorsState {
  const SearchDoctorsLoading();
}

class SearchDoctorsSuccess extends DoctorsState {
  final SearchDoctorsResponseModel response;

  const SearchDoctorsSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class SearchDoctorsFailure extends DoctorsState {
  final String errorMessage;

  const SearchDoctorsFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// ── Get doctor by id ──────────────────────────────────────────────────────────

class GetDoctorByIdLoading extends DoctorsState {
  const GetDoctorByIdLoading();
}

class GetDoctorByIdSuccess extends DoctorsState {
  final GetDoctorByIdResponseModel doctor;

  const GetDoctorByIdSuccess(this.doctor);

  @override
  List<Object?> get props => [doctor];
}

class GetDoctorByIdFailure extends DoctorsState {
  final String errorMessage;

  const GetDoctorByIdFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
