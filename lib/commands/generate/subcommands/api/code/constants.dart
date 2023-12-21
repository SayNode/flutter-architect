extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

content(String projectName) => """
class ${projectName.capitalize()}Constants {
  static const String apiDomain = const String.fromEnvironment('DATABASE_URL');
  static const String apiKey = const String.fromEnvironment('DATABASE_API_KEY');
  static bool get devMode => apiDomain.contains("dev-");
}
""";
