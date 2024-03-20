String content() {
  return r"""
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../model/user.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'user_state_service.dart';

enum ProviderTypes {
  none,
  email,
  google,
  apple,
}

class AuthResponse {
  AuthResponse(this.info, this.success);

  final Map<String, dynamic> info;
  final bool success;
}

class AuthService extends GetxService {
  String authenticationToken = '';
  StorageService storageService = Get.put(StorageService());
  UserStateService userStateService = Get.put(UserStateService());
  APIService apiService = Get.put(APIService());
  
  String verificationToken = '';
  String verificationUid = '';

  void init() {
    debugPrint('AuthService - initializing...');
  }

  String unexpectedError(http.Response response) {
    return '[Status Code : ${response.statusCode}] ${response.body}';
  }

  Map<String, dynamic> parseErrorMap(http.Response response) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Check if the user is logged in already, and if so, perform a silent login and return true.
  Future<bool> silentLogin() async {
    try {
      switch (ProviderTypes.values[storageService.getInt('provider')]) {
        case ProviderTypes.email:
          return (await login(
            storageService.getString('email'),
            storageService.getString('password'),
          ))
              .success;
        case ProviderTypes.google:
          return false;
        case ProviderTypes.apple:
          return false;
        case ProviderTypes.none:
          return false;
      }
    } catch (e) {
      return false;
    }
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
          debugPrint('AuthService - authenticationToken: $authenticationToken');
          debugPrint(
            'AuthService - user logged in: ${userStateService.user.value.email}',
          );

          // Disconnect other providers
          await _disconnectProviders();

          await storageService.setString('email', email);
          await storageService.setString('password', password);
          await storageService.setInt('provider', ProviderTypes.email.index);

          return AuthResponse(
            <String, dynamic>{'success': 'Successfully logged in.'},
            true,
          );
        } catch (error) {
          // Request parsing went wrong:
          throw Exception('AuthService - error while parsing the user: $error');
        }
      } else {
        // Unexpected status code:
        debugPrint(
          'AuthService - ${response.statusCode} ${response.body}',
        );
        return AuthResponse(parseErrorMap(response), false);
      }
    } catch (e) {
      // Endpoint failed:
      throw Exception('AuthService login endpoint failed - $e');
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
        // Disconnect other providers
        await _disconnectProviders();
        await storageService.setString('email', '');
        await storageService.setString('password', '');
        await storageService.setInt('provider', ProviderTypes.none.index);
        return AuthResponse(
          <String, dynamic>{'success': 'Successful logout.'},
          true,
        );
      } else {
        // Unexpected status code:
        throw Exception(
          'AuthService - error while logging out the user ${unexpectedError(response)}',
        );
      }
    } catch (e) {
      // Endpoint failed:
      throw Exception('AuthService logout endpoint failed - $e');
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
          debugPrint('AuthService - authenticationToken: $authenticationToken');
          debugPrint(
            'AuthService - user registered in: ${userStateService.user.value.email}',
          );

          // Disconnect other providers
          await _disconnectProviders();

          await storageService.setString('email', email);
          await storageService.setString('password', password);
          await storageService.setBool('biometrics', value: biometrics);
          await storageService.setInt('provider', ProviderTypes.email.index);

          return AuthResponse(
            <String, dynamic>{'success': 'Successfully signed up.'},
            true,
          );
        } catch (error) {
          // Request parsing went wrong:
          throw Exception('AuthService - error while parsing the user: $error');
        }
      } else {
        // Unexpected status code:
        debugPrint(
          'AuthService - ${unexpectedError(response)}',
        );
        return AuthResponse(parseErrorMap(response), false);
      }
    } catch (e) {
      // Endpoint failed:
      throw Exception('AuthService registration endpoint failed - $e');
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
        return AuthResponse(
          <String, dynamic>{'success': 'Reset code sent.'},
          true,
        );
      } else {
        // Unexpected status code:
        debugPrint(
          'AuthService - ${unexpectedError(response)}',
        );
        return AuthResponse(parseErrorMap(response), false);
      }
    } catch (e) {
      // Endpoint failed:
      throw Exception('AuthService reset password endpoint failed - $e');
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
            'AuthService - verification Token and UID: $verificationUid $verificationToken',
          );
          return AuthResponse(
            <String, dynamic>{'success': 'Verification code is valid.'},
            true,
          );
        } catch (error) {
          return AuthResponse(
            <String, dynamic>{'error': error.toString()},
            false,
          );
        }
      } else {
        // Unexpected status code:
        debugPrint(
          'AuthService - ${unexpectedError(response)}',
        );
        return AuthResponse(parseErrorMap(response), false);
      }
    } catch (e) {
      // Endpoint failed:
      throw Exception('AuthService validate code endpoint failed - $e');
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
        return AuthResponse(
          <String, dynamic>{'success': 'Password changed.'},
          true,
        );
      } else {
        // Unexpected status code:
        debugPrint(
          'AuthService - ${unexpectedError(response)}',
        );
        return AuthResponse(parseErrorMap(response), false);
      }
    } catch (e) {
      // Endpoint failed:
      throw Exception(
        'AuthService change password after reset endpoint failed - $e',
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
        'AuthService send verification email endpoint failed - $e',
      );
    }
  }

  Future<void> _disconnectProviders() async {
    debugPrint('AuthService - disconnecting providers');
  }
}
""";
}
