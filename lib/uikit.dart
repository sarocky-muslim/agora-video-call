import 'package:flutter/material.dart';
import 'package:agora_uikit/agora_uikit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AgoraClient client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
      appId: 'df92080537b34cf8938ddad34cfff043',
      channelName: 'mychannel',
    ),
    enabledPermission: [
      Permission.camera,
      Permission.microphone,
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Agora UIKit'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              AgoraVideoViewer(
                client: AgoraClient(
                  agoraConnectionData: AgoraConnectionData(
                    appId: 'df92080537b34cf8938ddad34cfff043',
                    channelName: 'mychannel',
                  ),
                  enabledPermission: [
                    Permission.camera,
                    Permission.microphone,
                  ],
                ),
              ),
              AgoraVideoButtons(
                client: AgoraClient(
                  agoraConnectionData: AgoraConnectionData(
                    appId: 'df92080537b34cf8938ddad34cfff043',
                    channelName: 'mychannel',
                  ),
                  enabledPermission: [
                    Permission.camera,
                    Permission.microphone,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
