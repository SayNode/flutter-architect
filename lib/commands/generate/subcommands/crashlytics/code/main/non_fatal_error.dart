String content() => r"""
await FirebaseCrashlytics.instance.recordError(
  error,
  stack,
  reason: 'a non-fatal error, this will be ignored',
  information: <Object>[
    'Current Route: ${Get.currentRoute}',
    'Previous Route: ${Get.previousRoute}',
    'Asynchronous: $async',
    'Production: ${!Constants.devMode}',
    'GetMaterialApp Called: $getMaterialAppCalled',
    // "User Id: ${Get.put(UserStateService()).user.value.id.toString()}",
    ...information,
  ],
);""";
