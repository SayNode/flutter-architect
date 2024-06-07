String content() => '''
    return StreamBuilder<bool>(
      stream: Get.put(ConnectivityService()).onConnectivityChanged,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) =>
          snapshot.connectionState == ConnectionState.waiting &&
                  snapshot.connectionState == ConnectionState.none &&
                  snapshot.data == null &&
                  !snapshot.data!
              ? const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : CustomScaffold(
                  body: Container(),
                ),
    );''';

String import() => '''
import 'package:get/get.dart';
import '../service/connectivity_service.dart';''';
