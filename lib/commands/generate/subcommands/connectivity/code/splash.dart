String content() => '''
    return StreamBuilder<bool>(
      stream: Get.find<ConnectivityService>().onConnectivityChanged,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) =>
          snapshot.connectionState == ConnectionState.waiting &&
                  snapshot.connectionState == ConnectionState.none &&
                  snapshot.data == null
                  
              ? const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : snapshot.data! ? CustomScaffold( // Replace this with your first screen
                  body: Container(),
                ) : LostConnectionPage(),
    );''';

String import() => '''
import 'package:get/get.dart';
import '../service/connectivity_service.dart';
import 'lost_connection/lost_connection_page.dart';''';
