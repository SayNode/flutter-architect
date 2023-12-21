content() => """
Future<void> handleError(
  Object error,
  StackTrace? stack,
  {bool fatal = false,
  Iterable<Object> information = const <Object>[],
  bool async = false,
}) async {
  // Failed host lookup
  if (error.toString().contains('Failed host lookup')) {
    Get.put(NetworkService()).onInternetLostPage.value = true;
    // ignore: inference_failure_on_function_invocation
    await Get.to(() => const LostConnectionPage());
    if (error.toString().contains('No host specified in URI file:///')) {
      return;
    }

    // Check if the application is running on dev mode
    final bool devMode = bool.tryParse(
      const String.fromEnvironment(
          'DEV_MODE',
      ),
    ) ??
    false;

    final GetMaterialController currentController = Get.rootController;

    final String previousRoute = currentController.routing.previous;

    // if (Get.put(UserStateService()).user.value.id != -1) {
    //   FirebaseCrashlytics.instance.setUserIdentifier(
    //       Get.put(UserStateService()).user.value.id.toString());
    // }

    if (!devMode) {
      if (fatal) {
        // If you see fatal on the crashlytics, it was registered here
        await FirebaseCrashlytics.instance.recordError(
          error,
          stack,
          fatal: true,
          information: <Object>[
            'Current Route: \${Get.currentRoute}',
            'Previous Route:  \$previousRoute',
            'Asynchronous: \$async',
            // "User Id: \${Get.put(UserStateService()).user.value.id.toString()}",
            ...information,
          ],
        );

        if (getMaterialAppCalled) {
          // ignore: inference_failure_on_function_invocation
          await Get.to(() => const ErrorPage());
        } else {
          // Try to exit app:
          // SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      } else {
        // If you see non fatal on the crashlytics, it was registered here
        await FirebaseCrashlytics.instance.recordError(
          error,
          stack,
          reason: 'a non-fatal error, this will be ignored',
          information: <Object>[
            'Current Route: \${Get.currentRoute}',
            'Previous Route:  \$previousRoute',
            'Asynchronous: \$async',
            // "User Id: \${Get.put(UserStateService()).user.value.id.toString()}",
            ...information,
          ],
        );
      }
    }
  }
}""";
