import 'package:project_initialization_tool/commands/generate/subcommands/api/code/constants.dart';

content(String projectName) {
  projectName = projectName.capitalize();
  return """
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../model/user.dart';
import 'api_service.dart';
import '../service/storage_service.dart';
import 'user_state_service.dart';
import 'package:http/http.dart' as http;

enum ProviderTypes {
  none,
  email,
  google,
  apple,
}

class AuthResponse {
  AuthResponse(this.message, this.success);
  final String message;
  final bool success;
}

class AuthService extends GetxService {
  String authenticationToken = '';
  StorageService storageService = Get.put(StorageService());
  UserStateService userStateService = Get.put(UserStateService());
  APIService apiService = Get.put(APIService());

  String verificationToken = '';
  String verificationUid = '';

  String parseError(http.Response response) {
    return '[Status Code : \${response.statusCode}] \${response.body}';
  }

  // Log the user in. This function is not responsible for any navigation.
  Future<AuthResponse> login(
    String email,
    String password,
  ) async {
    try {
      final http.Response response = await apiService.post(
        'auth/login/',
        body: <String, dynamic>{
          'email': email,
          'password': password,
        },
        omitBearerToken: true,
      );

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> userMap =
              jsonDecode(response.body) as Map<String, dynamic>;
          userStateService.user.value =
              User.fromJson(userMap['user'] as Map<String, dynamic>);

          /// save the token
          authenticationToken = userMap['access_token'] as String;
          debugPrint('AuthService - authenticationToken: \$authenticationToken');
          debugPrint(
            'AuthService - user logged in: \${userStateService.user.value.email}',
          );

          await storageService.setString('email', email);
          await storageService.setString('password', password);
          await storageService.setInt('provider', ProviderTypes.email.index);

          return AuthResponse('Successfully logged in.', true);
        } catch (error) {
          // Request parsing went wrong:
          throw Exception('AuthService - error while parsing the user: \$error');
        }
      } else {
        // Unexpected status code:
        debugPrint(
          'AuthService - \${parseError(response)}',
        );
        return AuthResponse(parseError(response), false);
      }
    } catch (e) {
      // Endpoint failed:
      throw Exception('AuthService login endpoint failed - \$e');
    }
  }

  // Log the user out. This function is not responsible for any navigation.
  Future<AuthResponse> logout() async {
    try {
      final http.Response response = await apiService.post(
        '/auth/logout/',
        contentType: 'application/json',
      );
      if (response.statusCode == 200) {
        authenticationToken = '';
        userStateService.clear();
        await storageService.setString('email', '');
        await storageService.setString('password', '');
        await storageService.setInt('provider', ProviderTypes.none.index);
        return AuthResponse('Successful logout.', true);
      } else {
        // Unexpected status code:
        throw Exception(
          'AuthService - error while logging out the user \${parseError(response)}',
        );
      }
    } catch (e) {
      // Endpoint failed:
      throw Exception('AuthService logout endpoint failed - \$e');
    }
  }

  // Register a new user.
  Future<AuthResponse> registration(
    String email,
    String password,
    String username, {
    required bool biometrics,
  }) async {
    try {
      final http.Response response = await apiService.post(
        '/auth/registration/',
        omitBearerToken: true,
        contentType: 'application/json',
        body: <String, dynamic>{
          'email': email,
          'password1': password,
          'password2': password,
          'username': username,
        },
      );

      if (response.statusCode == 201) {
        try {
          final Map<String, dynamic> userMap =
              jsonDecode(response.body) as Map<String, dynamic>;
          userStateService.user.value =
              User.fromJson(userMap['user'] as Map<String, dynamic>);

          /// save the token
          authenticationToken = userMap['access_token'] as String;
          debugPrint('AuthService - authenticationToken: \$authenticationToken');
          debugPrint(
            'AuthService - user registered in: \${userStateService.user.value.email}',
          );

          await storageService.setString('email', email);
          await storageService.setString('password', password);
          await storageService.setBool('biometrics', value: biometrics);
          await storageService.setInt('provider', ProviderTypes.email.index);

          return AuthResponse('Successfully signed up.', true);
        } catch (error) {
          // Request parsing went wrong:
          throw Exception('AuthService - error while parsing the user: \$error');
        }
      } else {
        // Unexpected status code:
        debugPrint(
          'AuthService - \${parseError(response)}',
        );
        return AuthResponse(parseError(response), false);
      }
    } catch (e) {
      // Endpoint failed:
      throw Exception('AuthService registration endpoint failed - \$e');
    }
  }

  // Initiate change password process. Send code to user.
  Future<AuthResponse> resetPassword(String email) async {
    try {
      final http.Response response = await apiService.post(
        '/auth/password/reset/',
        contentType: 'application/json',
        omitBearerToken: true,
        body: <String, dynamic>{
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        debugPrint('AuthService - Reset Code Sent');
        return AuthResponse('Reset code sent.', true);
      } else {
        // Unexpected status code:
        debugPrint(
          'AuthService - \${parseError(response)}',
        );
        return AuthResponse(parseError(response), false);
      }
    } catch (e) {
      // Endpoint failed:
      throw Exception('AuthService reset password endpoint failed - \$e');
    }
  }

  // Send code for verification.
  Future<AuthResponse> verifyCode(String code) async {
    try {
      final http.Response response = await apiService.post(
        '/auth/password/reset/code/validate/',
        contentType: 'application/json',
        omitBearerToken: true,
        body: <String, dynamic>{
          'code': code,
        },
      );

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> userMap =
              jsonDecode(response.body) as Map<String, dynamic>;

          /// save the verication token and uid
          verificationToken = userMap['token'] as String;
          verificationUid = userMap['code'] as String;
          debugPrint(
            'AuthService - verification Token and UID: \$verificationUid \$verificationToken',
          );
          return AuthResponse('Verification code is valid.', true);
        } catch (error) {
          return AuthResponse(error.toString(), false);
        }
      } else {
        // Unexpected status code:
        debugPrint(
          'AuthService - \${parseError(response)}',
        );
        return AuthResponse(parseError(response), false);
      }
    } catch (e) {
      // Endpoint failed:
      throw Exception('AuthService validate code endpoint failed - \$e');
    }
  }

  // Once the code is validated, call this function to set the new password.
  Future<AuthResponse> changePasswordAfterReset(
    String password1,
    String password2,
  ) async {
    try {
      final http.Response response = await apiService.post(
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

      if (response.statusCode == 200) {
        return AuthResponse('Password changed.', true);
      } else {
        // Unexpected status code:
        debugPrint(
          'AuthService - \${parseError(response)}',
        );
        return AuthResponse(parseError(response), false);
      }
    } catch (e) {
      // Endpoint failed:
      throw Exception(
        'AuthService change password after reset endpoint failed - \$e',
      );
    }
  }

  // Send email to user, to verify their email.
  Future<bool> sendVerificationEmail() async {
    try {
      final http.Response response = await apiService.post(
        '/auth/registration/resend-email/',
        contentType: 'application/json',
        body: <String, dynamic>{
          'email': userStateService.user.value.email,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception(
        'AuthService send verification email endpoint failed - \$e',
      );
    }
  }
}""";
}
