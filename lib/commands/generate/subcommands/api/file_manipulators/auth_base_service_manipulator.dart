import '../../../../../interfaces/file_manipulator.dart';

class AuthBaseServiceManipulator extends FileManipulator {
  @override
  String get name => 'AuthBaseService';

  @override
  String get path => 'lib/base/auth_base_service.dart';

  @override
  String content() {
    return r"""
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../model/api_response.dart';
import '../service/api_service.dart';
import '../service/logger_service.dart';
import '../service/storage/secure_storage_service.dart';
import '../service/storage/storage_service.dart';
import '../service/user_service.dart';
import 'api_base_service.dart';

enum ProviderTypes {
  none,
  email,
  google,
  apple,
}

abstract class AuthBaseService extends GetxService {
  String verificationToken = '';
  String verificationUid = '';

  final SecureStorageService storageService = Get.find<StorageService>().secure;

  final APIService apiService = Get.find<APIService>();

  final LoggerService logger = Get.find<LoggerService>();

  Map<String, dynamic> parseErrorMap(http.Response response) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Check if the user is logged in already.
  Future<ApiResponse> silentLogin() async {
    //load auth token from storage
    apiService.authenticationToken =
        await storageService.readString('token') ?? '';

    if (apiService.authenticationToken.isEmpty) {
      return ApiResponse(
        result: <String, dynamic>{},
        message: 'No stored token',
        status: -1,
        success: false,
      );
    }

    try {
      final ApiResponse response = await apiService.post(
        '/auth/token/verify/',
        omitBearerToken: true,
        body: <String, dynamic>{
          'token': apiService.authenticationToken,
        },
        log: true,
      );

      if (response.success) {
        await Get.find<UserService>().fetch();
      }

      return response;
    } catch (e) {
      // Endpoint failed:
      throw Exception('AuthService error on silent login - $e');
    }
  }

  // Log the user in. This function is not responsible for any navigation.
  Future<ApiResponse> login(
    String email,
    String password,
  ) async {
    try {
      final ApiResponse response = await apiService.post(
        'auth/login/',
        body: <String, dynamic>{
          'email': email,
          'password': password,
        },
        omitBearerToken: true,
      );
      if (response.status == 200) {
        apiService.authenticationToken = response.result?['access_token'] as String;

        await storageService.writeString(
          'token',
          response.result?['access_token'] as String,
        );

        await Get.find<UserService>().fetch();

        // Disconnect other providers
        await disconnectProviders();
      }

      return response;
    } catch (e) {
      // Endpoint failed:
      throw Exception('AuthService login endpoint failed - $e');
    }
  }

  // Log the user out. This function is not responsible for any navigation.
  Future<ApiResponse> logout() async {
    try {
      final ApiResponse response = await apiService.post(
        '/auth/logout/',
        contentType: 'application/json',
      );

      if (response.status == 200) {
        apiService.authenticationToken = '';
        // Disconnect other providers
        await disconnectProviders();
        await storageService.delete('token');
      } else {
        // Unexpected status code:
        throw Exception(
          'AuthService - error while logging out the user $response',
        );
      }
      return response;
    } catch (e) {
      // Endpoint failed:
      throw Exception('AuthService logout endpoint failed - $e');
    }
  }

  // Log the user out. This function is not responsible for any navigation.
  Future<ApiResponse> deleteUser() async {
    try {
      final ApiResponse response = await apiService.delete(
        '/users/delete/',
        contentType: 'application/json',
      );
      if (response.status == 200) {
        apiService.authenticationToken = '';
        await storageService.delete('token');
        // Disconnect other providers
        await disconnectProviders();
      } else {
        // Unexpected status code:
        // await Get.to<void>(() => HtmlDebug(res: response.body));
        throw Exception(
          'AuthService - error while logging out the user $response',
        );
      }
      return response;
    } catch (e) {
      // Endpoint failed:
      throw Exception('AuthService logout endpoint failed - $e');
    }
  }

  // Register a new user.
  Future<ApiResponse> registration(
    String email,
    String password,
    String username, {
    required bool biometrics,
  }) async {
    try {
      final ApiResponse response = await apiService.post(
        '/auth/registration/',
        omitBearerToken: true,
        contentType: 'application/json',
        body: <String, dynamic>{
          'email': email,
          'password1': password,
          'password2': password,
          'name': username,
        },
      );
      if (response.status == 201) {
        apiService.authenticationToken = response.result?['access_token'] as String;
        await storageService.writeString(
          'token',
          response.result?['access_token'] as String,
        );

        await Get.find<UserService>().fetch();

        // Disconnect other providers
        await disconnectProviders();
      }
      return response;
    } catch (e) {
      // Endpoint failed:
      throw Exception('AuthService registration endpoint failed - $e');
    }
  }

  // Initiate change password process. Send code to user.
  Future<ApiResponse> resetPassword(String email) async {
    try {
      final ApiResponse response = await apiService.post(
        '/auth/password/reset/',
        contentType: 'application/json',
        omitBearerToken: true,
        body: <String, dynamic>{
          'email': email,
        },
      );
      return response;
    } catch (e) {
      // Endpoint failed:
      throw Exception('AuthService reset password endpoint failed - $e');
    }
  }

  // Send code for verification.
  Future<ApiResponse> verifyCode(String code) async {
    try {
      final ApiResponse response = await apiService.post(
        '/auth/password/reset/code/validate/',
        contentType: 'application/json',
        omitBearerToken: true,
        body: <String, dynamic>{
          'code': code,
        },
      );
      if (response.status == 200) {
        try {
          /// save the verication token and uid
          verificationToken = response.result?['token'] as String;
          verificationUid = response.result?['code'] as String;
          logger.log(
            'AuthService - verification Token and UID: $verificationUid $verificationToken',
          );
          return response;
        } catch (error) {
          return response;
        }
      } else {
        // Unexpected status code:
        logger.log(
          'AuthService - $response',
        );
        return response;
      }
    } catch (e) {
      // Endpoint failed:
      throw Exception('AuthService validate code endpoint failed - $e');
    }
  }

  Future<ApiResponse> changePassword(
    String currentPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    try {
      final ApiResponse response = await apiService.post(
        '/auth/password/change/',
        contentType: 'application/json',
        body: <String, dynamic>{
          'old_password': currentPassword,
          'new_password1': newPassword,
          'new_password2': confirmNewPassword,
        },
      );

      if (response.status == 200) {
        return response;
      } else {
        return response;
      }
    } catch (e) {
      // Endpoint failed:
      throw Exception('AuthService change password endpoint failed - $e');
    }
  }

  // Once the code is validated, call this function to set the new password.
  Future<ApiResponse> changePasswordAfterReset(
    String password1,
    String password2,
  ) async {
    try {
      final ApiResponse response = await apiService.post(
        '/auth/password/reset/confirm/',
        contentType: 'application/json',
        omitBearerToken: true,
        body: <String, dynamic>{
          'new_password1': password1,
          'new_password2': password2,
          'uid': verificationUid,
          'token': verificationToken,
        },
      );
      if (response.status == 200) {
        return response;
      } else {
        // Unexpected status code:
        logger.log(
          'AuthService - $response',
        );
        return response;
      }
    } catch (e) {
      // Endpoint failed:
      throw Exception(
        'AuthService change password after reset endpoint failed - $e',
      );
    }
  }

  // Send email to user, to verify their email.
  Future<bool> sendVerificationEmail(String email) async {
    try {
      final ApiResponse response = await apiService.post(
        '/auth/registration/resend-email/',
        contentType: 'application/json',
        body: <String, dynamic>{
          'email': email,
        },
      );

      return response.status == 200;
    } catch (e) {
      throw Exception(
        'AuthService send verification email endpoint failed - $e',
      );
    }
  }

  Future<void> disconnectProviders() async {
    // Disconnect providers
  }
}
""";
  }
}
