import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_request_flags.dart';
import 'login/models/login_payload.dart';
import 'login/models/login_response.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository(this.apiClient);

  Future<LoginResponse> login(LoginPayload payload) async {
    final response = await apiClient.request(
      endpoint: ApiEndpoints.login,
      method: ApiMethod.post,
      data: payload.toMap(),
      options: Options(
        extra: {
          ApiRequestFlags.skipAuthHeader: true,
          ApiRequestFlags.skipAuthRefresh: true,
        },
      ),
    );

    if (response is Map<String, dynamic>) {
      return LoginResponse.fromMap(response);
    }

    if (response is Map) {
      return LoginResponse.fromMap(Map<String, dynamic>.from(response));
    }

    throw FormatException('Unexpected login response format');
  }
}
