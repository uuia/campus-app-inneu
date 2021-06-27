
import 'package:flutter/material.dart';
import 'package:inneu/home.dart';
import 'package:inneu/preloadData.dart';
import 'package:inneu/theme.dart';


class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _preload();
  }

  void _preload() async {
    await PreloadData.loadData();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(15),
              child: PhysicalModel(
                color: Colors.transparent,
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: Image(
                  image: AssetImage("assets/images/logo.png"),
                  width: MediaQuery.of(context).size.width*0.7,
                  height: MediaQuery.of(context).size.width*0.7,
                ),
              )
            ),
            Text("在东大", style: TextStyle(
                fontSize: 25,
                color: ThemeRegular.textColor,
                fontFamily: "MaShanZheng"
            ))
          ],
        ),
      ),
    );
  }
}