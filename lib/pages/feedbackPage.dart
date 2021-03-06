import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inneu/components/titleLine.dart';
import 'package:inneu/preloadData.dart';
import 'package:inneu/theme.dart';

class FeedBackPage extends StatelessWidget{

  final TextEditingController _controller = TextEditingController();

  _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Color.fromARGB(20, 255, 255, 255),
          body: Center(
            child: Container(
              decoration: BoxDecoration(
                  color: ThemeRegular.cardBackgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              height: 120,
              width: 120,
              child: Image(image: AssetImage("assets/images/loading.gif")),
            ),
          ),
        ),
      ),
    );
  }

  _postFeedback(BuildContext context) async {

    _showLoading(context);
    Dio dio = Dio();

    var ts = DateTime.now().millisecondsSinceEpoch;
    var _sign = Utf8Encoder().convert((PreloadData.userInfo["ID_NUMBER"]??"") + PreloadData.session + ts.toString() + "inneu1923");
    print(PreloadData.userInfo["ID_NUMBER"]??"" + PreloadData.session + ts.toString() + "inneu1923");

    try {
      var data = {
        "session": PreloadData.session,
        "signature": sha256.convert(_sign).toString().toLowerCase(),
        "user_id": PreloadData.userInfo["ID_NUMBER"],
        "content": _controller.text,
        "ts": ts
      };
      print(data);
      var resp = await dio.post("https://inneu-api.neuyan.com/app/feedback", data: data);
      print(resp.data);

      if (resp.data["code"] == 0) {

        FocusScope.of(context).requestFocus(FocusNode());

        await Future.delayed(Duration(milliseconds: 500));
        Fluttertoast.showToast(
          msg: "????????????,?????????????????????????????????",
          backgroundColor: ThemeRegular.cardBackgroundColor,
          textColor: ThemeRegular.textColor,
        );

        _controller.text = "";
      } else {
        throw Exception();
      }
    } catch(e) {
      print(e);
      Fluttertoast.showToast(
        msg: "????????????????????????",
        backgroundColor: ThemeRegular.cardBackgroundColor,
        textColor: ThemeRegular.textColor
      );
    }

    Navigator.of(context, rootNavigator: true).pop();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("????????????"),
      ),
      backgroundColor: ThemeRegular.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(ThemeRegular.cardMargin),
              child: TextField(
                controller: _controller,
                minLines: 5,
                maxLines: 10,
                maxLength: 200,
                style: TextStyle(
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  fillColor: ThemeRegular.cardBackgroundColor,
                  filled: true,
                  contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder()
                ),
              ),
            ),
             Container(
               padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
               child: SizedBox(
                 height: 40,
                 width: MediaQuery.of(context).size.width*0.8,
                 child: RaisedButton(
                   elevation: 0,
                   onPressed: () {
                     if (_controller.text.length == 0) {
                       Fluttertoast.showToast(
                         msg: "??????????????????????????????",
                         textColor: ThemeRegular.textColor,
                         backgroundColor: ThemeRegular.cardBackgroundColor
                       );
                       return;
                     }
                     _postFeedback(context);
                   },
                   color: ThemeRegular.mainColor,
                   textColor: ThemeRegular.backgroundColor,
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.all(Radius.circular(20))
                   ),
                   child: Text("??????"),
                 ),
               ),
             ),
            TitleLine(
              title: "??????",
              eng: "Notes",
            ),
            Container(
              margin: EdgeInsets.all(15),
              child: Text(
                "?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????",
                style: TextStyle(
                  color: ThemeRegular.textColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}