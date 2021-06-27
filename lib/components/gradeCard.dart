
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:inneu/components/iconTitle.dart';
import 'package:inneu/preloadData.dart';
import 'package:inneu/theme.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

import 'package:inneu/service/request.dart';
import 'package:inneu/service/state.dart';

import 'gradeList.dart';

class GradeCard extends StatefulWidget {

  @override
  _GradeCardState createState() => _GradeCardState();

}


class _InfoColumn extends StatelessWidget {

  final String title;
  final String data;

  _InfoColumn({this.title, this.data});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Container(
        margin: EdgeInsets.fromLTRB(4, 2, 4, 2),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(2),
              child: Text(title, style: TextStyle(
                fontWeight: FontWeight.w700
              )),
            ),
            Container(
              margin: EdgeInsets.all(2),
              child: Text(data, style: TextStyle(
                color: Color.fromARGB(230, 90, 90, 90),
                fontSize: 14
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradeCardState extends State<GradeCard> {

  String gpa = "-";
  String publishGradeNum = "-";
  String semesterGradePoint = "-";
  List<Map<String,dynamic>> gradeData = [] ;
  bool isLoading = false;
  bool isOpen = false;

  Color textColor = Color.fromARGB(240, 90, 90, 90);
  Color lightColor = Color.fromARGB(230, 90, 90, 90);
  Color blue = Color.fromARGB(255, 0, 129, 255);

  int tryTimes = 0;

  loadData() async {
    var res = await queryGrade(PreloadData.gradeSemesterId);

    if (res == null) {
      if (tryTimes < 5) {
        tryTimes++;
        await Future.delayed(Duration(milliseconds: 300));
        loadData();
      }
    } else {

      List<dynamic> courses = res["courses"];
      double creditSum = 0;
      double gradePointSum = 0;
      courses.forEach((element) {
        Map<String,dynamic> courseData = element;
        gradePointSum += double.parse(courseData["grade_point"]) * double.parse(courseData["credit"]);
        creditSum += double.parse(courseData["credit"]);
      });

      List<Map<String,dynamic>> _gradeData = [];
      List<dynamic> arr = res["courses"];

      arr.forEach((element) {
        _gradeData.add(Map<String,dynamic>.from(element));
      });

      setState(() {
        gpa = res["gpa"];
        publishGradeNum = courses.length.toString();
        semesterGradePoint = (gradePointSum/creditSum).toStringAsFixed(4);
        gradeData =  _gradeData;
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
      child: Column(
        children: <Widget>[
          IconTitle(
            icon: Icons.grade,
            title: "学期成绩",
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isOpen = !isOpen;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _InfoColumn(
                    title: "GPA",
                    data: gpa,
                  ),
                  _InfoColumn(
                    title: "已出科目",
                    data: publishGradeNum,
                  ),
                  _InfoColumn(
                    title: "学期绩点",
                    data: semesterGradePoint,
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                        margin: EdgeInsets.fromLTRB(4, 2, 4, 2),
                        child: Center(
                          child: isLoading?
                          (Container(
                            margin: EdgeInsets.all(2),
                            child: Loading(
                              size: 14,
                              indicator: BallPulseIndicator(),
                              color: lightColor,
                            ),
                          ))
                              :
                          (Row(
                            children: <Widget>[
                              Text(isOpen?"收起":"展开", style: TextStyle(
                                  color: blue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14
                              )),
                              Container(
                                margin: EdgeInsets.fromLTRB(5, 2, 2, 2),
                                child: Transform.rotate(
                                  angle: isOpen ? pi/2 : 0,
                                  child: Icon(Icons.keyboard_arrow_right, size: 14),
                                ),
                              )
                            ],
                          )),
                        )
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(9, isOpen? 10 : 0, 9, 17),
            child: isOpen ? GradeList(data: gradeData, width: MediaQuery.of(context).size.width) : null,
          ),
        ],
      ),
    );
  }
}