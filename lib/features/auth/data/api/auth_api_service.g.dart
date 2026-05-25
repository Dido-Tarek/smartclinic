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
  Future<dynamic> registerDoctor({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String gender,
    required String birthDate,
    required String phoneNumber,
    required String address,
    required String latitude,
    required String longitude,
    required String specialization,
    required File nationalIdFront,
    required File nationalIdBack,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.fields.add(MapEntry('FullName', name));
    _data.fields.add(MapEntry('Email', email));
    _data.fields.add(MapEntry('Password', password));
    _data.fields.add(MapEntry('ConfirmPassword', confirmPassword));
    _data.fields.add(MapEntry('Gender', gender));
    _data.fields.add(MapEntry('BirthDate', birthDate));
    _data.fields.add(MapEntry('PhoneNumber', phoneNumber));
    _data.fields.add(MapEntry('Address', address));
    _data.fields.add(MapEntry('Latitude', latitude));
    _data.fields.add(MapEntry('Longitude', longitude));
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
            'api/Auth/register-doctor',
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
  Future<dynamic> registerClinicAdmin({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String gender,
    required String birthDate,
    required String phoneNumber,
    required String address,
    required String latitude,
    required String longitude,
    required String specialization,
    required File nationalIdFront,
    required File nationalIdBack,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.fields.add(MapEntry('FullName', name));
    _data.fields.add(MapEntry('Email', email));
    _data.fields.add(MapEntry('Password', password));
    _data.fields.add(MapEntry('ConfirmPassword', confirmPassword));
    _data.fields.add(MapEntry('Gender', gender));
    _data.fields.add(MapEntry('BirthDate', birthDate));
    _data.fields.add(MapEntry('PhoneNumber', phoneNumber));
    _data.fields.add(MapEntry('Address', address));
    _data.fields.add(MapEntry('Latitude', latitude));
    _data.fields.add(MapEntry('Longitude', longitude));
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
            'api/Auth/register-clinic-admin',
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
  Future<dynamic> uploadVerificationDocs({
    required String doctorId,
    required File syndicatCard,
    required File license,
    required File nationalId,
    required File specializationCert,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.files.add(
      MapEntry(
        'syndicatCard',
        MultipartFile.fromFileSync(
          syndicatCard.path,
          filename: syndicatCard.path.split(Platform.pathSeparator).last,
        ),
      ),
    );
    _data.files.add(
      MapEntry(
        'license',
        MultipartFile.fromFileSync(
          license.path,
          filename: license.path.split(Platform.pathSeparator).last,
        ),
      ),
    );
    _data.files.add(
      MapEntry(
        'nationalId',
        MultipartFile.fromFileSync(
          nationalId.path,
          filename: nationalId.path.split(Platform.pathSeparator).last,
        ),
      ),
    );
    _data.files.add(
      MapEntry(
        'specializationCert',
        MultipartFile.fromFileSync(
          specializationCert.path,
          filename: specializationCert.path.split(Platform.pathSeparator).last,
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
            'api/Auth/upload-verification-docs/${doctorId}',
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
  Future<List<dynamic>> getPendingDoctors() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<List<dynamic>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            'api/Admin/pending-doctors',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<List<dynamic>>(_options);
    final _value = _result.data ?? <dynamic>[];
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

  @override
  Future<dynamic> uploadOwnerDocs({
    required String userId,
    required File medicalLicense,
    required File commerialRegister,
    required File taxCard,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.files.add(
      MapEntry(
        'medicalLicense',
        MultipartFile.fromFileSync(
          medicalLicense.path,
          filename: medicalLicense.path.split(Platform.pathSeparator).last,
        ),
      ),
    );
    _data.files.add(
      MapEntry(
        'commercialRegister',
        MultipartFile.fromFileSync(
          commerialRegister.path,
          filename: commerialRegister.path.split(Platform.pathSeparator).last,
        ),
      ),
    );
    _data.files.add(
      MapEntry(
        'taxCard',
        MultipartFile.fromFileSync(
          taxCard.path,
          filename: taxCard.path.split(Platform.pathSeparator).last,
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
            'api/Auth/upload-owner-docs/${userId}',
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
  Future<dynamic> claimClinicOwnership({
    required int clinicId,
    required File legalDoc1,
    required File legalDoc2,
    required File legalDoc3,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.files.add(
      MapEntry(
        'LegalDoc1',
        MultipartFile.fromFileSync(
          legalDoc1.path,
          filename: legalDoc1.path.split(Platform.pathSeparator).last,
        ),
      ),
    );
    _data.files.add(
      MapEntry(
        'LegalDoc2',
        MultipartFile.fromFileSync(
          legalDoc2.path,
          filename: legalDoc2.path.split(Platform.pathSeparator).last,
        ),
      ),
    );
    _data.files.add(
      MapEntry(
        'LegalDoc3',
        MultipartFile.fromFileSync(
          legalDoc3.path,
          filename: legalDoc3.path.split(Platform.pathSeparator).last,
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
            'api/Clinics/claim-ownership/${clinicId}',
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
