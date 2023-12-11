imports() => """
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/services.dart';""";

disconnect() => """
    // TODO: Disconnect from apple
""";

signIn() => """
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
          debugPrint('AuthService - authenticationToken: \$authenticationToken');
          debugPrint(
            'AuthService - user logged in: \${userStateService.user.value.email}',
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

          return AuthResponse(<String, dynamic>{'success': 'Successfully signed in with Apple.'}, true);
        } catch (error) {
          await _disconnectProviders();
          throw Exception('AuthService - error while parsing the user: \$error');
        }
      } else {
        await _disconnectProviders();
        return AuthResponse(parseErrorMap(response), false);
      }
    } //handles the error if user cancels apple signin and stops app crashing
    on PlatformException catch (e) {
      if (e.code == 'cancelled') {
        // User canceled the sign in
        return AuthResponse(<String, dynamic>{'error': 'Sign in cancelled'}, false);
      } else {
        // Other authorization error occurred
        throw Exception('Authorization error: \$e');
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      // Other error occurred
      return AuthResponse(<String, dynamic>{'error': e.message}, false);
    } catch (e) {
      // Other error occurred
      throw Exception('Authorization error: \$e');
    }
  }""";
