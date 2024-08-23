import '../../../../../interfaces/file_manipulator.dart';

class ApiBaseServiceManipulator extends FileManipulator {
  @override
  String get name => 'ApiBaseService';

  @override
  String get path => 'lib/base/api_base_service.dart';

  @override
  String content() {
    return r"""
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../service/logger_service.dart';
import '../util/constants.dart';
import '../model/api_response.dart';

class _APIException implements Exception {
  _APIException(this.url, this.statusCode);

  final String url;
  final int statusCode;

  @override
  String toString() =>
      'A request to the backend API failed with status code [$statusCode]: $url';
}

class ParsingException extends _APIException {
  ParsingException(super.url, super.statusCode, this.message);

  final String message;

  @override
  String toString() =>
      'Failed to parse response from $url [$statusCode]: $message';
}

abstract class ApiBaseService extends GetxService {
  String authenticationToken = '';
  LoggerService loggerService = Get.find<LoggerService>();

  /// Patch request to the backend.
  /// [path] the path to the endpoint.
  /// [body] is the body of the request.
  Future<ApiResponse> patch(
    String path, {
    Map<String, dynamic>? body,
    String? contentType,
    Encoding? encoding,
    Map<String, dynamic>? queryParameters,
    bool omitBearerToken = false,
    bool log = false,
  }) async {
    final Uri url =
        Uri.https(Constants.apiDomain, path, queryParameters);
    if (log) {
      loggerService.log(
        'API - called PATCH at $url',
      );
    }

    http.Response? response;

    for (int i = 0; i < 5; i++) {
      try {
        response = await http.patch(
          url,
          headers: <String, String>{
            'key': Constants.apiKey,
            'Content-Type': contentType ?? 'application/json',
            ...(omitBearerToken
                ? <String, String>{}
                : <String, String>{
                    HttpHeaders.authorizationHeader: 'Bearer $authenticationToken',
                  }),
          },
          body: body != null ? json.encode(body) : null,
          encoding: encoding,
        );
        break;
      } on http.ClientException catch (e, _) {
        if (i == 4) {
          throw Exception(
            'Got ClientException 5 times in a row, when requesting to $path - $e',
          );
        } else {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      } on HandshakeException catch (e, _) {
        if (i == 4) {
          throw Exception(
            'Got HandshakeException 5 times in a row, when requesting to $path - $e',
          );
        } else {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      } catch (e) {
        rethrow;
      }
    }

    if (response == null) {
      throw Exception('Unexpected error in request handling - $path');
    }

    if (response.statusCode >= 500) {
      throw _APIException(
        path,
        response.statusCode,
      );
    }

    try {
      final ApiResponse ret = ApiResponse.fromJson(
        json.decode(
          utf8.decode(
            response.bodyBytes,
          ),
        ) as Map<String, dynamic>,
        response.statusCode,
      );
      if (log) {
        loggerService.log(
          'API - PATCH to $path - Got ${response.statusCode} with body: ${response.body}',
        );
      }
      return ret;
    } catch (e) {
      throw ParsingException(e.toString(), response.statusCode, path);
    }
  }

  /// Put request to the backend.
  /// [path] the path to the endpoint.
  /// [body] is the body of the request.
  Future<ApiResponse> put(
    String path, {
    Map<String, dynamic>? body,
    String? contentType,
    Encoding? encoding,
    Map<String, dynamic>? queryParameters,
    bool omitBearerToken = false,
    bool log = false,
  }) async {
    final Uri url =
        Uri.https(Constants.apiDomain, path, queryParameters);
    if (log) {
      loggerService.log(
        'API - called PUT at $url',
      );
    }

    http.Response? response;

    for (int i = 0; i < 5; i++) {
      try {
        response = await http.put(
          url,
          headers: <String, String>{
            'key': Constants.apiKey,
            'Content-Type': contentType ?? 'application/json',
            ...(omitBearerToken
                ? <String, String>{}
                : <String, String>{
                    HttpHeaders.authorizationHeader: 'Bearer $authenticationToken',
                  }),
          },
          body: body != null ? json.encode(body) : null,
          encoding: encoding,
        );
        break;
      } on http.ClientException catch (e, _) {
        if (i == 4) {
          throw Exception(
            'Got ClientException 5 times in a row, when requesting to $path - $e',
          );
        } else {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      } on HandshakeException catch (e, _) {
        if (i == 4) {
          throw Exception(
            'Got HandshakeException 5 times in a row, when requesting to $path - $e',
          );
        } else {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      } catch (e) {
        rethrow;
      }
    }

    if (response == null) {
      throw Exception('Unexpected error in request handling - $path');
    }

    if (response.statusCode >= 500) {
      throw _APIException(
        path,
        response.statusCode,
      );
    }

    try {
      final ApiResponse ret = ApiResponse.fromJson(
        json.decode(
          utf8.decode(
            response.bodyBytes,
          ),
        ) as Map<String, dynamic>,
        response.statusCode,
      );
      if (log) {
        loggerService.log(
          'API - PUT to $path - Got ${response.statusCode} with body: ${response.body}',
        );
      }
      return ret;
    } catch (e) {
      throw ParsingException(e.toString(), response.statusCode, path);
    }
  }

  /// Post request to the backend.
  /// [path] the path to the endpoint.
  /// [body] is the body of the request.
  Future<ApiResponse> post(
    String path, {
    Map<String, dynamic>? body,
    String? contentType,
    Encoding? encoding,
    Map<String, dynamic>? queryParameters,
    bool omitBearerToken = false,
    bool log = false,
  }) async {
    final Uri url =
        Uri.https(Constants.apiDomain, path, queryParameters);
    if (log) {
      loggerService.log(
        'API - called POST at $url',
      );
    }

    http.Response? response;

    for (int i = 0; i < 5; i++) {
      try {
        response = await http.post(
          url,
          headers: <String, String>{
            'key': Constants.apiKey,
            'Content-Type': contentType ?? 'application/json',
            ...(omitBearerToken
                ? <String, String>{}
                : <String, String>{
                    HttpHeaders.authorizationHeader: 'Bearer $authenticationToken',
                  }),
          },
          body: body != null ? json.encode(body) : null,
          encoding: encoding,
        );
        break;
      } on http.ClientException catch (e, _) {
        if (i == 4) {
          throw Exception(
            'Got ClientException 5 times in a row, when requesting to $path - $e',
          );
        } else {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      } on HandshakeException catch (e, _) {
        if (i == 4) {
          throw Exception(
            'Got HandshakeException 5 times in a row, when requesting to $path - $e',
          );
        } else {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      } catch (e) {
        rethrow;
      }
    }

    if (response == null) {
      throw Exception('Unexpected error in request handling - $path');
    }

    if (response.statusCode >= 500) {
      throw _APIException(
        path,
        response.statusCode,
      );
    }

    try {
      final ApiResponse ret = ApiResponse.fromJson(
        json.decode(
          utf8.decode(
            response.bodyBytes,
          ),
        ) as Map<String, dynamic>,
        response.statusCode,
      );
      if (log) {
        loggerService.log(
          'API - POST to $path - Got ${response.statusCode} with body: ${response.body}',
        );
      }
      return ret;
    } catch (e) {
      throw ParsingException(e.toString(), response.statusCode, path);
    }
  }

  /// Get request to the backend.
  /// [path] the path to the endpoint.
  Future<ApiResponse> get(
    String path, {
    String? contentType,
    Map<String, dynamic>? queryParameters,
    bool omitBearerToken = false,
    bool log = false,
  }) async {
    final Uri url =
        Uri.https(Constants.apiDomain, path, queryParameters);

    if (log) {
      loggerService.log('API - GET to queryParameters');
    }

    http.Response? response;

    for (int i = 0; i < 5; i++) {
      try {
        response = await http.get(
          url,
          headers: <String, String>{
            'key': Constants.apiKey,
            'Content-Type': contentType ?? 'application/json',
            ...(omitBearerToken
                ? <String, String>{}
                : <String, String>{
                    HttpHeaders.authorizationHeader: 'Bearer $authenticationToken',
                  }),
          },
        );
        break;
      } on http.ClientException catch (e, _) {
        if (i == 4) {
          throw Exception(
            'Got ClientException 5 times in a row, when requesting to $path - $e',
          );
        } else {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      } on HandshakeException catch (e, _) {
        if (i == 4) {
          throw Exception(
            'Got HandshakeException 5 times in a row, when requesting to $path - $e',
          );
        } else {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      } catch (e) {
        rethrow;
      }
    }

    if (response == null) {
      throw Exception('Unexpected error in request handling - $path');
    }

    if (response.statusCode >= 500) {
      throw _APIException(
        path,
        response.statusCode,
      );
    }

    try {
      final ApiResponse ret = ApiResponse.fromJson(
        json.decode(
          utf8.decode(
            response.bodyBytes,
          ),
        ) as Map<String, dynamic>,
        response.statusCode,
      );
      if (log) {
        loggerService.log(
          'API - GET to $path - Got ${response.statusCode} with body: ${response.body}',
        );
      }
      return ret;
    } catch (e) {
      throw ParsingException(e.toString(), response.statusCode, path);
    }
  }

  /// Delete request to the backend.
  /// [path] the path to the endpoint.
  /// [body] is the body of the request.
  Future<ApiResponse> delete(
    String path, {
    Map<String, dynamic>? body,
    String? contentType,
    Encoding? encoding,
    Map<String, dynamic>? queryParameters,
    bool omitBearerToken = false,
    bool log = false,
  }) async {
    final Uri url =
        Uri.https(Constants.apiDomain, path, queryParameters);

    if (log) {
      loggerService.log(
        'API - called DELETE at $url',
      );
    }

    http.Response? response;

    for (int i = 0; i < 5; i++) {
      try {
        response = await http.delete(
          url,
          headers: <String, String>{
            'key': Constants.apiKey,
            'Content-Type': contentType ?? 'application/json',
            ...(omitBearerToken
                ? <String, String>{}
                : <String, String>{
                    HttpHeaders.authorizationHeader: 'Bearer $authenticationToken',
                  }),
          },
          body: body != null ? json.encode(body) : null,
          encoding: encoding,
        );
        break;
      } on http.ClientException catch (e, _) {
        if (i == 4) {
          throw Exception(
            'Got ClientException 5 times in a row, when requesting to $path - $e',
          );
        } else {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      } on HandshakeException catch (e, _) {
        if (i == 4) {
          throw Exception(
            'Got HandshakeException 5 times in a row, when requesting to $path - $e',
          );
        } else {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      } catch (e) {
        rethrow;
      }
    }

    if (response == null) {
      throw Exception('Unexpected error in request handling - $path');
    }

    if (response.statusCode >= 500) {
      throw _APIException(
        path,
        response.statusCode,
      );
    }

    try {
      final ApiResponse ret = ApiResponse.fromJson(
        json.decode(
          utf8.decode(
            response.bodyBytes,
          ),
        ) as Map<String, dynamic>,
        response.statusCode,
      );
      if (log) {
        loggerService.log(
          'API - DELETE to $path - Got ${response.statusCode} with body: ${response.body}',
        );
      }
      return ret;
    } catch (e) {
      throw ParsingException(e.toString(), response.statusCode, path);
    }
  }
}
""";
  }
}
