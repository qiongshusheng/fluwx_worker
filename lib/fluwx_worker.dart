
import 'dart:async';

import 'package:flutter/services.dart';

class FluwxWorker {
  static const MethodChannel _channel = MethodChannel('fluwx_worker');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
