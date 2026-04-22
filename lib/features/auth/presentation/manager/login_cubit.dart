import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/auth/data/models/login_request_model.dart';
import 'package:smartclinic/features/auth/domain/auth_repo.dart';

import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepo _authRepo;
  LoginCubit(this._authRepo) : super(const LoginState.initial());

  Future<void> emitLogin(LoginRequestModel loginRequest) async {
    emit(const LoginState.loading());
    final response = await _authRepo.login(
      loginRequest.email,
      loginRequest.password,
    );
    response.when(
      success: (data) => emit(LoginState.success(data)),
      failure: (message) => emit(LoginState.error(message: message)),
    );
  }
}
