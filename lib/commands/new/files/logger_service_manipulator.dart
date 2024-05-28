import '../../../interfaces/service_manipulator.dart';
import 'constant_manipulator.dart';

class LoggerServiceManipulator extends ServiceManipulator {
  @override
  Future<void> create(
      {bool initialize = false, String projectName = ''}) async {
    final ConstantManipulator constantManipulator = ConstantManipulator();
    await constantManipulator.addConstant(
      'static const bool devMode = true;',
    );
    await super.create();
  }

  @override
  String get name => 'LoggerService';

  @override
  String get path => 'lib/service/logger_service.dart';

  @override
  String content() {
    return r"""
// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../util/constants.dart';

class LoggerService extends GetxService {
  final RxList<Widget> _logs = <Widget>[].obs;
  final bool devMode = Constants.devMode;

  void log(String? message, {StackTrace? stackTrace, dynamic error}) {
    if (devMode) {
      if (message != null) {
        debugPrint(message);
        _addEvent(message);
      }
      if (error != null) {
        debugPrint(error.toString());
        _addEvent(error.toString());
      }
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
        _addEvent(stackTrace.toString());
      }
    }
  }

  void _addEvent(dynamic event) {
    _logs.value.add(
      Text(
        '=> $event',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  void show() {
    Get.dialog<Widget>(
      Card(
        elevation: 6,
        color: Colors.black87,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: MediaQuery.of(Get.overlayContext!).size.width,
          height: 200,
          child: Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Logs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  return ListView(
                    reverse: true,
                    padding: const EdgeInsets.all(6),
                    children: _logs.value.reversed.toList(),
                  );
                }),
              ),

              //clear logs button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                    // ignore: inference_failure_on_generic_invocation
                    onPressed: Get.back,
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _logs.value.clear();
                      _logs.refresh();
                    },
                    child: const Text(
                      'Clear Logs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
""";
  }
}
