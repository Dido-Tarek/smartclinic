import '../../../../core/network/api_result.dart';
import '../../data/models/family_member_model.dart';

abstract class FamilyRepo {
  // إضافة فرد عائلة جديد
  Future<ApiResult<dynamic>> addMember(FamilyMemberModel member);

  // جلب قائمة أفراد العائلة
  Future<ApiResult<List<FamilyMemberModel>>> getFamily();

  // حذف فرد عائلة معين بواسطة الـ ID
  Future<ApiResult<dynamic>> deleteMember(int id);
}
