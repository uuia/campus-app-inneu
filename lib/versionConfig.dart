import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inneu/preloadData.dart';
import 'package:inneu/service/request.dart';
import 'package:inneu/theme.dart';


class VersionConfig {
  static final String versionStr = "0.1.2";
  static final int versionNum = 12;
  static final bool marketVersion = false;
  static final String description = "在东大是一款第三方信息聚合App，它致力于帮助我们东北大学的学生提供更方便的校园服务";
  static final int iosId = 0;
  static final String iosVersionStr = "0.0.0";
  static final String packageName = "com.neuyan.inneu";

  static _startLoading(BuildContext context) {
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

  static Future<bool> checkUpdate(BuildContext context, [bool showRes = false]) async {

    if (context != null) {
      _startLoading(context);
    }

    var data = await getNetData("https://cdn.jsdelivr.net/gh/yearsyan/inneu-public/app-status/version.json");
    if (context != null) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (Platform.isAndroid) {
      int latestVersion = data["android"]["version_num"];
      if (versionNum < latestVersion) {
        if (data["android"]["market_available"]) {

        } else {

          PreloadData.method.invokeMethod("update", json.encode({
            "url": data["android"]["download_url"],
            "content": data["android"]["change_log"]
          }));

        }
        return true;
      } else {

        if (showRes == true) {
          Fluttertoast.showToast(
              msg: "已经是最新版本",
              backgroundColor: ThemeRegular.cardBackgroundColor,
              textColor: ThemeRegular.textColor
          );
        }

        return false;
      }
    } else if (Platform.isIOS) {

    }
    return false;
  }

}