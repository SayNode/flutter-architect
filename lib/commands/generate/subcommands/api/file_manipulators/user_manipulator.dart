import '../../../../../interfaces/file_manipulator.dart';

class UserManipulator extends FileManipulator {
  @override
  String get name => 'User';

  @override
  String get path => 'lib/model/user.dart';

  @override
  String content() {
    return """
class User {
  User();

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int? ?? json['pk'] as int? ?? -1,
        email = json['email'] as String? ?? '',
        name = json['name'] as String? ?? '';
        // Add more fields as needed

  int id = -1;
  String email = '';
  String name = '';
  // Add more fields as needed

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'email': email,
    'name': name,
    // Add more fields as needed
  };
}
""";
  }
}
