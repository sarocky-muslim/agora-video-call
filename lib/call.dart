import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:audioplayers/audioplayers.dart';

const appId = '74999f04f6ac43f196019fb48becc653';
const token =
    '00674999f04f6ac43f196019fb48becc653IADRJ70bDhUkKB8IfdtHFLTBvGGtcJ91uEN77qV2M6Q1jVAkJPi379yDIgCj1gAAeEIkYQQAAQB4QiRhAwB4QiRhAgB4QiRhBAB4QiRh';
const channelName = 'U2DQMGO8QAAY';

class Call extends StatefulWidget {
  const Call({Key? key}) : super(key: key);

  @override
  _CallState createState() => _CallState();
}

// App state class
class _CallState extends State<Call> {
  bool _joined = false;
  int _remoteUid = 0;
  bool _switch = false;
  bool _microphone = true;
  bool _video = true;
  bool _backCamera = false;
  bool _speaker = false;

  final _audioPlayer = AudioPlayer();
  final _assetPlayer = AudioCache();
  AudioPlayer? _playingAudio;

  // bool _isTarget = false;
  // double? _dragLeft = 20.0;
  // double? _dragRight;
  // double? _targetLeft;
  // double? _targetRight = 20.0;

  RtcEngine? _rtcEngine;

  @override
  void initState() {
    super.initState();
    initEngine();
    // initPlatformState();
  }

  // init agora engine
  void initEngine() async {
    try {
      await [Permission.camera, Permission.microphone].request();

      RtcEngineContext context = RtcEngineContext(appId);
      _rtcEngine = await RtcEngine.createWithContext(context);

      // Rtc Engine Event Handler
      _setEvent();

      await _rtcEngine!.enableVideo();
      await _rtcEngine!.enableInEarMonitoring(true);
      await _rtcEngine!.joinChannel(token, channelName, null, 0);
    } catch (error) {
      print(SnackBar(content: Text(error.toString())));
    }
  }

