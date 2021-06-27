import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inneu/event.dart';
import 'package:inneu/service/request.dart';
import 'package:inneu/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../preloadData.dart';

class _LoginButton extends StatefulWidget {
  final Function(BuildContext context) onLogin;

  _LoginButton({this.onLogin});

  _LoginButtonState createState() => _LoginButtonState();

}

class _LoginButtonState extends State<_LoginButton> {

  bool _agreePrivacyAgreement = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(2, 0, 2, 0),
              child: Checkbox(
                value: _agreePrivacyAgreement,
                onChanged: (v) {
                  setState(() {
                    _agreePrivacyAgreement = v;
                  });
                },
              ),
            ),
            Text("我已阅读并同意", style: TextStyle(fontSize: 12),),
            GestureDetector(
              onTap: () {
                PreloadData.method.invokeMethod("open", json.encode({
                  "url": "https://img-pool.zxysy.net/privacy-agreement.html",
                  "title": "隐私协定"
                }));
              },
              child: Text("《在东大隐私协议》", style: TextStyle(fontSize: 12, decoration: TextDecoration.underline),),
            )
          ],
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 8, 0, 4),
          child: SizedBox(
            height: 30,
            width: 100,
            child: RaisedButton(
              color: ThemeRegular.mainColor,
              disabledColor: ThemeRegular.backgroundColor,
              textColor: ThemeRegular.backgroundColor,
              onPressed: _agreePrivacyAgreement ? () => widget.onLogin(context) : null,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25))
              ),
              child: Text("确定"),
            ),
          ),
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class LoginPage extends StatelessWidget {

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _userId;
  String _password;

  final Function(BuildContext context) target;
  LoginPage({this.target});

  _login(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print("ok");
      FocusScope.of(context).requestFocus(FocusNode());

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

      var loginRes = await loginService(_userId, _password);
      if (loginRes == true) {

        var userInfo = await queryUserInfo();
        if (userInfo != null) {
          PreloadData.userInfo = userInfo;
        }

        if (_userId.length == 8) {
          PreloadData.indexComponents = ["schedule","card"];
          SharedPreferences preferences = await SharedPreferences.getInstance();
          preferences.setStringList("index_components", ["schedule","card"]);
          await PreloadData.loadSchedule(null);
        } else if (_userId.length == 7) {
          PreloadData.indexComponents = ["card", "library"];
          SharedPreferences preferences = await SharedPreferences.getInstance();
          preferences.setStringList("index_components", ["card","library"]);
        }


        EventBus.emitEvent("index_change");
        EventBus.emitEvent("login");
        Navigator.of(context, rootNavigator: true).pop();

        if (target != null) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: target)
          );
        } else {
          Navigator.pop(context);
        }

      } else {
        Navigator.of(context, rootNavigator: true).pop();
        Fluttertoast.showToast(
          msg: "密码错误",
          backgroundColor: ThemeRegular.backgroundColor,
          textColor: ThemeRegular.themeTextColor,
        );
      }


    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeRegular.backgroundColor,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Image(
                image: AssetImage("assets/images/neu.png"),
                fit: BoxFit.fitWidth,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
          Positioned(
            left: 15,
            top: 30,
            child: SizedBox(
              height: 50,
              width: 50,
              child: RaisedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25))
                ),
                child: Container(
                    child: Icon(Icons.arrow_back_ios, size: 18,)
                ),
              ),
            )
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width*0.75,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromARGB(245, 255, 255, 255),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 5, 5),
                        child: Icon(Icons.link, size: 20,),
                      ),
                      Text("绑定您的一网通办", style: TextStyle(
                        fontSize: 20
                      )),
                      Container(width: 5)
                    ],
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 5, 5, 8),
                          child: TextFormField(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              border: OutlineInputBorder(),
                              hintText: "学号",
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (s) {_userId = s;},
                            onSaved: (s) {_userId = s;},
                            validator: (s){
                              if (RegExp("^\\d{4,9}\$").hasMatch(s)) {
                                print("match");
                                return null;
                              } else {
                                return "学号格式错误";
                              }
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 3, 5, 5),
                          child: TextFormField(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              border: OutlineInputBorder(),
                              hintText: "密码",
                            ),
                            obscureText: true,
                            onChanged: (s) {_password = s;},
                            onSaved: (s) {_password = s;},
                            validator: (s){
                              if (RegExp("^\\S{5,20}\$").hasMatch(s)) {
                                return null;
                              } else {
                                return "密码格式错误";
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  _LoginButton(onLogin: _login,)
//                  Container(
//                    margin: EdgeInsets.fromLTRB(0, 8, 0, 4),
//                    child: SizedBox(
//                      height: 30,
//                      width: 100,
//                      child: RaisedButton(
//                        color: ThemeRegular.mainColor,
//                        textColor: ThemeRegular.backgroundColor,
//                        onPressed: () => _login(context),
//                        elevation: 0,
//                        shape: RoundedRectangleBorder(
//                            borderRadius: BorderRadius.all(Radius.circular(25))
//                        ),
//                        child: Text("确定"),
//                      ),
//                    ),
//                  ),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}