String imports() => """
import 'package:google_sign_in/google_sign_in.dart';""";

String initialization() => '''
  late GoogleSignIn _googleSignIn;''';

String initContent() => """
    _googleSignIn = GoogleSignIn(
      scopes: <String>[
        'email',
      ],
    );""";

String disconnect() => r"""
    try {
      await _googleSignIn.disconnect();
    } catch (e) {
      debugPrint('AuthService - error while logging out from google: $e');
    }""";

String signIn() => r"""
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

String switchCase() {
  return '''
        case ProviderTypes.google:
          return (await googleSignIn()).success;''';
}
