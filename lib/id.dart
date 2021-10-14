import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/sound_list.dart';

/// @author wu chao
/// @project flutter_record
/// @date 2021/7/19
class InputId extends StatefulWidget {
  const InputId({Key key}) : super(key: key);

  @override
  _InputIdState createState() => _InputIdState();
}

class _InputIdState extends State<InputId> {
  TextEditingController textEditingController = TextEditingController();
  bool showFlag = false;

  @override
  void initState() {
    super.initState();
    getPermission();
  }

  getPermission() async {
    var status = await Permission.speech.status;
    if (status.isDenied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.speech,
      ].request();
      print(statuses[Permission.location]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              controller: textEditingController,
              decoration: InputDecoration(labelText: "account name"),
            ),
          ),
          Visibility(
              visible: showFlag,
              child: Text(
                "You must enter an account name",
                style: TextStyle(color: Colors.red),
              )),
          SizedBox(height: 50),
          GestureDetector(
            onTap: () {
              if (textEditingController.text == "") {
                showFlag = true;
                setState(() {});
                return;
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SoundList(uid: textEditingController.text),
                  ));
            },
            child: Container(
              width: 200,
              height: 50,
              color: Colors.blue,
              alignment: Alignment.center,
              child: Text(
                "save",
                style: TextStyle(fontSize: 25),
              ),
            ),
          )
        ],
      ),
    );
  }
}
