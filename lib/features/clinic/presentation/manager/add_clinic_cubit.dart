import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/clinic/data/model/add_clinic_request_model.dart';
import 'package:smartclinic/features/clinic/domain/facility_repo.dart';
import 'package:smartclinic/features/clinic/presentation/manager/add_clinic_state.dart';
import 'package:smartclinic/core/network/api_error_handler.dart';

class AddClinicCubit extends Cubit<AddClinicState> {
  final FacilityRepo _facilityRepo;

  AddClinicCubit(this._facilityRepo) : super(const AddClinicState.initial());

  Future<void> emitAddClinicStates(AddClinicRequestModel requestModel) async {
    emit(const AddClinicState.loading());

    final response = await _facilityRepo.addNewClinic(requestModel);

    response.when(
      success: (addClinicResponse) {
        emit(AddClinicState.success(addClinicResponse));
      },
      failure: (error) {
        emit(AddClinicState.error(error: ApiErrorHandler.handle(error)));
      },
    );
  }
}
