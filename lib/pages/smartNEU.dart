import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inneu/components/menuItems.dart';
import 'package:inneu/components/titleLine.dart';
import 'package:inneu/pages/loginPage.dart';
import 'package:inneu/preloadData.dart';
import 'package:inneu/service/request.dart';
import 'package:inneu/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class _SmartNEUItem {
  String url;
  String name;
  Widget icon;
  bool allowGuest;
  bool nativeLogin = false;

  _SmartNEUItem({this.url, this.name, this.icon, this.allowGuest, this.nativeLogin});

}

class SmartNEU extends StatefulWidget {
  
  @override
  _SmartNEUState createState() => _SmartNEUState();
  
}

class _SmartNEUState extends State<SmartNEU> {
  
  List<_SmartNEUItem> _data = [];

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
  
  
  _openService(BuildContext context,String url, String name,[bool nativeLogin = false]) async {

    _showLoading(context);


    print(url);

    if (nativeLogin) {
      var cookieStr = await getSSOCookie();
      if (cookieStr != null) {

        PreloadData.method.invokeMethod("set_cookie", json.encode(cookieStr.split(";").map((e) => {
          "cookie": e.trim(),
          "domain": "pass.neu.edu.cn"
        }).toList()));
        await Future.delayed(Duration(milliseconds: 150));
        Navigator.of(context, rootNavigator: true).pop();

        PreloadData.method.invokeMethod("open", json.encode({
          "url": url,
          "title": name
        }));

        return;
      }

    }

    String jumpUrl = await getLoginUrl(url);
    Navigator.of(context, rootNavigator: true).pop();
    print(jumpUrl);
    if (url != null) {
      // launch(jumpUrl);
      PreloadData.method.invokeListMethod("open", json.encode({
        "url": jumpUrl,
        "title": name
      }));
    } else {
      Fluttertoast.showToast(
        msg: "??????????????????",
        textColor: ThemeRegular.textColor,
        backgroundColor: ThemeRegular.backgroundColor,
      );
    }
  }
  
  loadData() async {
    _showLoading(context);
    try {
      var resp = await getNetData("https://cdn.jsdelivr.net/gh/yearsyan/inneu-public/app-status/smart-neu.json");
      print(resp);
      setState(() {
        _data = List<Map<String,dynamic>>.from(resp).map((e) => _SmartNEUItem(
          nativeLogin: e["native_login"],
          url: e["url"],
          name: e["name"],
          allowGuest: e["allow_guest"],
          icon: e["icon"] == null ? Icon(Icons.label_outline, size: 28,): Image.network(e["icon"],height: 28, width: 28)
        )).toList();
      });

    } catch (e) {
      print(e);
      setState(() {
        _data = [];
      });
    }
    Navigator.of(context, rootNavigator: true).pop();
  }
  
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      loadData();
    });
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
            MenuItems(
              data: _data.map((e) => MenuItem(
                  name: e.name,
                  icon: e.icon,
                  onTap: () {
                    if (e.allowGuest) {
                      PreloadData.method.invokeListMethod("open", "${e.name}#!!${e.url}");
                    } else {
                      if (PreloadData.isLogin) {
                        _openService(context, e.url, e.name, e.nativeLogin);
                      } else {
                        showDialog(
                            context: context,
                            builder: (BuildContext ctx) => CupertinoAlertDialog(
                              content: Text("??????????????????????????????????????????????????????????????????"),
                              actions: [
                                CupertinoDialogAction(
                                  child: Text("??????"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => LoginPage() )
                                    );
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: Text("??????"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            )
                        );
                      }
                    }
                  }
              )).toList(),
            ),
            TitleLine(
              title: "????????????",
              eng: "Q&A",
            ),
            Container(
              margin: EdgeInsets.all(15),
              child: Text(
                "??????????????????????????????App????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????App????????????",
                style: TextStyle(
                  color: ThemeRegular.textColor,
                  fontSize: 12,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(15),
              child: Text(
                "???????????????????????????????????????????????????App???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????portal.neu.edu.cn??????????????????",
                style: TextStyle(
                  color: ThemeRegular.textColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}