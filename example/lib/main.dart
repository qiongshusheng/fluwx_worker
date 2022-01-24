import 'package:flutter/material.dart';
import 'package:fluwx_worker/fluwx_worker.dart' as fluwxWorker;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _result = 'None';

  final schema = 'xxxxxxxxxxxxxxxx'; //替换成自己的
  final corpId = 'xxxxxxx';
  final agentId = 'xxxxx';

  final miniprogramPath = '/pages/index/index';
  final username = 'xxxxxxxx@app'; // 小程序原始id

  @override
  void initState() {
    super.initState();
    _initFluwx();

    //等待授权结果
    fluwxWorker.responseFromAuth.listen((data) async {
      if (data.errCode == 0) {
        _result = data.code; //后续用这个code再发http请求取得UserID
      } else if (data.errCode == 1) {
        _result = '授权失败';
      } else {
        _result = '用户取消';
      }
      setState(() {});
    });
  }

  _initFluwx() async {
    await fluwxWorker.register(
        schema: schema, corpId: corpId, agentId: agentId);
    var result = await fluwxWorker.isWeChatInstalled();
    print("is installed $result");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            TextButton(
              onPressed: () {
                fluwxWorker.sendAuth(
                    schema: schema, appId: corpId, agentId: agentId);
              },
              child: const Text('企业微信授权'),
            ),
            TextButton(
              onPressed: () {
                fluwxWorker.shareToWeChat(fluwxWorker.WeChatShareMiniProgramModel(
                    title: '分享到小程序',
                    path: miniprogramPath,
                    username: username,
                    hdImageData: fluwxWorker.WeChatImage.network(
                        'http://pic.616pic.com/ys_bnew_img/00/06/27/TWk2P5YJ5k.jpg',
                        suffix: '.jpg')));
              },
              child: const Text('分享到小程序'),
            ),
            TextButton(
              onPressed: () {
                fluwxWorker.shareToWeChat(fluwxWorker.WeChatShareTextModel(
                  source: '分享文字',
                ));
              },
              child: const Text('分享文字'),
            ),
          ],
        ),
      ),
    );
  }
}
