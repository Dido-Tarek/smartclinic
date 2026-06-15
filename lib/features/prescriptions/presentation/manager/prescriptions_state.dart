import 'package:equatable/equatable.dart';
import 'package:smartclinic/features/prescriptions/data/model/prescriptions_resoponse_model.dart';

abstract class PrescriptionsState extends Equatable {
  const PrescriptionsState();

  @override
  List<Object?> get props => [];
}

class PrescriptionsInitial extends PrescriptionsState {
  const PrescriptionsInitial();
}

// ── GET /api/Prescriptions/my-prescriptions ───────────────────────────────────

class GetMyPrescriptionsLoading extends PrescriptionsState {
  const GetMyPrescriptionsLoading();
}

class GetMyPrescriptionsSuccess extends PrescriptionsState {
  final MyPrescriptionsResponseModel response;

  const GetMyPrescriptionsSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class GetMyPrescriptionsFailure extends PrescriptionsState {
  final String errorMessage;

  const GetMyPrescriptionsFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// ── GET /api/Prescriptions/get/{id} ──────────────────────────────────────────

class GetPrescriptionByIdLoading extends PrescriptionsState {
  const GetPrescriptionByIdLoading();
}

class GetPrescriptionByIdSuccess extends PrescriptionsState {
  final PrescriptionModel prescription;

  const GetPrescriptionByIdSuccess(this.prescription);

  @override
  List<Object?> get props => [prescription];
}

class GetPrescriptionByIdFailure extends PrescriptionsState {
  final String errorMessage;

  const GetPrescriptionByIdFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
