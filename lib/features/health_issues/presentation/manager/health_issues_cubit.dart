import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/health_issues/data/models/health_issues_model.dart';
import 'package:smartclinic/features/health_issues/domain/repo/health_issues_repo.dart';
import 'package:smartclinic/features/health_issues/presentation/manager/health_issues_state.dart';

class HealthIssuesCubit extends Cubit<HealthIssuesState> {
  final HealthIssuesRepo _repo;
  HealthIssuesCubit(this._repo) : super(const HealthIssuesState.initial());

  Future<void> emitAddHealthIssue(
    String patientId,
    HealthIssueModel issue,
  ) async {
    emit(const HealthIssuesState.loading());
    final result = await _repo.addHealthIssue(patientId, issue);
    result.when(
      success: (data) => emit(HealthIssuesState.success(data)),
      failure: (error) => emit(HealthIssuesState.error(message: error)),
    );
  }

  Future<void> emitUpdateHealthIssue(int id, HealthIssueModel issue) async {
    emit(const HealthIssuesState.loading());
    final result = await _repo.updateHealthIssue(id, issue);
    result.when(
      success: (data) => emit(HealthIssuesState.success(data)),
      failure: (error) => emit(HealthIssuesState.error(message: error)),
    );
  }

  Future<void> emitGetPatientHistory() async {
    emit(const HealthIssuesState.loading());
    final result = await _repo.getPatientHistory();
    result.when(
      success: (data) => emit(HealthIssuesState.success(data)),
      failure: (error) => emit(HealthIssuesState.error(message: error)),
    );
  }
}
