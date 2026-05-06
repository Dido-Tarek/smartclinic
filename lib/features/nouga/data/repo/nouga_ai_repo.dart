import 'package:dartz/dartz.dart';
import 'package:smartclinic/core/network/api_error_handler.dart';
import 'package:smartclinic/features/nouga/data/api/nouga_ai_api_service.dart';
import 'package:smartclinic/features/nouga/data/model/nouga_ai_request_model.dart';
import 'package:smartclinic/features/nouga/data/model/nouga_ai_response_model.dart';

abstract class MedicalChatRepo {
  Future<Either<String, SendMessageResponseModel>> sendMessage(
    SendMessageRequestModel request,
  );
}

class MedicalChatRepoImpl implements MedicalChatRepo {
  final MedicalChatApiService _apiService;

  MedicalChatRepoImpl(this._apiService);

  @override
  Future<Either<String, SendMessageResponseModel>> sendMessage(
    SendMessageRequestModel request,
  ) async {
    try {
      final result = await _apiService.sendMessage(request);
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }
}
