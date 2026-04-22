import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_state.freezed.dart';

@freezed
class RegisterState<T> with _$RegisterState<T> {
  // 1. الحالة الابتدائية
  const factory RegisterState.initial() = Initial<T>;

  // 2. حالة التحميل (Loading)
  const factory RegisterState.loading() = Loading<T>;

  // 3. حالة النجاح مع استقبال بيانات (Generic T)
  const factory RegisterState.success(T data) = Success<T>;

  // 4. حالة الخطأ مع رسالة توضيحية
  const factory RegisterState.error({required String message}) = Error<T>;
}
