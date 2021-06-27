import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inneu/components/menuItems.dart';
import 'package:inneu/preloadData.dart';
import 'package:inneu/theme.dart';
import 'package:inneu/versionConfig.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class AboutPage extends StatelessWidget {

  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("关于"),
      ),
      backgroundColor: ThemeRegular.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(ThemeRegular.cardMargin),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: ThemeRegular.cardBackgroundColor,
                borderRadius: ThemeRegular.cardRadius,
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(25),
                    child: Image(
                      height: MediaQuery.of(context).size.width*0.4,
                      image: AssetImage("assets/images/logo.png"),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 4, 20, 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("在东大", style: TextStyle(
                          fontSize: 26,
                          color: ThemeRegular.textColor,
                          fontFamily: "SourceHanSans"
                        )),
                        Container(
                          child: Text("v${VersionConfig.versionStr}", style: TextStyle(
                            fontSize: 20,
                            color: ThemeRegular.textColor,
                            fontWeight: FontWeight.w300
                          )),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width-2*ThemeRegular.cardMargin,
                    color: ThemeRegular.backgroundColor,
                    height: 1,
                    margin: EdgeInsets.fromLTRB(0, 4, 0, 4),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Row(
                      children: [
                        Text("简介", style: TextStyle(
                          fontSize: 20,
                          color: ThemeRegular.themeTextColor
                        ))
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Text(VersionConfig.description),
                  ),
                ],
              ),
            ),
            MenuItems(
              data: [
                MenuItem(
                    icon: Icon(Icons.update),
                    name: "检查更新",
                    onTap: () async {
                      VersionConfig.checkUpdate(context, true);
                    }
                ),
                MenuItem(
                    icon: Icon(Icons.group),
                    name: "加入用户QQ群",
                    right: Text("721423324", style: TextStyle(
                        fontSize: 12,
                        color: ThemeRegular.textColor
                    )),
                    onTap: () async {
                      String launchUrl = "mqqapi://card/show_pslcard?src_type=internal&version=1&uin=721423324&card_type=group&source=qrcode";
                      if(await canLaunch(launchUrl)) {
                        launch(launchUrl);
                      }
                    }
                ),
                MenuItem(
                  icon: Icon(Icons.info_outline),
                  name: "版本号",
                  right: Text(Platform.isAndroid? VersionConfig.versionStr : VersionConfig.iosVersionStr, style: TextStyle(
                    fontSize: 12,
                    color: ThemeRegular.textColor
                  )),
                  onTap: () {
                    if (_count++ == 8) {
                      Fluttertoast.showToast(
                        msg: "这里没彩蛋哦",
                        textColor: ThemeRegular.textColor,
                      );
                      return;
                    }
                    if (_count == 200) {
                      Fluttertoast.showToast(
                        msg: "这里真没彩蛋哦",
                        textColor: ThemeRegular.textColor,
                      );
                    }
                  }
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}