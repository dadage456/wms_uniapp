import 'package:dio/dio.dart';
import 'package:wms_app/modules/account/models/account_profile.dart';
import 'package:wms_app/services/api_response_handler.dart';
import 'package:wms_app/services/api_service.dart';
import 'package:wms_app/services/user_manager.dart';

class AccountService {
  AccountService({
    required Dio dio,
    required ApiService apiService,
    required UserManager userManager,
  })  : _dio = dio,
        _apiService = apiService,
        _userManager = userManager;

  final Dio _dio;
  final ApiService _apiService;
  final UserManager _userManager;

  Future<AccountProfile> fetchProfile() async {
    final response = await _dio.get('/system/user/profile');
    final profileJson = ApiResponseHandler.handleResponse<Map<String, dynamic>>(
      response: response,
      dataExtractor: (data) {
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw Exception('响应数据格式错误');
      },
    );

    return AccountProfile.fromJson(profileJson);
  }

  Future<AccountProfile> updateProfile(AccountProfileUpdateRequest request) async {
    final response = await _dio.put(
      '/system/user/profile',
      data: request.toJson(),
    );
    _ensureSuccess(response);

    // 更新用户信息缓存
    final freshUserInfo = await _apiService.getUserInfo();
    _userManager.updateUserInfo(freshUserInfo);

    // 返回最新的用户档案
    return fetchProfile();
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await _dio.put(
      '/system/user/profile/updatePwd',
      queryParameters: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
    _ensureSuccess(response);

    await _userManager.updateStoredCredentials(password: newPassword);
  }

  void _ensureSuccess(Response<dynamic> response) {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('响应格式错误');
    }
    final code = data['code'] as int?;
    if (code != 200) {
      final message = data['msg']?.toString() ?? '请求失败';
      throw Exception(message);
    }
  }
}
