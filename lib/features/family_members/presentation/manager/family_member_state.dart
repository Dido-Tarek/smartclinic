import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_member_state.freezed.dart';

@freezed
class FamilyState<T> with _$FamilyState<T> {
  const factory FamilyState.initial() = _Initial;
  const factory FamilyState.loading() = _Loading;
  const factory FamilyState.success(T data) = _Success<T>;
  const factory FamilyState.error({required String message}) = _Error;
}
