import 'package:flutter/material.dart';
import 'package:inneu/functions.dart';
import 'package:inneu/me.dart';
import 'package:inneu/theme.dart';
import 'event.dart';
import 'index.dart';


class MyHomePage extends StatefulWidget {

  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {

  int _currentSelectedIndex = 0;

  @override
  void initState() {
    super.initState();
    EventBus.addListener("logout", () {
      print("logout received");
      setState(() {
        _currentSelectedIndex = 0;
      });
    });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: ThemeRegular.backgroundColor,
      appBar: AppBar(
        title: Text("在东大"),
      ),
      body: IndexedStack(
        index: _currentSelectedIndex,
        children: <Widget>[
          Index(),
          Functions(),
          InfoPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.home),
            title: Text("首页"),
          ),
          BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Icon(Icons.functions),
              title: Text("百宝箱"),
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.account_circle),
            title: Text("我的"),
          ),
        ],
        currentIndex: _currentSelectedIndex,
        onTap: (int index) {
          this.setState(() {
            _currentSelectedIndex = index;
          });
        },
      ),
    );
  }
}