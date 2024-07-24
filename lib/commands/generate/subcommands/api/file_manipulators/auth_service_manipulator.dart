import '../../../../../interfaces/service_manipulator.dart';
import '../../../../../util/util.dart';

class AuthServiceManipulator extends ServiceManipulator {
  @override
  String get name => 'AuthService';

  @override
  String get path => 'lib/service/auth_service.dart';

  @override
  String content() {
    return """
import '../base/auth_base_service.dart';

class AuthService extends AuthBaseService {
  // Add your custom code here
}
""";
  }

  Future<void> createGoogleSignIn() async {
    if (!(await checkIfAlreadyRunWithReturn('signin-apple'))) {
      await addLinesAfterLineInFile(
        path,
        <String, List<String>>{
          '// https://saynode.ch': <String>[otherImports()],
        },
      );
      await addLinesAfterLineInFile(
        path,
        <String, List<String>>{
          '// Add your custom code here': <String>[disconnectOverride()],
        },
      );
    }
    await addLinesAfterLineInFile(
      path,
      <String, List<String>>{
        '// https://saynode.ch': <String>[googleImports()],
        '// Add your custom code here': <String>[
          googleInitContent(),
          '\n',
          googleSignIn(),
        ],
        '// Disconnect providers': <String>[
          googleDisconnect(),
        ],
      },
    );
  }

  Future<void> createAppleSignIn() async {
    if (!(await checkIfAlreadyRunWithReturn('signin-google'))) {
      await addLinesAfterLineInFile(
        path,
        <String, List<String>>{
          '// https://saynode.ch': <String>[otherImports()],
        },
      );
      await addLinesAfterLineInFile(
        path,
        <String, List<String>>{
          '// Add your custom code here': <String>[disconnectOverride()],
        },
      );
    }
    await addLinesAfterLineInFile(
      path,
      <String, List<String>>{
        '// https://saynode.ch': <String>[appleImports()],
        '// Add your custom code here': <String>[appleSignIn()],
        '// Disconnect providers': <String>[
          appleDisconnect(),
        ],
      },
    );
  }

  Future<void> removeGoogleSignIn() async {
    await removeTextFromFile(path, googleImports());
    await removeTextFromFile(path, googleInitContent());
    await removeTextFromFile(path, googleSignIn());
    await removeTextFromFile(path, googleDisconnect());
    if (!(await checkIfAlreadyRunWithReturn('signin-apple'))) {
      await removeTextFromFile(path, otherImports());
      await removeTextFromFile(path, disconnectOverride());
    }
  }

  Future<void> removeAppleSignIn() async {
    await removeTextFromFile(path, appleImports());
    await removeTextFromFile(path, appleSignIn());
    await removeTextFromFile(path, appleDisconnect());
    if (!(await checkIfAlreadyRunWithReturn('signin-google'))) {
      await removeTextFromFile(path, otherImports());
      await removeTextFromFile(path, disconnectOverride());
    }
  }

  String appleImports() => """
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';""";

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

      final AuthResponse authResult = AuthResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );

      if (response.statusCode == 200) {
        try {
          /// Save the token
          apiService.authenticationToken = authResult.accessToken;
          await storageService.writeString('token', authResult.accessToken);

          return authResult;
        } catch (error) {
          await disconnectProviders();
          throw Exception('AuthService - error while parsing the user: $error');
        }
      } else {
        await disconnectProviders();
        return authResult;
      }
    } //handles the error if user cancels apple signin and stops app crashing
    on PlatformException catch (e) {
      if (e.code == 'cancelled') {
        // User canceled the sign in
        return AuthResponse(
          result: <String, dynamic>{},
          accessToken: '',
          message: 'Sign in cancelled',
          status: 0,
          success: false,
        );
      } else {
        // Other authorization error occurred
        throw Exception('Authorization error: $e');
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      // Other error occurred
      return AuthResponse(
        result: <String, dynamic>{},
        accessToken: '',
        message: e.message,
        status: 0,
        success: false,
      );
    } catch (e) {
      // Other error occurred
      throw Exception('Authorization error: $e');
    }
  }""";

  String googleImports() => """
import 'package:google_sign_in/google_sign_in.dart';""";

  String googleInitContent() => """
    late GoogleSignIn _googleSignIn;

    void init() {
      _googleSignIn = GoogleSignIn(
        scopes: <String>[
          'email',
        ],
      );
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
        final GoogleSignInAuthentication googleKey =
            await result.authentication;

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

        final AuthResponse authResult = AuthResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );

        if (response.statusCode == 200) {
          try {
            /// Save the token
            apiService.authenticationToken = authResult.accessToken;
            await storageService.writeString(
              'token',
              authResult.accessToken,
            );

            return authResult;
          } catch (error) {
            await disconnectProviders();
            throw Exception(
              'AuthService - error while parsing the user: $error',
            );
          }
        } else if (response.statusCode == 400) {
          await disconnectProviders();
          return authResult;
        } else {
          await disconnectProviders();
          throw Exception('AuthService - ${authResult.message}');
        }
      }
      return AuthResponse(
        result: <String, dynamic>{},
        accessToken: '',
        message: "Google auth isn't working at the moment. Please try again later.",
        status: 0,
        success: false,
      );
    } catch (e) {
      // Other error occurred
      throw Exception('Catched an error while logging in with Google: $e');
    }
  }""";

  String otherImports() => """
import '../model/auth_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';""";

  String googleDisconnect() => r"""
    // Disconnect from Google.
    if (await _googleSignIn.isSignedIn()) {
      try {
        await _googleSignIn.disconnect();
      } catch (e) {
        throw Exception('AuthService - error while disconnecting from google: $e');
      }
    }""";

  String appleDisconnect() => '''
    // Disconnect from Apple.
    ''';

  String disconnectOverride() => '''
  @override
  Future<void> disconnectProviders() async {
    // Disconnect providers
    super.disconnectProviders();
  }''';
}
