import '../../../../../interfaces/file_manipulator.dart';
import '../../../../../util/util.dart';

class AuthServiceBaseManipulator extends FileManipulator {
  @override
  String get name => 'AuthServiceBase';

  @override
  String get path => 'lib/base/auth_service_base.dart';

  Future<void> createGoogleSignIn() async {
    await removeTextFromFile(
      path,
      googleDefaultSwitchCase,
    );

    await addLinesAfterLineInFile(
      path,
      <String, List<String>>{
        '// https://saynode.ch': <String>[googleImports()],
        'abstract class AuthServiceBase extends GetxService {': <String>[
          googleInitialization(),
        ],
        'void init() {': <String>[googleInitContent()],
        'Future<void> _disconnectProviders() async {': <String>[
          googleDisconnect(),
        ],
      },
    );

    await addLinesBeforeLineInFile(
      path,
      <String, List<String>>{
        'Future<void> _disconnectProviders() async {': <String>[
          googleSignIn(),
        ],
        'case ProviderTypes.none:': <String>[googleSwitchCase()],
      },
    );
  }

  Future<void> createAppleSignIn() async {
    await removeTextFromFile(path, appleDefaultSwitchCase);

    await addLinesAfterLineInFile(
      path,
      <String, List<String>>{
        '// https://saynode.ch': <String>[appleImports()],
        'Future<void> _disconnectProviders() async {': <String>[
          appleDisconnect(),
        ],
      },
    );

    await addLinesBeforeLineInFile(
      path,
      <String, List<String>>{
        'Future<void> _disconnectProviders() async {': <String>[appleSignIn()],
        'case ProviderTypes.none:': <String>[appleSwitchCase()],
      },
    );
  }

  Future<void> removeGoogleSignIn() async {
    await removeTextFromFile(path, googleImports());
    await removeTextFromFile(path, googleInitialization());
    await removeTextFromFile(path, googleInitContent());
    await removeTextFromFile(path, googleDisconnect());
    await removeTextFromFile(path, googleSignIn());
    await removeTextFromFile(path, googleSwitchCase());
    await addLinesBeforeLineInFile(
      path,
      <String, List<String>>{
        'case ProviderTypes.none:': <String>[googleDefaultSwitchCase],
      },
    );
  }

  Future<void> removeAppleSignIn() async {
    await removeTextFromFile(path, appleImports());
    await removeTextFromFile(path, appleDisconnect());
    await removeTextFromFile(path, appleSignIn());
    await removeTextFromFile(path, appleSwitchCase());
    await addLinesBeforeLineInFile(
      path,
      <String, List<String>>{
        'case ProviderTypes.none:': <String>[appleDefaultSwitchCase],
      },
    );
  }

