content() {
  return """
import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wizzer_flutter/main.dart';
import 'package:wizzer_flutter/page/error/controller/network_controller.dart';
import 'package:wizzer_flutter/theme/colors.dart';

import '../../theme/typography.dart';

class ErrorPage extends StatelessWidget {
  ErrorPage(
      {Key? key,
      required this.errorMessage,
      this.imageUrl = "assets/images/thunderbolt.png"})
      : super(key: key);

  /// Should be null in case of connection problem.
  final String? errorMessage;
  final String imageUrl;
  final RxBool restarting = false.obs;

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var imageSize = screenSize.height * 0.25;

    final NetworkConnectivityController networkController =
        Get.put(NetworkConnectivityController());

    bool connectionProblem = errorMessage == null;

    Future<String> getVersionString() async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return "\${packageInfo.version}+\${packageInfo.buildNumber}";
    }

    return Scaffold(
      body: FutureBuilder<String>(
          future: getVersionString(),
          builder: (context, snapshot) {
            String version = snapshot.hasData ? "[v\${snapshot.data}]" : "[v?]";
            return Container(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          imageUrl,
                          height: imageSize,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: screenSize.height * 0.02,
                    ),
                    Padding(
                      padding: EdgeInsets.all(screenSize.width * 0.02),
                      child: Text("Oops, something went wrong!",
                          style: WizzerTypography.socialText
                              .copyWith(fontSize: 20, color: WizzerColor.red5)),
                    ),
                    if (!connectionProblem)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            screenSize.width * 0.1,
                            screenSize.height * 0.01,
                            screenSize.width * 0.1,
                            0.0),
                        child: Container(
                          height: screenSize.height * 0.12,
                          color: WizzerColor.grey1,
                          child: Scrollbar(
                            thumbVisibility: true,
                            trackVisibility: true,
                            controller: scrollController,
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SelectableText(
                                  version + ' ' + errorMessage!,
                                  style: WizzerTypography.socialText
                                      .copyWith(fontSize: 17),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (!connectionProblem)
                      SizedBox(
                        height: screenSize.height * 0.005,
                      ),
                    if (!connectionProblem)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: screenSize.height * 0.005),
                          child: Icon(
                            Icons.arrow_upward_rounded,
                            color: WizzerColor.black1,
                          ),
                        ),
                      ),
                    if (!connectionProblem)
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              screenSize.width * 0.11,
                              0.0,
                              screenSize.width * 0.11,
                              screenSize.height * 0.01),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "This gibberish above could help to solve the issue, please send it to us. ",
                                  style: WizzerTypography.socialText.copyWith(
                                    fontSize: 14,
                                    color: WizzerColor.black1,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: "Click here to copy it.",
                                  style: WizzerTypography.socialText.copyWith(
                                    fontSize: 14,
                                    color: WizzerColor.blueLink1,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      if (errorMessage != null) {
                                        await Clipboard.setData(
                                          new ClipboardData(
                                              text: errorMessage!),
                                        ).then(
                                          (result) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Copied to your clipboard!'),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    connectionProblem
                        ? Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                  screenSize.width * 0.11,
                                  0.0,
                                  screenSize.width * 0.11,
                                  screenSize.height * 0.01),
                              child: Text(
                                "Please check your connection, and try to restart the app.",
                                textAlign: TextAlign.center,
                                style: WizzerTypography.socialText.copyWith(
                                  fontSize: 14,
                                  color: WizzerColor.black1,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                  screenSize.width * 0.11,
                                  0.0,
                                  screenSize.width * 0.11,
                                  screenSize.height * 0.01),
                              child: Text(
                                "Please try to restart the app.",
                                textAlign: TextAlign.center,
                                style: WizzerTypography.socialText.copyWith(
                                  fontSize: 14,
                                  color: WizzerColor.orange1,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                    SizedBox(
                      height: screenSize.height * 0.01,
                    ),
                    Obx(
                      () => Center(
                        child: restarting.value
                            ? Padding(
                                padding:
                                    EdgeInsets.all(screenSize.height * 0.008),
                                child: CircularProgressIndicator(
                                  color: Color.fromRGBO(247, 152, 36, 1),
                                ),
                              )
                            : Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenSize.width * 0.1,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromRGBO(185, 113, 27, 1),
                                        offset: Offset(0, 5),
                                        blurRadius: 0,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      fixedSize: Size(
                                        MediaQuery.of(context).size.width * 1,
                                        MediaQuery.of(context).size.height *
                                            0.048,
                                      ),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      backgroundColor:
                                          Color.fromRGBO(247, 152, 36, 1),
                                      elevation: 5,
                                    ),
                                    onPressed: () async {
                                      log(networkController.connectionType
                                          .toString());
                                      if (networkController.connectionType ==
                                          0) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Check your network connection and try again.'),
                                          ),
                                        );
                                        return;
                                      }
                                      restarting.value = true;
                                      await RestartWidget.restartApp(context);

                                      restarting.value = false;
                                    },
                                    child: Text(
                                      'Restart the app',
                                      style: TextStyle(
                                        fontFamily: 'Futura',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        color: Color.fromRGBO(255, 255, 255, 1),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}

  """;
}
