import 'package:freezed_annotation/freezed_annotation.dart';
part 'add_clinic_state.freezed.dart';

@freezed
class AddClinicState<T> with _$AddClinicState<T> {
  const factory AddClinicState.initial() = _Initial;
  const factory AddClinicState.loading() = Loading;
  const factory AddClinicState.success(T data) = Success<T>;
  const factory AddClinicState.error({required String error}) = Error;
}
