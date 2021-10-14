import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';

import 'model.dart';

/// @author wu chao
/// @project record
/// @date 2021/7/15
class Record extends StatefulWidget {
  Song data;
  String uid;

  Record({this.data, this.uid});

  @override
  _RecordState createState() => _RecordState();
}

class _RecordState extends State<Record> {
  FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  final String _mPath = 'flutter_sound_example.aac';
  File audio;
  num second = 0;
  Timer timer;

  //初始化
  @override
  void initState() {
    _mPlayer.openAudioSession().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });
    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    super.initState();
  }

  Future<void> openTheRecorder() async {
    await _mRecorder.openAudioSession();
    _mRecorderIsInited = true;
  }
  //销毁资源
  @override
  void dispose() {
    _mPlayer.closeAudioSession();
    _mPlayer = null;
    _mRecorder.closeAudioSession();
    _mRecorder = null;
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }
  void record() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        second += 1;
        if (second == 20) {
          stopRecorder();
        }
      });
    });
    _mRecorder
        .startRecorder(
            codec: Codec.aacMP4,
            toFile: _mPath,
            sampleRate: 96000,
            bitRate: 256000,
            numChannels: 2
    )
        .then((value) {
      setState(() {});
    });
  }

  void stopRecorder() async {
    timer.cancel();
    second = 0;
    await _mRecorder.stopRecorder().then((value) {
      setState(() {
        _mplaybackReady = true;
        audio = File(value);
        print(value);
      });
    });
    // _mPathMP3 = await _getAppPath('flutter_sound_example.mp3');
    // await FlutterSoundHelper()
    //     .convertFile(audio.path, Codec.aacADTS, _mPathMP3, Codec.mp3);
    setState(() {});
  }

  // Future<String> _getAppPath(String path) async {
  //   var tempDir = await getApplicationDocumentsDirectory();
  //   var tempPath = tempDir.path;
  //   return tempPath + '/' + path;
  // }

  void play() async {
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder.isStopped &&
        _mPlayer.isStopped);
    _mPlayer
        .startPlayer(
            fromURI: audio.path,
            whenFinished: () {
              setState(() {});
            })
        .then((value) {
      setState(() {});
    });
  }

  void stopPlayer() {
    _mPlayer.stopPlayer().then((value) {
      setState(() {});
    });
  }

// ----------------------------- UI --------------------------------------------

  getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer.isStopped) {
      return null;
    }
    return _mRecorder.isStopped ? record : stopRecorder;
  }

  getPlaybackFn() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder.isStopped) {
      return null;
    }
    return _mPlayer.isStopped ? play : stopPlayer;
  }

  upload() async {
    var formData = FormData.fromMap({
      'check': 'yes',
      'id': widget.data.id,
      'file':
          await MultipartFile.fromFile(audio.path, filename: widget.data.title),
      "uid": widget.uid
    });
    var response;
    try {
      response = await Dio().post(
          'https:///qiangchang/song/setfile',
          data: formData);
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text("Upload failed"),
              actions: <Widget>[
                GestureDetector(
                  child: Text("close"),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            );
          });
      return;
    }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                "${(response.data["code"] == 1000) ? "Uploaded successfully: " : "Upload failed: "}"),
            content: Text("${response.data["message"]}"),
            actions: <Widget>[
              GestureDetector(
                child: Text("close"),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
          ),
          Spacer(
            flex: 1,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text("Song name : ${widget.data.title}"),
          ),
          Spacer(
            flex: 1,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text("Singer : ${widget.data.singer}"),
          ),
          Spacer(
            flex: 1,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("PlayLyrics :"),
                SizedBox(
                  height: 5,
                ),
                Text("${widget.data.playLyrics}"),
              ],
            ),
          ),
          Spacer(
            flex: 1,
          ),
          Spacer(
            flex: 6,
          ),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                        padding: EdgeInsets.fromLTRB(20,0,20,20),
                        child: ListView(
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                    Icons.close
                                    ),
                                  ),
                                ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.end,
                            ),
                            Text("""The "upload failed" cause is displayed

1: There is an error in the song, please change the song

2: Singing out of tune

3: The song is wrong, it is another song with the same name

The same song uploaded repeatedly failed , suggest choose another song.

Try to sing with headphones to reduce the noise during recording.

If you find songs difficult,Click the refresh icon in the upper right corner, and the list of songs will refresh."""),

                          ],
                        ),
                      ));
            },
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text(
                "Some tips",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
          Spacer(
            flex: 1,
          ),
          Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFFAF0E6),
              border: Border.all(
                color: Colors.indigo,
                width: 3,
              ),
            ),
            child: Row(children: [
              ElevatedButton(
                onPressed: getRecorderFn(),
                child: Text(_mRecorder.isRecording ? 'pause' : 'record'),
              ),
              SizedBox(
                width: 20,
              ),
              Visibility(
                visible: _mRecorder.isRecording,
                child: Text('The recording time:$second s'),
              ),
            ]),
          ),
          Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFFAF0E6),
              border: Border.all(
                color: Colors.indigo,
                width: 3,
              ),
            ),
            child: Row(children: [
              ElevatedButton(
                onPressed: getPlaybackFn(),
                //color: Colors.white,
                //disabledColor: Colors.grey,
                child: Text(_mPlayer.isPlaying ? 'stop' : "audition"),
              ),
              SizedBox(
                width: 20,
              ),
              Visibility(
                visible: _mPlayer.isPlaying,
                child: Text('Now playing'),
              ),
            ]),
          ),
          Spacer(
            flex: 2,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                child: Container(
                  width: 180,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: audio != null ? Colors.blue : Colors.black12,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "upload",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                onTap: () {
                  if (!_mPlayerIsInited ||
                      !_mplaybackReady ||
                      !_mRecorder.isStopped) return;
                  upload();
                },
              ),
            ],
          ),
          Spacer(
            flex: 2,
          ),
        ],
      ),
    );
  }
}
