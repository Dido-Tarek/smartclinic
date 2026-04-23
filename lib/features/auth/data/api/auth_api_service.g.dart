// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_api_service.dart';

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main

class _AuthApiService implements AuthApiService {
  _AuthApiService(this._dio, {this.baseUrl, this.errorLogger}) {
    baseUrl ??= 'http://smartclinicccc.runasp.net/';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<dynamic> registerPatient({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
    required String address,
    required String birthDate,
    required String gender,
    required String bloodGroup,
    required File nationalIdFront,
    required File nationalIdBack,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.fields.add(MapEntry('FullName', fullName));
    _data.fields.add(MapEntry('Email', email));
    _data.fields.add(MapEntry('Password', password));
    _data.fields.add(MapEntry('ConfirmPassword', confirmPassword));
    _data.fields.add(MapEntry('PhoneNumber', phoneNumber));
    _data.fields.add(MapEntry('Address', address));
    _data.fields.add(MapEntry('BirthDate', birthDate));
    _data.fields.add(MapEntry('Gender', gender));
    _data.fields.add(MapEntry('BloodGroup', bloodGroup));
    _data.files.add(
      MapEntry(
        'NationalIdFront',
        MultipartFile.fromFileSync(
          nationalIdFront.path,
          filename: nationalIdFront.path.split(Platform.pathSeparator).last,
        ),
      ),
    );
    _data.files.add(
      MapEntry(
        'NationalIdBack',
        MultipartFile.fromFileSync(
          nationalIdBack.path,
          filename: nationalIdBack.path.split(Platform.pathSeparator).last,
        ),
      ),
    );
    final _options = _setStreamType<dynamic>(
      Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'multipart/form-data',
          )
          .compose(
            _dio.options,
            'api/Auth/register-patient',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    return _value;
  }

  @override
  Future<dynamic> registerFacility({
    required String name,
    required String email,
    required String password,
    String confirmPassword = '',
    required dynamic gender,
    required dynamic birthDate,
    required String phoneNumber,
    required String address,
    required String specialization,
    required File nationalIdFront,
    required File nationalIdBack,
    String url = '',
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.fields.add(MapEntry('FullName', name));
    _data.fields.add(MapEntry('Email', email));
    _data.fields.add(MapEntry('Password', password));
    _data.fields.add(MapEntry('ConfirmPassword', confirmPassword));
    _data.fields.add(MapEntry('Gender', gender.toString()));
    _data.fields.add(MapEntry('BirthDate', birthDate.toString()));
    _data.fields.add(MapEntry('PhoneNumber', phoneNumber));
    _data.fields.add(MapEntry('Address', address));
    _data.fields.add(MapEntry('Specialization', specialization));
    _data.files.add(
      MapEntry(
        'NationalidFront',
        MultipartFile.fromFileSync(
          nationalIdFront.path,
          filename: nationalIdFront.path.split(Platform.pathSeparator).last,
        ),
      ),
    );
    _data.files.add(
      MapEntry(
        'NationalidBack',
        MultipartFile.fromFileSync(
          nationalIdBack.path,
          filename: nationalIdBack.path.split(Platform.pathSeparator).last,
        ),
      ),
    );
    final _options = _setStreamType<dynamic>(
      Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'multipart/form-data',
          )
          .compose(
            _dio.options,
            url,
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    return _value;
  }

  @override
  Future<dynamic> login(LoginRequestModel loginRequestBody) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(loginRequestBody.toJson());
    final _options = _setStreamType<dynamic>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            'api/Auth/Login',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}

// dart format on
