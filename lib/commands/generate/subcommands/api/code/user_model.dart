String content() => """
class User {
  User();

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int? ?? json['pk'] as int? ?? -1,
        firstName = json['first_name'] as String? ?? '',
        lastName = json['last_name'] as String? ?? '',
        email = json['email'] as String? ?? '',
        avatar = json['avatar'] as String? ?? '',
        username = json['username'] as String? ?? '',
        firstLogin = json['is_first_login'] as bool? ?? true,
        aboutMe = json['about_me'] as String? ?? '';
  int id = -1;
  String email = '';
  String firstName = '';
  String lastName = '';
  String avatar = '';
  String username = '';
  bool firstLogin = true;
  String aboutMe = '';

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'avatar': avatar,
        'username': username,
        'firstLogin': firstLogin,
        'about_me': aboutMe,
      };
}""";
