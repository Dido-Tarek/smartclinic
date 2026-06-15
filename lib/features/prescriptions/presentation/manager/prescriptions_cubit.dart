import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/features/prescriptions/data/repo/prescription_repo.dart';
import 'package:smartclinic/features/prescriptions/presentation/manager/prescriptions_state.dart';

class PrescriptionsCubit extends Cubit<PrescriptionsState> {
  final PrescriptionsRepo _repo;

  PrescriptionsCubit(this._repo) : super(const PrescriptionsInitial());

  Future<void> getMyPrescriptions() async {
    emit(const GetMyPrescriptionsLoading());
    final result = await _repo.getMyPrescriptions();
    result.fold(
      (error) => emit(GetMyPrescriptionsFailure(error)),
      (response) => emit(GetMyPrescriptionsSuccess(response)),
    );
  }

  Future<void> getPrescriptionById(int id) async {
    emit(const GetPrescriptionByIdLoading());
    final result = await _repo.getPrescriptionById(id);
    result.fold(
      (error) => emit(GetPrescriptionByIdFailure(error)),
      (prescription) => emit(GetPrescriptionByIdSuccess(prescription)),
    );
  }
}
