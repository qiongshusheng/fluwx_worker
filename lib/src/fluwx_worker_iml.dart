import 'dart:async';

import 'package:flutter/services.dart';

import 'response_models.dart';
import 'share_models.dart';

const Map<Type, String> _shareModelMethodMapper = {
  WeChatShareTextModel: "shareText",
  WeChatShareImageModel: "shareImage",
  WeChatShareFileModel: "shareFile",
  WeChatShareVideoModel: "shareVideo",
  WeChatShareWebPageModel: "shareWebPage",
  WeChatShareMiniProgramModel: "shareMiniProgram",
};

StreamController<WeChatWorkAuthResponse> _responseAuthController =
    StreamController.broadcast();

/// Response from auth
Stream<WeChatWorkAuthResponse> get responseFromAuth =>
    _responseAuthController.stream;

final MethodChannel _channel = const MethodChannel('fluwx_worker')
  ..setMethodCallHandler(_handler);

Future<dynamic> _handler(MethodCall methodCall) {
  if ("onAuthResponse" == methodCall.method) {
    _responseAuthController
        .add(WeChatWorkAuthResponse.fromMap(methodCall.arguments));
  }

  return Future.value(true);
}

//// 注册
Future register(
    {required String schema,
    required String corpId,
    required String agentId}) async {
  return await _channel.invokeMethod('registerApp', {
    'schema': schema,
    'corpId': corpId,
    'agentId': agentId,
  });
}

/// 检测是否安装微信
Future isWeChatInstalled() async {
  return await _channel.invokeMethod("isWeChatInstalled");
}

/// 授权登陆
Future sendAuth(
    {required String schema,
    required String appId,
    required String agentId,
    String? state}) async {
  if (state == null || state.isEmpty) {
    state = DateTime.now().millisecondsSinceEpoch.toString();
  }

  return await _channel.invokeMethod('sendAuth',
      {'schema': schema, 'appId': appId, 'agentId': agentId, 'state': state});
}

///Share your requests to WeChat.
///This depends on the actual type of [model].
///see [_shareModelMethodMapper] for detail.
Future<bool> shareToWeChat(WeChatShareBaseModel model) async {
  if (_shareModelMethodMapper.containsKey(model.runtimeType)) {
    var methodChannel = _shareModelMethodMapper[model.runtimeType];
    if (methodChannel == null) {
      throw ArgumentError.value(
          "${model.runtimeType} method channel not found");
    }
    return await _channel.invokeMethod(methodChannel, model.toMap());
  } else {
    return Future.error("no method mapper found[${model.runtimeType}]");
  }
}

void dispose() {
  _responseAuthController.close();
}
