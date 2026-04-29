// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinic_api_service.dart';

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main

class _ClinicApiService implements ClinicApiService {
  _ClinicApiService(this._dio, {this.baseUrl, this.errorLogger}) {
    baseUrl ??= 'http://smartclinicccc.runasp.net/';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<dynamic> addClinic(
    String name,
    String address,
    String phoneNumber,
    String city,
    String area,
    bool isOwner, {
    MultipartFile? clinicImage,
    double? latitude,
    double? longitude,
    String? specialization,
    int? sessionDuration,
    MultipartFile? legalDocument1,
    MultipartFile? legalDocument2,
    MultipartFile? legalDocument3,
    double? clinicFee,
    double? onlineFee,
    double? homeVisitFee,
    double? followUpFee,
    double? emergencyFee,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.fields.add(MapEntry('Name', name));
    _data.fields.add(MapEntry('Address', address));
    _data.fields.add(MapEntry('PhoneNumber', phoneNumber));
    _data.fields.add(MapEntry('City', city));
    _data.fields.add(MapEntry('Area', area));
    _data.fields.add(MapEntry('IsOwner', isOwner.toString()));
    if (clinicImage != null) {
      _data.files.add(MapEntry('ClinicImage', clinicImage));
    }
    if (latitude != null) {
      _data.fields.add(MapEntry('Latitude', latitude.toString()));
    }
    if (longitude != null) {
      _data.fields.add(MapEntry('Longitude', longitude.toString()));
    }
    if (specialization != null) {
      _data.fields.add(MapEntry('Specialization', specialization));
    }
    if (sessionDuration != null) {
      _data.fields.add(MapEntry('SessionDuration', sessionDuration.toString()));
    }
    if (legalDocument1 != null) {
      _data.files.add(MapEntry('LegalDocument1', legalDocument1));
    }
    if (legalDocument2 != null) {
      _data.files.add(MapEntry('LegalDocument2', legalDocument2));
    }
    if (legalDocument3 != null) {
      _data.files.add(MapEntry('LegalDocument3', legalDocument3));
    }
    if (clinicFee != null) {
      _data.fields.add(MapEntry('ClinicFee', clinicFee.toString()));
    }
    if (onlineFee != null) {
      _data.fields.add(MapEntry('OnlineFee', onlineFee.toString()));
    }
    if (homeVisitFee != null) {
      _data.fields.add(MapEntry('HomeVisitFee', homeVisitFee.toString()));
    }
    if (followUpFee != null) {
      _data.fields.add(MapEntry('FollowUpFee', followUpFee.toString()));
    }
    if (emergencyFee != null) {
      _data.fields.add(MapEntry('EmergencyFee', emergencyFee.toString()));
    }
    final _options = _setStreamType<dynamic>(
      Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'multipart/form-data',
          )
          .compose(
            _dio.options,
            'api/clinics/add',
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
