import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/features/search/data/model/search_doctors_request_model.dart';
import 'package:smartclinic/features/search/data/repo/search_doctors_repo.dart';
import 'package:smartclinic/features/search/presentation/manager/search_doctors_state.dart';

class DoctorsCubit extends Cubit<DoctorsState> {
  final DoctorsRepo _repo;

  DoctorsCubit(this._repo) : super(const DoctorsInitial());

  // ── POST /api/Doctors/search-doctors ───────────────────────────────────────
  Future<void> searchDoctors({
    String? query,
    String? specialization,
    String? city,
    String? area,
    int? consultationType,
    int? maxPrice,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    emit(const SearchDoctorsLoading());

    final request = SearchDoctorsRequestModel(
      query: query,
      specialization: specialization,
      city: city,
      area: area,
      consultationType: consultationType,
      maxPrice: maxPrice,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    final result = await _repo.searchDoctors(request);

    result.fold(
      (errorMessage) => emit(SearchDoctorsFailure(errorMessage)),
      (response) => emit(SearchDoctorsSuccess(response)),
    );
  }

  // ── GET /api/Doctors/{id} ──────────────────────────────────────────────────
  Future<void> getDoctorById(String id) async {
    emit(const GetDoctorByIdLoading());

    final result = await _repo.getDoctorById(id);

    result.fold(
      (errorMessage) => emit(GetDoctorByIdFailure(errorMessage)),
      (doctor) => emit(GetDoctorByIdSuccess(doctor)),
    );
  }

  /// Resets back to initial (e.g. when leaving search screen)
  void reset() => emit(const DoctorsInitial());
}
