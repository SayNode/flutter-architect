content() {
  return """
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../util/constants.dart';

class LostConnectionPage extends StatelessWidget {
  const LostConnectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: getRelativeWidth(71)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset("assets/icons/lost_connection_icon.svg"),
                SizedBox(height: getRelativeHeight(47)),
                Text(
                  "No internet connection".tr,
                  style: TextStyle(color: Colors.black), //TODO Add theme color for text,
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Check your internet connection and reload the page".tr,
                  style: TextStyle(color: Colors.black), //TODO Add theme color for text,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: getRelativeHeight(57)),
                ElevatedButton(
                    child: Text(
                      "Reload".tr,
                      style: TextStyle(color: Colors.black), //TODO Add theme color for text,
                    ),
                    onPressed: () async {
                      // await Get.put(NetworkService()).checkInternetStatus();
                    }),
                SizedBox(height: getRelativeHeight(37)),
                GestureDetector(
                  onTap: () async {
                    final Uri url =
                        Uri.parse('mailto: [email]');
                    if (!await launchUrl(url)) {}
                  },
                  child: Text(
                    "HELP & SUPPORT".tr,
                    style: TextStyle(color: Colors.black), //TODO Add theme color for text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

  """;
}
