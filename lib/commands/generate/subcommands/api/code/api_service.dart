import 'constants.dart';

String content(String projectName) {
  projectName = projectName.capitalize();
  return """
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../util/constants.dart';
import 'auth_service.dart';

class APIService extends GetxService {
  AuthService get authService => Get.put(AuthService());

  /// Patch request to $projectName backend.
  /// [path] the path to the endpoint.
  /// [body] is the body of the request.
  Future<http.Response> patch(
    String path, {
    Map<String, dynamic>? body,
    String? contentType,
    Encoding? encoding,
    Map<String, dynamic>? queryParameters,
    bool omitBearerToken = false,
  }) async {
    final Uri url =
        Uri.https(${projectName}Constants.apiDomain, path, queryParameters);
    debugPrint(
      'API - PATCH to \$path\${body != null ? ' with body: \$body' : ''}',
    );
    final http.Response response = await http.patch(
      url,
      headers: <String, String>{
        'key': ${projectName}Constants.apiKey,
        'Content-Type': contentType ?? 'application/json',
        ...(omitBearerToken
            ? <String, String>{}
            : <String, String>{
                HttpHeaders.authorizationHeader:
                    'Bearer \${authService.authenticationToken}',
              }),
      },
      body: body != null ? json.encode(body) : null,
      encoding: encoding,
    );
    debugPrint(
      'API - PATCH to \$path - Got \${response.statusCode} with body: \${response.body}',
    );
    return response;
  }

  /// Put request to $projectName backend.
  /// [path] the path to the endpoint.
  /// [body] is the body of the request.
  Future<http.Response> put(
    String path, {
    Map<String, dynamic>? body,
    String? contentType,
    Encoding? encoding,
    Map<String, dynamic>? queryParameters,
    bool omitBearerToken = false,
  }) async {
    final Uri url =
        Uri.https(${projectName}Constants.apiDomain, path, queryParameters);
    debugPrint(
      'API - PUT to \$path\${body != null ? ' with body: \$body' : ''}',
    );
    final http.Response response = await http.put(
      url,
      headers: <String, String>{
        'key': ${projectName}Constants.apiKey,
        'Content-Type': contentType ?? 'application/json',
        ...(omitBearerToken
            ? <String, String>{}
            : <String, String>{
                HttpHeaders.authorizationHeader:
                    'Bearer \${authService.authenticationToken}',
              }),
      },
      body: body != null ? json.encode(body) : null,
      encoding: encoding,
    );
    debugPrint(
      'API - PUT to \$path - Got \${response.statusCode} with body: \${response.body}',
    );
    return response;
  }

  /// Post request to $projectName backend.
  /// [path] the path to the endpoint.
  /// [body] is the body of the request.
  Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
    String? contentType,
    Encoding? encoding,
    Map<String, dynamic>? queryParameters,
    bool omitBearerToken = false,
  }) async {
    final Uri url =
        Uri.https(${projectName}Constants.apiDomain, path, queryParameters);
    debugPrint(
      'API - POST to \$path\${body != null ? ' with body: \$body' : ''}',
    );
    final http.Response response = await http.post(
      url,
      headers: <String, String>{
        'key': ${projectName}Constants.apiKey,
        'Content-Type': contentType ?? 'application/json',
        ...(omitBearerToken
            ? <String, String>{}
            : <String, String>{
                HttpHeaders.authorizationHeader:
                    'Bearer \${authService.authenticationToken}',
              }),
      },
      body: body != null ? json.encode(body) : null,
      encoding: encoding,
    );
    debugPrint(
      'API - POST to \$path - Got \${response.statusCode} with body: \${response.body}',
    );
    return response;
  }

  /// Get request to $projectName backend.
  /// [path] the path to the endpoint.
  Future<http.Response> get(
    String path, {
    String? contentType,
    Map<String, dynamic>? queryParameters,
    bool omitBearerToken = false,
  }) async {
    final Uri url =
        Uri.https(${projectName}Constants.apiDomain, path, queryParameters);
    debugPrint('API - GET to \$path');
    final http.Response response = await http.get(
      url,
      headers: <String, String>{
        'key': ${projectName}Constants.apiKey,
        'Content-Type': contentType ?? 'application/json',
        ...(omitBearerToken
            ? <String, String>{}
            : <String, String>{
                HttpHeaders.authorizationHeader:
                    'Bearer \${authService.authenticationToken}',
              }),
      },
    );
    debugPrint(
      'API - GET to \$path - Got \${response.statusCode} with body: \${response.body}',
    );
    return response;
  }

  /// Delete request to $projectName backend.
  /// [path] the path to the endpoint.
  /// [body] is the body of the request.
  Future<http.Response> delete(
    String path, {
    Map<String, dynamic>? body,
    String? contentType,
    Encoding? encoding,
    Map<String, dynamic>? queryParameters,
    bool omitBearerToken = false,
  }) async {
    final Uri url =
        Uri.https(${projectName}Constants.apiDomain, path, queryParameters);
    debugPrint(
      'API - DELETE to \$path\${body != null ? ' with body: \$body' : ''}',
    );
    final http.Response response = await http.delete(
      url,
      headers: <String, String>{
        'key': ${projectName}Constants.apiKey,
        'Content-Type': contentType ?? 'application/json',
        ...(omitBearerToken
            ? <String, String>{}
            : <String, String>{
                HttpHeaders.authorizationHeader:
                    'Bearer \${authService.authenticationToken}',
              }),
      },
      body: body != null ? json.encode(body) : null,
      encoding: encoding,
    );
    debugPrint(
      'API - DELETE to \$path - Got \${response.statusCode} with body: \${response.body}',
    );
    return response;
  }
}""";
}
