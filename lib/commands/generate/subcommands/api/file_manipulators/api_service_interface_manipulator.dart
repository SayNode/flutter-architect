import '../../../../../interfaces/file_manipulator.dart';

class ApiServiceInterfaceManipulator extends FileManipulator {
  @override
  // TODO: implement name
  String get name => 'ApiServiceInterface';

  @override
  String get path => 'lib/services/api_service_interface.dart';

  @override
  String content() {
    return """
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../service/logger_service.dart';
import '../util/constants.dart';

abstract class ApiServiceInterface extends GetxService {
  String authenticationToken = '';
  LoggerService loggerService = Get.find<LoggerService>();

  /// Patch request to the backend.
  /// [path] the path to the endpoint.
  /// [body] is the body of the request.
  Future<http.Response> patch(
    String path, {
    Map<String, dynamic>? body,
    String? contentType,
    Encoding? encoding,
    Map<String, dynamic>? queryParameters,
    bool omitBearerToken = false,
    bool log = false,
  }) async {
    final Uri url = Uri.https(Constants.apiDomain, path, queryParameters);
    if (log) {
      loggerService.log(
        'API - PATCH to queryParameters{body != null ? ' with body: \body' : ''}',
      );
    }
    final http.Response response = await http.patch(
      url,
      headers: <String, String>{
        'key': Constants.apiKey,
        'Content-Type': contentType ?? 'application/json',
        ...(omitBearerToken
            ? <String, String>{}
            : <String, String>{
                HttpHeaders.authorizationHeader: 'Bearer authenticationToken',
              }),
      },
      body: body != null ? json.encode(body) : null,
      encoding: encoding,
    );

    if (log) {
      loggerService.log(
        'API - PATCH to queryParameters - Got {response.statusCode} with body: {response.body}',
      );
    }
    return response;
  }

  /// Put request to the backend.
  /// [path] the path to the endpoint.
  /// [body] is the body of the request.
  Future<http.Response> put(
    String path, {
    Map<String, dynamic>? body,
    String? contentType,
    Encoding? encoding,
    Map<String, dynamic>? queryParameters,
    bool omitBearerToken = false,
    bool log = false,
  }) async {
    final Uri url = Uri.https(Constants.apiDomain, path, queryParameters);
    if (log) {
      loggerService.log(
        'API - PUT to queryParameters{body != null ? ' with body: \body' : ''}',
      );
    }
    final http.Response response = await http.put(
      url,
      headers: <String, String>{
        'key': Constants.apiKey,
        'Content-Type': contentType ?? 'application/json',
        ...(omitBearerToken
            ? <String, String>{}
            : <String, String>{
                HttpHeaders.authorizationHeader: 'Bearer authenticationToken',
              }),
      },
      body: body != null ? json.encode(body) : null,
      encoding: encoding,
    );
    if (log) {
      loggerService.log(
        'API - PUT to queryParameters - Got {response.statusCode} with body: {response.body}',
      );
    }
    return response;
  }

  /// Post request to the backend.
  /// [path] the path to the endpoint.
  /// [body] is the body of the request.
  Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
    String? contentType,
    Encoding? encoding,
    Map<String, dynamic>? queryParameters,
    bool omitBearerToken = false,
    bool log = false,
  }) async {
    final Uri url = Uri.https(Constants.apiDomain, path, queryParameters);
    if (log) {
      loggerService.log(
        'API - POST to queryParameters{body != null ? ' with body: \body' : ''}',
      );
    }
    final http.Response response = await http.post(
      url,
      headers: <String, String>{
        'key': Constants.apiKey,
        'Content-Type': contentType ?? 'application/json',
        ...(omitBearerToken
            ? <String, String>{}
            : <String, String>{
                HttpHeaders.authorizationHeader: 'Bearer authenticationToken',
              }),
      },
      body: body != null ? json.encode(body) : null,
      encoding: encoding,
    );
    if (log) {
      loggerService.log(
        'API - POST to queryParameters - Got {response.statusCode} with body: {response.body}',
      );
    }
    return response;
  }

  /// Get request to the backend.
  /// [path] the path to the endpoint.
  Future<http.Response> get(
    String path, {
    String? contentType,
    Map<String, dynamic>? queryParameters,
    bool omitBearerToken = false,
    bool log = false,
  }) async {
    final Uri url = Uri.https(Constants.apiDomain, path, queryParameters);

    if (log) {
      loggerService.log('API - GET to queryParameters');
    }
    final http.Response response = await http.get(
      url,
      headers: <String, String>{
        'key': Constants.apiKey,
        'Content-Type': contentType ?? 'application/json',
        ...(omitBearerToken
            ? <String, String>{}
            : <String, String>{
                HttpHeaders.authorizationHeader: 'Bearer authenticationToken',
              }),
      },
    );
    if (log) {
      loggerService.log(
        'API - GET to queryParameters - Got {response.statusCode} with body: {response.body}',
      );
    }
    return response;
  }

  /// Delete request to the backend.
  /// [path] the path to the endpoint.
  /// [body] is the body of the request.
  Future<http.Response> delete(
    String path, {
    Map<String, dynamic>? body,
    String? contentType,
    Encoding? encoding,
    Map<String, dynamic>? queryParameters,
    bool omitBearerToken = false,
    bool log = false,
  }) async {
    final Uri url = Uri.https(Constants.apiDomain, path, queryParameters);

    if (log) {
      loggerService.log(
        'API - DELETE to queryParameters{body != null ? ' with body: \body' : ''}',
      );
    }
    final http.Response response = await http.delete(
      url,
      headers: <String, String>{
        'key': Constants.apiKey,
        'Content-Type': contentType ?? 'application/json',
        ...(omitBearerToken
            ? <String, String>{}
            : <String, String>{
                HttpHeaders.authorizationHeader: 'Bearer authenticationToken',
              }),
      },
      body: body != null ? json.encode(body) : null,
      encoding: encoding,
    );
    if (log) {
      loggerService.log(
        'API - DELETE to queryParameters - Got {response.statusCode} with body: {response.body}',
      );
    }
    return response;
  }
}

""";
  }
}
