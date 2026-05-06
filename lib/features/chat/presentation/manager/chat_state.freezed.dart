// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatState()';
}


}

/// @nodoc
class $ChatStateCopyWith<$Res>  {
$ChatStateCopyWith(ChatState _, $Res Function(ChatState) __);
}


/// Adds pattern-matching-related methods to [ChatState].
extension ChatStatePatterns on ChatState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _MessageSent value)?  messageSent,TResult Function( _HistoryLoaded value)?  historyLoaded,TResult Function( _MarkedAsSeen value)?  markedAsSeen,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _MessageSent() when messageSent != null:
return messageSent(_that);case _HistoryLoaded() when historyLoaded != null:
return historyLoaded(_that);case _MarkedAsSeen() when markedAsSeen != null:
return markedAsSeen(_that);case _Error() when error != null:
return error(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _MessageSent value)  messageSent,required TResult Function( _HistoryLoaded value)  historyLoaded,required TResult Function( _MarkedAsSeen value)  markedAsSeen,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _MessageSent():
return messageSent(_that);case _HistoryLoaded():
return historyLoaded(_that);case _MarkedAsSeen():
return markedAsSeen(_that);case _Error():
return error(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _MessageSent value)?  messageSent,TResult? Function( _HistoryLoaded value)?  historyLoaded,TResult? Function( _MarkedAsSeen value)?  markedAsSeen,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _MessageSent() when messageSent != null:
return messageSent(_that);case _HistoryLoaded() when historyLoaded != null:
return historyLoaded(_that);case _MarkedAsSeen() when markedAsSeen != null:
return markedAsSeen(_that);case _Error() when error != null:
return error(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( dynamic data)?  messageSent,TResult Function( List<MessageModel> messages)?  historyLoaded,TResult Function( dynamic data)?  markedAsSeen,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _MessageSent() when messageSent != null:
return messageSent(_that.data);case _HistoryLoaded() when historyLoaded != null:
return historyLoaded(_that.messages);case _MarkedAsSeen() when markedAsSeen != null:
return markedAsSeen(_that.data);case _Error() when error != null:
return error(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( dynamic data)  messageSent,required TResult Function( List<MessageModel> messages)  historyLoaded,required TResult Function( dynamic data)  markedAsSeen,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _MessageSent():
return messageSent(_that.data);case _HistoryLoaded():
return historyLoaded(_that.messages);case _MarkedAsSeen():
return markedAsSeen(_that.data);case _Error():
return error(_that.message);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( dynamic data)?  messageSent,TResult? Function( List<MessageModel> messages)?  historyLoaded,TResult? Function( dynamic data)?  markedAsSeen,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _MessageSent() when messageSent != null:
return messageSent(_that.data);case _HistoryLoaded() when historyLoaded != null:
return historyLoaded(_that.messages);case _MarkedAsSeen() when markedAsSeen != null:
return markedAsSeen(_that.data);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements ChatState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatState.initial()';
}


}




/// @nodoc


class _Loading implements ChatState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatState.loading()';
}


}




/// @nodoc


class _MessageSent implements ChatState {
  const _MessageSent(this.data);
  

 final  dynamic data;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageSentCopyWith<_MessageSent> get copyWith => __$MessageSentCopyWithImpl<_MessageSent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageSent&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'ChatState.messageSent(data: $data)';
}


}

/// @nodoc
abstract mixin class _$MessageSentCopyWith<$Res> implements $ChatStateCopyWith<$Res> {
  factory _$MessageSentCopyWith(_MessageSent value, $Res Function(_MessageSent) _then) = __$MessageSentCopyWithImpl;
@useResult
$Res call({
 dynamic data
});




}
/// @nodoc
class __$MessageSentCopyWithImpl<$Res>
    implements _$MessageSentCopyWith<$Res> {
  __$MessageSentCopyWithImpl(this._self, this._then);

  final _MessageSent _self;
  final $Res Function(_MessageSent) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(_MessageSent(
freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

/// @nodoc


class _HistoryLoaded implements ChatState {
  const _HistoryLoaded(final  List<MessageModel> messages): _messages = messages;
  

 final  List<MessageModel> _messages;
 List<MessageModel> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}


/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistoryLoadedCopyWith<_HistoryLoaded> get copyWith => __$HistoryLoadedCopyWithImpl<_HistoryLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistoryLoaded&&const DeepCollectionEquality().equals(other._messages, _messages));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_messages));

@override
String toString() {
  return 'ChatState.historyLoaded(messages: $messages)';
}


}

/// @nodoc
abstract mixin class _$HistoryLoadedCopyWith<$Res> implements $ChatStateCopyWith<$Res> {
  factory _$HistoryLoadedCopyWith(_HistoryLoaded value, $Res Function(_HistoryLoaded) _then) = __$HistoryLoadedCopyWithImpl;
@useResult
$Res call({
 List<MessageModel> messages
});




}
/// @nodoc
class __$HistoryLoadedCopyWithImpl<$Res>
    implements _$HistoryLoadedCopyWith<$Res> {
  __$HistoryLoadedCopyWithImpl(this._self, this._then);

  final _HistoryLoaded _self;
  final $Res Function(_HistoryLoaded) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? messages = null,}) {
  return _then(_HistoryLoaded(
null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<MessageModel>,
  ));
}


}

/// @nodoc


class _MarkedAsSeen implements ChatState {
  const _MarkedAsSeen(this.data);
  

 final  dynamic data;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarkedAsSeenCopyWith<_MarkedAsSeen> get copyWith => __$MarkedAsSeenCopyWithImpl<_MarkedAsSeen>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarkedAsSeen&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'ChatState.markedAsSeen(data: $data)';
}


}

/// @nodoc
abstract mixin class _$MarkedAsSeenCopyWith<$Res> implements $ChatStateCopyWith<$Res> {
  factory _$MarkedAsSeenCopyWith(_MarkedAsSeen value, $Res Function(_MarkedAsSeen) _then) = __$MarkedAsSeenCopyWithImpl;
@useResult
$Res call({
 dynamic data
});




}
/// @nodoc
class __$MarkedAsSeenCopyWithImpl<$Res>
    implements _$MarkedAsSeenCopyWith<$Res> {
  __$MarkedAsSeenCopyWithImpl(this._self, this._then);

  final _MarkedAsSeen _self;
  final $Res Function(_MarkedAsSeen) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(_MarkedAsSeen(
freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

/// @nodoc


class _Error implements ChatState {
  const _Error({required this.message});
  

 final  String message;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ChatState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $ChatStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
