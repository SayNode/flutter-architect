import '../../../../../interfaces/file_manipulator.dart';

class AuthResponseManipulator extends FileManipulator {
  @override
  String get name => 'ApiResponse';

  @override
  String get path => 'lib/model/api_response.dart';

  @override
  String content() {
    return r"""
class ApiResponse {
  ApiResponse({
    required this.result,
    required this.message,
    required this.status,
    required this.success,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, int statusCode) {
    return ApiResponse(
      result: json['result'] as Map<String, dynamic>? ?? <String, dynamic>{},
      message: json['message'] as String,
      status: statusCode,
      success: json['success'] as bool,
    );
  }
  final Map<String, dynamic> result;
  final String message;
  final int status;
  final bool success;

  @override
  String toString() {
    return 'ApiResponse(message: $message, status: $status, success: $success, result: $result)';
  }
}
""";
  }
}
