import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:record/model.dart';
import 'package:record/record.dart';

import 'id.dart';

/// @author wu chao
/// @project record
/// @date 2021/7/15
class SoundList extends StatefulWidget {
  String uid;

  SoundList({Key key, this.uid}) : super(key: key);

  @override
  _SoundListState createState() => _SoundListState();
}

class _SoundListState extends State<SoundList> {
  SoundListData soundListData;

  String count = "0";

  @override
  void initState() {
    super.initState();
    getHttp();
    getCount();
  }

  void getCount() async {
    try {
      var response = await Dio().get(
          'https:///qiangchang/song/uidcount?uid=${widget.uid}');
      if (response.data == null || response.data["data"] == null) return;
      count = response.data["data"]["total"].toString();
      setState(() {
        log("getCount");
      });
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text("An error occurs, please restart the APP"),
            );
          });
      log(e);
    }
  }

  void getHttp() async {
    try {
      var response = await Dio().get(
          'https:///qiangchang/song/random?status=pending&count=8');
      if (response.data == null || response.data["data"] == null) return;
      soundListData = SoundListData.fromJson(response.data["data"]);
      setState(() {
        log("getHttp");
      });
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text("An error occurs, please restart the APP"),
            );
          });
      log(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Spacer(flex: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InputId(),
                      ));
                },
                child: Container(
                    color: Colors.blue,
                    padding: EdgeInsets.all(15),
                    child: Text(
                      "Account:${widget.uid}",
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              Text("Recorded songs:$count"),
              GestureDetector(
                onTap: (){
                  getHttp();
                  getCount();
                },
                  child: Icon(
                Icons.refresh,
                size: 30,
              ))
            ],
          ),
          Expanded(
            flex: 18,
            child: ListView(
              children: [
                if (soundListData != null)
                  for (Song soundData in soundListData.songs)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Record(
                                data: soundData,
                                uid: widget.uid,
                              ),
                            )).then((value) {
                          getHttp();
                          getCount();
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 1)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Song name:${soundData.title}"),
                            SizedBox(height: 15),
                            Text("Singer:${soundData.singer}"),
                          ],
                        ),
                      ),
                    )
              ],
            ),
          )
        ],
      ),
    );
  }
}
