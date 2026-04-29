import 'package:smartclinic/core/network/api_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/auth/data/models/facility_claim_ownership_request.dart.dart';
import 'package:smartclinic/features/auth/domain/auth_repo.dart';
import 'package:smartclinic/features/auth/presentation/manager/upload_credentials_state.dart';
import 'package:smartclinic/injection_dependency.dart';

class UploadCredentialsCubit extends Cubit<UploadCredentialsState> {
  final AuthRepo _authRepo;

  UploadCredentialsCubit(this._authRepo)
    : super(const UploadCredentialsState.initial());

  /// الدالة الرئيسية لرفع الملفات والتمييز بين Owner Docs و Claim Ownership
  Future<void> uploadCredentials({
    int? clinicId, // لو القيمة موجودة يبقى Claim، لو null يبقى Owner Docs
    required FacilityClaimOwnershipRequest request,
  }) async {
    emit(const UploadCredentialsState.loading());

    // تحديد هل العملية هي "إثبات ملكية" عيادة موجودة أم "توثيق مالك" لعيادة جديدة
    final bool isClaiming = clinicId != null;

    // الحصول على الـ ID المستهدف (إما الـ clinicId المختار أو الـ userId الخاص بالدكتور الحالي)
    final targetId = isClaiming ? clinicId : getIt<UserSession>().userId;

    final response = await _authRepo.uploadFacilityCredentials(
      isClaiming: isClaiming,
      targetId: targetId,
      request: request,
    );

    response.when(
      success: (data) {
        emit(UploadCredentialsState.success(data));
      },
      failure: (error) {
        emit(
          UploadCredentialsState.error(error: ApiErrorHandler.handle(error)),
        );
      },
    );
  }
}
