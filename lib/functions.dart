
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inneu/components/functionList.dart';
import 'package:inneu/pages/card/cardPage.dart';
import 'package:inneu/pages/examPage.dart';
import 'package:inneu/pages/gpaCalculatorPage.dart';
import 'package:inneu/pages/gradePage.dart';
import 'package:inneu/pages/library/libraryIndex.dart';
import 'package:inneu/pages/loginPage.dart';
import 'package:inneu/pages/schedule/schedulePage.dart';
import 'package:inneu/pages/smartNEU.dart';
import 'package:inneu/event.dart';
import 'package:inneu/preloadData.dart';

class Functions extends StatefulWidget {

  @override
  _FunctionsState createState() => _FunctionsState();

}

class _FunctionsState extends State<Functions> {

  _reload() {
    setState(() {});
  }

  _showLoginDialog() {
    showDialog(
        context: context,
        builder: (BuildContext ctx) => CupertinoAlertDialog(
          content: Text("此功能需要绑定您的一网通办账号,您当前还没有绑定一网通办账号，是否前往绑定？"),
          actions: [
            CupertinoDialogAction(
              child: Text("确定"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage() )
                );
              },
            ),
            CupertinoDialogAction(
              child: Text("取消"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        )
    );
  }

  @override
  void dispose() {
    EventBus.removeListen("login", _reload);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    EventBus.addListener("login", _reload);
  }

  @override
  Widget build(BuildContext context) {

    List<FunctionItem> studyItems = [];

    if (!PreloadData.isLogin || PreloadData.userType == "undergraduate") {
      studyItems = [
        FunctionItem(
            icon: Icon(Icons.grade, size: 45,),
            onTap: (){
              if (PreloadData.isLogin) {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GradePage() )
                );
              } else {
                _showLoginDialog();
              }
            },
            name: "成绩"
        ),
        FunctionItem(
            icon: Icon(Icons.speaker_notes, size: 45,),
            onTap: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExamPage())
              );
            },
            name: "考试日程"
        ),
        FunctionItem(
            icon: Icon(Icons.computer, size: 45,),
            onTap: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GpaCalculatorPage())
              );
            },
            name: "GPA计算器"
        ),
        FunctionItem(
            icon: Icon(Icons.schedule, size: 45,),
            onTap: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SchedulePage())
              );
            },
            name: "课程表"
        ),
        FunctionItem(
            icon: Icon(Icons.local_library, size: 45,),
            onTap: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LibraryIndexPage())
              );
            },
            name: "图书馆"
        ),
      ];
    } else if (PreloadData.userType == "postgraduate") {
      studyItems.add(FunctionItem(
          icon: Icon(Icons.local_library, size: 45,),
          onTap: (){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LibraryIndexPage())
            );
          },
          name: "图书馆"
      ));
    }



    studyItems.addAll(PreloadData.studyFunctions.map((e) => FunctionItem(
      name: e["name"],
      onTap: () {
        PreloadData.method.invokeMethod("open", json.encode({
          "url": e["url"],
          "title": e["name"]
        }));
      },
      icon: e["icon"]==null || e["icon"]==""? Icon(Icons.apps, size: 45,) : Image.network(e["icon"], height: 45, width: 45)
    )).toList());

    List<FunctionItem> lifeItems = [
      FunctionItem(
          icon: Icon(Icons.credit_card, size: 45,),
          onTap: (){
            if (PreloadData.isLogin) {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CardPage())
              );
            } else {
              _showLoginDialog();
            }
          },
          name: "校园卡"
      ),
      FunctionItem(
          icon: Icon(Icons.menu, size: 45,),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SmartNEU())
            );
          },
          name: "智慧东大"
      ),
    ];

    lifeItems.addAll(PreloadData.lifeFunctions.map((e) => FunctionItem(
        name: e["name"],
        onTap: () {
          PreloadData.method.invokeMethod("open", json.encode({
            "url": e["url"],
            "title": e["name"]
          }));
        },
        icon: e["icon"]==null || e["icon"]==""? Icon(Icons.apps, size: 45,) : Image.network(e["icon"], height: 45, width: 45)
    )).toList());

    return Column(
      children: <Widget>[
        FunctionList(
          title: "学习在东大",
          items: studyItems,
        ),
        FunctionList(
          title: "生活在东大",
          items: lifeItems,
        ),
      ],
    );
  }
}