  @override
  String content() {
    return r"""
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../model/auth_result.dart';
import '../service/api_service.dart';
import '../service/logger_service.dart';
import '../service/storage/secure_storage_service.dart';
import '../service/storage/storage_service.dart';

enum ProviderTypes {
  none,
  email,
  google,
  apple,
}

abstract class AuthServiceBase extends GetxService {
  String verificationToken = '';
  String verificationUid = '';

  final SecureStorageService _storageService =
      Get.find<StorageService>().secure;

  final APIService apiService = Get.find<APIService>();

  final LoggerService logger = Get.find<LoggerService>();

  Map<String, dynamic> parseErrorMap(http.Response response) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Check if the user is logged in already.
  Future<AuthResponse> silentLogin() async {
    //load auth token from storage
    apiService.authenticationToken = await _storageService.readString('token');

    try {
      final http.Response response = await apiService.post(
        '/auth/token/verify/',
        omitBearerToken: true,
        body: <String, dynamic>{
          'token': apiService.authenticationToken,
        },
        log: true,
      );

      final AuthResponse authResult = AuthResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      return authResult;
    } catch (e) {
      // Endpoint failed:
      throw Exception('AuthService error on silent login - $e');
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
      final AuthResponse authResult = AuthResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      if (authResult.status == 200) {
        apiService.authenticationToken = authResult.accessToken;

        await _storageService.writeString(
          'token',
          authResult.accessToken,
        );

        // Disconnect other providers
        await _disconnectProviders();
      }

      return authResult;
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
      final AuthResponse authResult = AuthResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );

      if (response.statusCode == 200) {
        apiService.authenticationToken = '';
        // Disconnect other providers
        await _disconnectProviders();
        await _storageService.delete('token');
      } else {
        // Unexpected status code:
        throw Exception(
          'AuthService - error while logging out the user $authResult',
        );
      }
      return authResult;
    } catch (e) {
      // Endpoint failed:
      throw Exception('AuthService logout endpoint failed - $e');
    }
  }

  // Log the user out. This function is not responsible for any navigation.
  Future<AuthResponse> deleteUser() async {
    try {
      final http.Response response = await apiService.delete(
        '/users/delete/',
        contentType: 'application/json',
      );
      final AuthResponse authResult = AuthResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      if (response.statusCode == 200) {
        apiService.authenticationToken = '';
        await _storageService.delete('token');
        // Disconnect other providers
        await _disconnectProviders();
      } else {
        // Unexpected status code:
        // await Get.to<void>(() => HtmlDebug(res: response.body));
        throw Exception(
          'AuthService - error while logging out the user $authResult',
        );
      }
      return authResult;
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
      final AuthResponse authResult = AuthResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      if (response.statusCode == 201) {
        apiService.authenticationToken = authResult.accessToken;
        await _storageService.writeString(
          'token',
          authResult.accessToken,
        );

        // Disconnect other providers
        await _disconnectProviders();
      }
      return authResult;
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
      final AuthResponse authResult = AuthResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      return authResult;
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
      final AuthResponse authResult = AuthResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> userMap =
              jsonDecode(response.body) as Map<String, dynamic>;

          /// save the verication token and uid
          verificationToken = userMap['token'] as String;
          verificationUid = userMap['code'] as String;
          logger.log(
            'AuthService - verification Token and UID: $verificationUid $verificationToken',
          );
          return authResult;
        } catch (error) {
          return authResult;
        }
      } else {
        // Unexpected status code:
        logger.log(
          'AuthService - $authResult',
        );
        return authResult;
      }
    } catch (e) {
      // Endpoint failed:
      throw Exception('AuthService validate code endpoint failed - $e');
    }
  }

  Future<AuthResponse> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final http.Response response = await apiService.post(
        '/auth/password/change/',
        contentType: 'application/json',
        body: <String, dynamic>{
          'old_password': currentPassword,
          'new_password1': newPassword,
          'new_password2': confirmNewPassword,
        },
      );
      final AuthResponse authResult = AuthResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );

      if (response.statusCode == 200) {
        return authResult;
      } else {
        return authResult;
      }
    } catch (e) {
      // Endpoint failed:
      throw Exception('AuthService change password endpoint failed - $e');
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
      final AuthResponse authResult = AuthResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      if (response.statusCode == 200) {
        return authResult;
      } else {
        // Unexpected status code:
        logger.log(
          'AuthService - $authResult',
        );
        return authResult;
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
      final http.Response response = await apiService.post(
        '/auth/registration/resend-email/',
        contentType: 'application/json',
        body: <String, dynamic>{
          'email': email,
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
    logger.log('AuthService - disconnecting providers');
  }
}

""";
  }

  String appleImports() => """
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/services.dart';""";

  String appleDisconnect() => '''
    // TODO: Disconnect from apple
''';

  String appleSignIn() => r"""
  // Login with Apple.
  Future<AuthResponse> appleSignIn({
    String? authorizationCode,
    String? identityToken,
  }) async {
    try {
      if (authorizationCode != null &&
          identityToken != null &&
          authorizationCode.isNotEmpty &&
          identityToken.isNotEmpty) {
        debugPrint('Signing in with Apple silently');
      } else {
        final AuthorizationCredentialAppleID credential =
            await SignInWithApple.getAppleIDCredential(
          scopes: <AppleIDAuthorizationScopes>[
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          webAuthenticationOptions: WebAuthenticationOptions(
            clientId: '', // TODO
            redirectUri:
                // For web your redirect URI needs to be the host of the "current page",
                // while for Android you will be using the API server that redirects back into your app via a deep link
                kIsWeb
                    ? Uri.parse('') // TODO
                    : Uri.parse(''), // TODO
          ),
        );
        authorizationCode = credential.authorizationCode;
        identityToken = credential.identityToken;
      }

      // This is the endpoint that will convert an authorization code obtained
      // via Sign in with Apple into a session in your system
      final http.Response response = await apiService.post(
        'auth/apple/',
        omitBearerToken: true,
        contentType: 'application/json',
        body: <String, dynamic>{
          'access_token': authorizationCode,
          'id_token': identityToken,
        },
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

          await storageService.setString(
            'email',
            userStateService.user.value.email,
          );
          await storageService.setString(
            'password',
            '',
          );
          await storageService.setInt(
            'provider',
            ProviderTypes.apple.index,
          );
          await storageService.setString(
            'authorizationCode',
            authorizationCode,
          );
          await storageService.setString(
            'identityToken',
            identityToken ?? '',
          );

          return AuthResponse(
            <String, dynamic>{
              'success': 'Successfully signed in with Apple.',
            },
            true,
          );
        } catch (error) {
          await _disconnectProviders();
          throw Exception('AuthService - error while parsing the user: $error');
        }
      } else {
        await _disconnectProviders();
        return AuthResponse(parseErrorMap(response), false);
      }
    } //handles the error if user cancels apple signin and stops app crashing
    on PlatformException catch (e) {
      if (e.code == 'cancelled') {
        // User canceled the sign in
        return AuthResponse(
          <String, dynamic>{'error': 'Sign in cancelled'},
          false,
        );
      } else {
        // Other authorization error occurred
        throw Exception('Authorization error: $e');
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      // Other error occurred
      return AuthResponse(<String, dynamic>{'error': e.message}, false);
    } catch (e) {
      // Other error occurred
      throw Exception('Authorization error: $e');
    }
  }""";

