import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/features/family_members/data/models/family_member_request_model.dart';
import 'package:smartclinic/features/family_members/data/repo/family_member_repo.dart';
import 'package:smartclinic/features/family_members/presentation/manager/family_member_state.dart';

class FamilyCubit extends Cubit<FamilyState> {
  final FamilyRepo _repo;

  FamilyCubit(this._repo) : super(const FamilyInitial());

  // ── POST /api/Family/add ────────────────────────────────────────────────
  Future<void> addFamilyMember({
    required String patientId,
    required String name,
    required String relation,
    required String gender,
    required String birthDate, // ISO-8601 string
    required String bloodType,
  }) async {
    emit(const AddFamilyMemberLoading());

    final result = await _repo.addFamilyMember(
      AddFamilyMemberRequestModel(
        patientId: patientId,
        name: name,
        relation: relation,
        gender: gender,
        birthDate: birthDate,
        bloodType: bloodType,
      ),
    );

    result.fold((error) => emit(AddFamilyMemberFailure(error)), (member) {
      emit(AddFamilyMemberSuccess(member));
      // Auto-refresh list so the new member appears immediately
      getMyFamily();
    });
  }

  // ── GET /api/Family/my-family ───────────────────────────────────────────
  Future<void> getMyFamily() async {
    emit(const GetMyFamilyLoading());

    final result = await _repo.getMyFamily();

    result.fold(
      (error) => emit(GetMyFamilyFailure(error)),
      (response) => emit(GetMyFamilySuccess(response)),
    );
  }

  Future<void> emitGetFamily() => getMyFamily();

  // ── DELETE /api/Family/remove/{id} ─────────────────────────────────────
  Future<void> removeFamilyMember(int id) async {
    emit(RemoveFamilyMemberLoading(id)); // carries id for per-item spinner

    final result = await _repo.removeFamilyMember(id);

    result.fold((error) => emit(RemoveFamilyMemberFailure(error)), (response) {
      emit(RemoveFamilyMemberSuccess(response, id));
      // Auto-refresh list after deletion
      getMyFamily();
    });
  }

  Future<void> emitAddMember(AddFamilyMemberRequestModel request) {
    return addFamilyMember(
      patientId: request.patientId,
      name: request.name,
      relation: request.relation,
      gender: request.gender,
      birthDate: request.birthDate,
      bloodType: request.bloodType,
    );
  }

  Future<void> emitDeleteMember(int id) => removeFamilyMember(id);

  void reset() => emit(const FamilyInitial());
}
