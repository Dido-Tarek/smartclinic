import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/family_members/data/models/family_member_model.dart';
import 'package:smartclinic/features/family_members/domain/repo/family_member_repo.dart';
import 'package:smartclinic/features/family_members/presentation/manager/family_member_state.dart';

class FamilyCubit extends Cubit<FamilyState> {
  final FamilyRepo _repo;
  FamilyCubit(this._repo) : super(const FamilyState.initial());

  Future<void> emitAddMember(FamilyMemberModel member) async {
    emit(const FamilyState.loading());
    final result = await _repo.addMember(member);
    result.when(
      success: (data) => emit(FamilyState.success(data)),
      failure: (error) => emit(FamilyState.error(message: error)),
    );
  }

  Future<void> emitGetFamily() async {
    emit(const FamilyState.loading());
    final result = await _repo.getFamily();
    result.when(
      success: (data) => emit(FamilyState.success(data)),
      failure: (error) => emit(FamilyState.error(message: error)),
    );
  }

  Future<void> emitDeleteMember(int id) async {
    emit(const FamilyState.loading());
    final result = await _repo.deleteMember(id);
    result.when(
      success: (data) async {
        final fetchResult = await _repo.getFamily();
        fetchResult.when(
          success: (members) => emit(FamilyState.success(members)),
          failure: (error) => emit(FamilyState.error(message: error)),
        );
      },
      failure: (error) => emit(FamilyState.error(message: error)),
    );
  }
}
