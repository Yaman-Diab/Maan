// -------------------------
// API Client
// -------------------------

import 'package:dio/dio.dart';

import 'api_exception.dart';

enum ApiMethod { get, post, put, patch, delete }

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<dynamic> request({
    required String endpoint,
    required ApiMethod method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      late final Response response;

      switch (method) {
        case ApiMethod.get:
          response = await _dio.get(
            endpoint,
            queryParameters: queryParameters,
            options: options,
          );
          break;

        case ApiMethod.post:
          response = await _dio.post(
            endpoint,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          break;

        case ApiMethod.put:
          response = await _dio.put(
            endpoint,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          break;

        case ApiMethod.patch:
          response = await _dio.patch(
            endpoint,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          break;

        case ApiMethod.delete:
          response = await _dio.delete(
            endpoint,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          break;
      }

      final statusCode = response.statusCode ?? 0;

      if (statusCode >= 200 && statusCode < 300) {
        return response.data ?? {};
      }

      throw ApiException.fromResponse(response);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
