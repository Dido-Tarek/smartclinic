import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_credentials_state.freezed.dart';

@freezed
class UploadCredentialsState<T> with _$UploadCredentialsState<T> {
  const factory UploadCredentialsState.initial() = _Initial;

  const factory UploadCredentialsState.loading() = Loading;

  const factory UploadCredentialsState.success(T data) = Success<T>;

  const factory UploadCredentialsState.error({required String error}) =
      Error<T>;
}
