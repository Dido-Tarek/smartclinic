import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_issues_state.freezed.dart';

@freezed
class HealthIssuesState<T> with _$HealthIssuesState<T> {
  const factory HealthIssuesState.initial() = _Initial;
  const factory HealthIssuesState.loading() = _Loading;
  const factory HealthIssuesState.success(T data) = _Success<T>;
  const factory HealthIssuesState.error({required String message}) = _Error;
}
