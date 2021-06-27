

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:inneu/components/iconTitle.dart';
import 'package:inneu/service/request.dart';
import 'package:inneu/theme.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

class LibraryInfo extends StatefulWidget {

  @override
  _LibraryInfoState createState() => _LibraryInfoState();

}

class _LibraryInfoState extends State<LibraryInfo> {

  Color textColor = Color.fromARGB(240, 90, 90, 90);
  Color lightColor = Color.fromARGB(230, 90, 90, 90);

  List<Map<String,String>> borrowList = [
  ];

  bool isLoading = true;
  bool isOpen = false;
  int tryTimes = 0;

  void loadData() async {
    var data = await queryLibraryBorrow();
    if (data == null) {
      await Future.delayed(Duration(milliseconds: 300));
      if (tryTimes < 5) {
        tryTimes++;
        loadData();
      }
    } else {
      List<Map<String,String>> res = [];
      List<dynamic> list = data["current"];
      list.forEach((element) {
        res.add(Map<String,String>.from(element));
      });
      setState(() {
        isLoading = false;
        borrowList = res;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(ThemeRegular.cardMargin),
      decoration: BoxDecoration(
        borderRadius: ThemeRegular.cardRadius,
        color: ThemeRegular.cardBackgroundColor
      ),
      child: Center(
        child: Column(
          children: <Widget>[
            IconTitle(
              icon: Icons.local_library,
              title: "图书借阅",
            ),
            isLoading?
            (Center(
              child: Container(
                margin: EdgeInsets.all(40),
                child: Loading(
                  indicator: BallPulseIndicator(),
                  size: 30,
                  color: lightColor,
                ),
              ),
            )) :
            (GestureDetector(
              onTap: (){
                setState(() {
                  isOpen = !isOpen;
                });
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 12, 0, 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: borrowList.length > 0 ? (<Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        Text("共", style: TextStyle(
                            fontSize: 20,
                            color: textColor
                        )),
                        Text("${borrowList.length}", style: TextStyle(
                            fontSize: 55,
                            color: textColor
                        )),
                        Text("本单册在借", style: TextStyle(
                            fontSize: 20,
                            color: textColor
                        ))
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.all(8),
                      child: Text("点击${isOpen?"收起":"展开"}详情", style: TextStyle(
                        color: lightColor
                      )),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.80,
                      margin: isOpen? EdgeInsets.all(8) : EdgeInsets.all(0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textBaseline: TextBaseline.alphabetic,
                        children: isOpen? borrowList.map((e) => Container(
                          margin: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            textBaseline: TextBaseline.alphabetic,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: 4,
                                    height: 16,
                                    margin: EdgeInsets.fromLTRB(3, 0, 7, 0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(2)),
                                      color: textColor
                                    ),
                                  ),
                                  Text(e["book_name"], style: TextStyle(
                                    fontSize: 15,
                                    color: lightColor,
                                    fontWeight: FontWeight.w500
                                  ))
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 7, 0, 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 0, 4, 0),
                                      child: Icon(Icons.account_box, size: 14, color: lightColor),
                                    ),
                                    Text("${e["author"]}|${e["branch_lib"]}", style: TextStyle(
                                      color: lightColor
                                    )),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 0, 4, 0),
                                      child: Icon(Icons.access_time, size: 14, color: lightColor),
                                    ),
                                    Text("到期时间 ${e["back_day"]}", style: TextStyle(
                                      color: lightColor
                                    ))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )).toList() : <Widget>[],
                      ),
                    ),
                  ]) : (<Widget>[
                    Container(
                      child: Icon(
                        Icons.local_library,
                        color: Color.fromARGB(255, 0, 129, 255),
                        size: 45,
                      ),
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 5),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 7, 0, 20),
                      child: Text("当前没有任何在借单册", style: TextStyle(
                          fontSize: 14,
                          color: lightColor
                      )),
                    ),
                  ]),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}