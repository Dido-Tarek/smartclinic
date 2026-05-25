import 'package:equatable/equatable.dart';
import 'package:smartclinic/features/family_members/data/models/family_member_response_model.dart';

abstract class FamilyState extends Equatable {
  const FamilyState();

  @override
  List<Object?> get props => [];
}

// ── Shared ────────────────────────────────────────────────────────────────────

class FamilyInitial extends FamilyState {
  const FamilyInitial();
}

// ── Add family member ─────────────────────────────────────────────────────────

class AddFamilyMemberLoading extends FamilyState {
  const AddFamilyMemberLoading();
}

class AddFamilyMemberSuccess extends FamilyState {
  final AddFamilyMemberResponseModel member;

  const AddFamilyMemberSuccess(this.member);

  @override
  List<Object?> get props => [member];
}

class AddFamilyMemberFailure extends FamilyState {
  final String errorMessage;

  const AddFamilyMemberFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// ── Get my family ─────────────────────────────────────────────────────────────

class GetMyFamilyLoading extends FamilyState {
  const GetMyFamilyLoading();
}

class GetMyFamilySuccess extends FamilyState {
  final MyFamilyResponseModel response;

  const GetMyFamilySuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class GetMyFamilyFailure extends FamilyState {
  final String errorMessage;

  const GetMyFamilyFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// ── Remove family member ──────────────────────────────────────────────────────

class RemoveFamilyMemberLoading extends FamilyState {
  /// Carries the id being deleted so the UI can show a per-item spinner.
  final int removingId;

  const RemoveFamilyMemberLoading(this.removingId);

  @override
  List<Object?> get props => [removingId];
}

class RemoveFamilyMemberSuccess extends FamilyState {
  final RemoveFamilyMemberResponseModel response;

  /// The id that was just removed — lets the UI optimistically remove the tile.
  final int removedId;

  const RemoveFamilyMemberSuccess(this.response, this.removedId);

  @override
  List<Object?> get props => [response, removedId];
}

class RemoveFamilyMemberFailure extends FamilyState {
  final String errorMessage;

  const RemoveFamilyMemberFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
