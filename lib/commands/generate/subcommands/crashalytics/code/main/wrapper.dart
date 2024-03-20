String contentBefore() => '''
  FlutterError.onError = (FlutterErrorDetails details) async {
    await handleError(
      details.exception,
      details.stack,
      fatal: true,
    );
  };

  await runZonedGuarded<Future<void>>(() async {''';

String contentAfter() => """
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    // ignore: unused_local_variable
    // await GetStorage.init('theme');
    //await networkService.init();
    await SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[DeviceOrientation.portraitUp],
    );
    isFirstRun = await IsFirstRun.isFirstRun();
  }, (Object error, StackTrace stack) async {
    debugPrint('Error caught by main zone');
    debugPrint(error.toString());
    debugPrint(stack.toString());

    await handleError(error, stack, fatal: true);
  });""";
