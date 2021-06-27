import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inneu/components/menuItems.dart';
import 'package:inneu/event.dart';
import 'package:inneu/pages/aboutPage.dart';
import 'package:inneu/pages/feedbackPage.dart';
import 'package:inneu/pages/loginPage.dart';
import 'package:inneu/pages/setting/setting.dart';
import 'package:inneu/preloadData.dart';
import 'package:inneu/service/request.dart';
import 'package:inneu/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InfoPage extends StatefulWidget {
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {

  String userName;
  String college;
  String userType;
  String gender;
  String userId;

  _reload() {
    setState(() {
      userName = PreloadData.userInfo["USER_NAME"]??"-";
      gender = PreloadData.userInfo["USER_SEX"]??"-";
      college = PreloadData.userInfo["UNIT_NAME"]??"-";
      userType = PreloadData.userInfo["ID_TYPE"]??"-";
      userId = PreloadData.userInfo["ID_NUMBER"]??"-";
    });
  }

  @override
  void dispose() {
    EventBus.removeListen("login", _reload);
    super.dispose();
  }

  @override
  void initState() {

    if (PreloadData.isLogin) {
      userName = PreloadData.userInfo["USER_NAME"]??"-";
      gender = PreloadData.userInfo["USER_SEX"]??"-";
      college = PreloadData.userInfo["UNIT_NAME"]??"-";
      userType = PreloadData.userInfo["ID_TYPE"]??"-";
      userId = PreloadData.userInfo["ID_NUMBER"]??"-";

      if (PreloadData.userInfo["USER_NAME"] == null) {
        (() async {
          var userInfo = await queryUserInfo();
          if (userInfo != null) {
            setState(() {
              PreloadData.userInfo = userInfo;
            });
          }
        })();
      }

    }

    super.initState();
    EventBus.addListener("login", _reload);

  }

  @override
  Widget build(BuildContext context) {

    List<MenuItem> functions = [];

    if (PreloadData.isLogin) {
      functions.add(MenuItem(
        icon: Icon(Icons.offline_bolt),
        name: "解除绑定",
        onTap: () {

          showDialog(
              context: context,
              builder: (BuildContext ctx) => CupertinoAlertDialog(
                content: Text("是否解绑您的一网通办账号？解除绑定后您将无法更新您的数据，但导入的课表、自定义编辑的考试将仍然保留"),
                actions: [
                  CupertinoDialogAction(
                    child: Text("确定"),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setBool("login_status", false);
                      PreloadData.isLogin = false;

                      PreloadData.indexComponents = ["news"];
                      await prefs.setStringList("index_components", null);
                      PreloadData.userInfo = {};
                      await prefs.setString("userInfo", null);
                      await prefs.setString("user_id", null);
                      await prefs.setString("enc_pwd", null);
                      EventBus.emitEvent("index_change");
                      EventBus.emitEvent("logout");
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
      ));
    } else {
      functions.add(MenuItem(
        icon: Icon(Icons.account_circle),
        name: "账号绑定",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage() )
          );
        }
      ));
    }

    functions.addAll([
      MenuItem(
          icon: Icon(Icons.feedback),
          name: "意见反馈",
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedBackPage() )
            );
          }
      ),
      MenuItem(
          icon: Icon(Icons.settings),
          name: "设置",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AppSetting() )
            );
          }
      ),
      MenuItem(
        icon: Icon(Icons.info_outline),
        name: "关于",
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AboutPage() )
          );
        }
      )
    ]);


    return SingleChildScrollView(
      child: Column(
        children: [
          PreloadData.isLogin ?
          Container(
            margin: EdgeInsets.all(ThemeRegular.cardMargin),
            decoration: BoxDecoration(
              color: ThemeRegular.cardBackgroundColor,
              borderRadius: ThemeRegular.cardRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(18, 20, 0, 20),
                    child: Center(
                      child: Image(
                        height: 65,
                        image: AssetImage(gender == "男"?"assets/images/info/boy.png" : "assets/images/info/girl.png"),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 80,
                    margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 0, 0, 2),
                          child: Text(userName, style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: ThemeRegular.themeTextColor
                          )),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 0, 0, 2),
                          child: Text("$userType #$userId", style: TextStyle(
                            color: ThemeRegular.textColor,
                            fontSize: 14
                          )),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 2, 0, 0),
                          child: Text(college, style: TextStyle(
                              color: ThemeRegular.textColor,
                              fontSize: 14
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ) :
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage() )
              );
            },
            child: Container(
              margin: EdgeInsets.all(ThemeRegular.cardMargin),
              decoration: BoxDecoration(
                color: ThemeRegular.cardBackgroundColor,
                borderRadius: ThemeRegular.cardRadius,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(18, 20, 0, 20),
                      child: Center(
                        child: Image(
                          height: 65,
                          image: AssetImage("assets/images/info/boy.png"),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 0, 0, 3),
                          child: Text("未绑定", style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: ThemeRegular.themeTextColor
                          )),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 0, 0, 2),
                          child: Text("绑定您的一网通办账号可以享受更多功能", style: TextStyle(
                              color: ThemeRegular.textColor,
                              fontSize: 14
                          )),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          MenuItems(
            data: functions,
          )
        ],
      ),
    );
  }
}