  String appleSwitchCase() {
    return """
        case ProviderTypes.apple:
          return (await appleSignIn(
            authorizationCode: storageService.getString('authorizationCode'),
            identityToken: storageService.getString('identityToken'),
          ))
              .success;""";
  }

  String googleImports() => """
import 'package:google_sign_in/google_sign_in.dart';""";

  String googleInitialization() => '''
  late GoogleSignIn _googleSignIn;''';

  String googleInitContent() => """
    _googleSignIn = GoogleSignIn(
      scopes: <String>[
        'email',
      ],
    );""";

  String googleDisconnect() => r"""
    try {
      await _googleSignIn.disconnect();
    } catch (e) {
      debugPrint('AuthService - error while logging out from google: $e');
    }""";

  String googleSignIn() => r"""
  // Login with Google.
  Future<AuthResponse> googleSignIn() async {
    try {
      // Clear cache
      await _googleSignIn.currentUser?.clearAuthCache();

      // Try to login silently
      final GoogleSignInAccount? result =
          await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();

      if (result != null) {
        debugPrint('Google Sign In result - $result');

        final GoogleSignInAuthentication googleKey =
            await result.authentication;

        debugPrint('- token -');
        debugPrint(googleKey.accessToken);
        debugPrint('- idToken -');
        debugPrint(googleKey.idToken);
        debugPrint('- displayName -');
        debugPrint(_googleSignIn.currentUser?.displayName);

        // Login in backend
        final http.Response response = await apiService.post(
          'auth/google/',
          body: <String, dynamic>{
            'access_token': googleKey.accessToken,
            'id_token': googleKey.idToken,
          },
          omitBearerToken: true,
          contentType: 'application/json',
        );

        if (response.statusCode == 200) {
          try {
            final Map<String, dynamic> userMap =
                jsonDecode(response.body) as Map<String, dynamic>;
            userStateService.user.value =
                User.fromJson(userMap['user'] as Map<String, dynamic>);

            /// save the token
            authenticationToken = userMap['access_token'] as String;
            debugPrint(
              'AuthService - authenticationToken: $authenticationToken',
            );
            debugPrint(
              'AuthService - user logged in: ${userStateService.user.value.email}',
            );

            await storageService.setString(
              'email',
              userStateService.user.value.email,
            );
            await storageService.setString(
              'password',
              '',
            );
            await storageService.setInt(
              'provider',
              ProviderTypes.google.index,
            );

            return AuthResponse(
              <String, dynamic>{
                'success': 'Successfully signed in with Google.',
              },
              true,
            );
          } catch (error) {
            await _disconnectProviders();
            throw Exception(
              'AuthService - error while parsing the user: $error',
            );
          }
        } else if (response.statusCode == 400) {
          await _disconnectProviders();
          return AuthResponse(parseErrorMap(response), false);
        } else {
          await _disconnectProviders();
          throw Exception('AuthService - ${unexpectedError(response)}');
        }
      }
      return AuthResponse(
        <String, dynamic>{
          'error':
              "Google auth isn't working at the moment. Please try again later.",
        },
        false,
      );
    } catch (e) {
      // Other error occurred
      throw Exception('Catched an error while logging in with Google: $e');
    }
  }""";

  String googleSwitchCase() {
    return '''
        case ProviderTypes.google:
          return (await googleSignIn()).success;''';
  }

  String get appleDefaultSwitchCase => '''
        case ProviderTypes.apple:
          return false;''';

  String get googleDefaultSwitchCase => '''
        case ProviderTypes.google:
          return false;''';
}
