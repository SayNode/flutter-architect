String content() => r"""
await FirebaseCrashlytics.instance.recordError(
  error,
  stack,
  fatal: true,
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