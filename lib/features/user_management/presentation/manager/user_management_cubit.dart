import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/user_management/data/model/reset_password_request_model.dart';
import 'package:smartclinic/features/user_management/data/repo/user_management_repo.dart';
import 'user_management_state.dart';

class UserManagementCubit extends Cubit<UserManagementState> {
  final UserManagementRepo _repo;
  UserManagementCubit(this._repo) : super(UserManagementInitial());

  Future<void> emitLogout() async {
    emit(UserManagementLoading());
    final result = await _repo.logout();
    result.when(
      success: (_) => emit(LogoutSuccess()),
      failure: (message) => emit(UserManagementError(message)),
    );
  }

  Future<void> getDoctorProfile(String id) async {
    emit(UserManagementLoading());
    final result = await _repo.getProfile(id);
    result.when(
      success: (profile) => emit(ProfileLoaded(profile)),
      failure: (message) => emit(UserManagementError(message)),
    );
  }

  Future<void> resetPassword(ResetPasswordRequest request) async {
    emit(UserManagementLoading());
    final result = await _repo.resetPassword(request);
    result.when(
      success: (_) => emit(UserManagementSuccess()),
      failure: (message) => emit(UserManagementError(message)),
    );
  }
}