  void _setEvent() {
    _rtcEngine!.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print('joinChannelSuccess $channel $uid');
          setState(() {
            _joined = true;
          });
        },
        userJoined: (int uid, int elapsed) {
          print('userJoined $uid');
          setState(() {
            _remoteUid = uid;
          });
        },
        userOffline: (int uid, UserOfflineReason reason) {
          print('userOffline $uid');
          setState(() {
            _remoteUid = 0;
          });
        },
      ),
    );
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        // appBar: AppBar(
        //   title: const Text('Call'),
        // ),
        body: Container(
          child: Stack(
            children: <Widget>[
              !_video
                  ? Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                        colors: [Colors.tealAccent, Colors.teal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )),
                    )
                  : _bigView(),
              _remoteUid == 0 || !_video ? Container() : _smallView(),
              !_video ? Center() : _switchCameraButton(),
              _buttonView(),
              _endButton(),
              _remoteUid == 0 ? _callingText() : Container(),
              // _isTarget ? _dragTarget() : Container(),
            ],
          ),
        ),
      ),
    );
  }

  _bigView() {
    return Positioned(
      left: 0.0,
      right: 0.0,
      top: 0.0,
      bottom: 0.0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: _switch ? _renderLocalPreview() : _renderRemoteVideo(),
      ),
    );
  }

  _smallView() {
    return Positioned(
      left: 20.0,
      top: 40.0,
      child: InkWell(
        onTap: () {
          setState(() {
            _switch = !_switch;
            print(_switch);
          });
        },
        child: Draggable(
          data: 'myVideo',
          child: Container(
            width: 70,
            height: 100,
            child: _switch ? _renderRemoteVideo() : _renderLocalPreview(),
            decoration: BoxDecoration(color: Colors.transparent),
          ),
          feedback: Material(
            child: Container(
              width: 70,
              height: 100,
              child: _switch ? _renderRemoteVideo() : _renderLocalPreview(),
              decoration: BoxDecoration(color: Colors.transparent),
            ),
          ),
          childWhenDragging: Container(),
          onDragStarted: () {
            setState(() {
              // _isTarget = true;
            });
          },
          onDragCompleted: () {
            setState(() {
              // _isTarget = false;
            });
          },
          onDraggableCanceled: (valocity, offset) {
            setState(() {
              // _isTarget = false;
            });
          },
        ),
      ),
    );
  }

  _buttonView() {
    return Positioned(
      width: MediaQuery.of(context).size.width,
      bottom: 20.0,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: _switchSpeaker,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      _speaker ? Icons.volume_down : Icons.volume_up,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 15),
                InkWell(
                  onTap: _microphoneOnOff,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      _microphone ? Icons.mic : Icons.mic_off,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 15),
                InkWell(
                  onTap: _videoOnOff,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      _video ? Icons.videocam : Icons.videocam_off,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 15),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _callingText() {
    return Positioned(
      width: MediaQuery.of(context).size.width,
      top: MediaQuery.of(context).size.height / 2,
      child: Container(
        child: Column(
          children: [
            Text(
              'Dr. Shamsul Alam Rocky',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Calling...',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _endButton() {
    return Positioned(
      width: MediaQuery.of(context).size.width,
      bottom: 100.0,
      child: InkWell(
        onTap: _callEnd,
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.red,
          child: Icon(
            _remoteUid == 0 ? Icons.close : Icons.call_end,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  _switchCameraButton() {
    return Positioned(
      top: 40.0,
      right: 20.0,
      child: InkWell(
        onTap: _switchCamera,
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          child: Icon(
            _backCamera ? Icons.camera_alt : Icons.cameraswitch,
            size: 30,
          ),
        ),
      ),
    );
  }

  // _dragTarget() {
  //   return Positioned(
  //     left: _targetLeft,
  //     right: _targetRight,
  //     top: 20.0,
  //     child: DragTarget(
  //       builder: (context, acceptData, rejectData) => Container(
  //         width: 70,
  //         height: 100,
  //         color: Colors.grey,
  //         child: Center(child: Text('target-1')),
  //       ),
  //       onAccept: (data) {
  //         print('onAccept');
  //         setState(() {
  //           if (_dragRight == null) {
  //             _dragLeft = null;
  //             _dragRight = 20.0;
  //             _targetLeft = 20.0;
  //             _targetRight = null;
  //           } else {
  //             _dragLeft = 20.0;
  //             _dragRight = null;
  //             _targetLeft = null;
  //             _targetRight = 20.0;
  //           }
  //         });
  //       },
  //       onWillAccept: (data) => true,
  //     ),
  //   );
  // }

  // Local preview
  Widget _renderLocalPreview() {
    if (_joined) {
      return RtcLocalView.SurfaceView();
    } else {
      print('Please join channel first');
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  // Remote preview
  Widget _renderRemoteVideo() {
    if (_remoteUid != 0) {
      return RtcRemoteView.SurfaceView(
        uid: _remoteUid,
        channelId: channelName,
      );
    } else {
      print('Please wait remote user join');
      return _renderLocalPreview();
      // return Center(
      //   child: CircularProgressIndicator(),
      // );
    }
  }

  Future _callEnd() async {
    await _rtcEngine!.leaveChannel();
    await _rtcEngine!.destroy();
    Navigator.of(context).pop();
  }

  void _switchCamera() async {
    await _rtcEngine!.switchCamera().then((value) {
      setState(() {
        _backCamera = !_backCamera;
      });
    });
  }

  void _switchSpeaker() async {
    await _rtcEngine!.setEnableSpeakerphone(_speaker).then((value) {
      setState(() {
        _speaker = !_speaker;
      });
    });
  }

  void _videoOnOff() async {
    _rtcEngine!.muteLocalVideoStream(_video).then((value) {
      setState(() {
        _video = !_video;
      });
    });
  }

  void _microphoneOnOff() async {
    _rtcEngine!.muteLocalAudioStream(_microphone).then((value) {
      setState(() {
        _microphone = !_microphone;
      });
    });
  }

  // _playLocal() async {
  //   var audioPath = 'Outgoing_Ringtone_Music.mp3';
  //   try {
  //     if (_remoteUid == 0) {
  //       _playingAudio = await _assetPlayer.loop(audioPath);
  //     } else {
  //       await _playingAudio!.stop();
  //     }
  //   } catch (error) {
  //     print('catch _playLocal ${error.toString()}');
  //   }
  // }
}
