
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inneu/pages/schedule/courseListPage.dart';
import 'package:inneu/preloadData.dart';
import 'package:inneu/service/request.dart';
import 'package:inneu/theme.dart';
import 'package:loading/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseItem {

  String courseName;
  String courseCode;
  List<String> teachers;
  String classroom;
  List<int> weeks;
  int day;
  int len;
  int section;

  CourseItem({
    this.courseName,
    this.courseCode,
    this.teachers,
    this.classroom,
    this.weeks,
    this.day,
    this.len,
    this.section
  });

}

class _ScheduleBody extends StatelessWidget {

  final List<CourseItem> courses;
  final int week;
  final int semester = PreloadData.scheduleSemesterId;
  final List<List<CourseItem>> currentWeekCourses = [
    [],[],[],[],[],[],[]
  ];
  final double courseItemHeight = 53;
  final double screenWidth;

  _ScheduleBody({this.courses, this.week, this.screenWidth}) {
    courses.forEach((element) {
      if (element.weeks.contains(week)) {
        currentWeekCourses[element.day].add(element);
      }
    });
  }


  bool courseEqual(List<CourseItem> list1, List<CourseItem> list2) {


    if (list1.length != list2.length) {
      return false;
    }

    list1.sort((item1,item2) => item1.courseName.compareTo(item1.courseName));
    list2.sort((item1,item2) => item1.courseName.compareTo(item1.courseName));


    for(int index = 0;index < list1.length; index++) {
      if (
        list1[index].courseName != list2[index].courseName ||
        list1[index].courseCode != list2[index].courseCode ||
        list1[index].classroom != list2[index].classroom ||
        list1[index].teachers != list2[index].teachers
      ) {
        return false;
      }
    }

    return true;

  }

  _getDayCourses(int day, BuildContext context) {

    List<CourseItem> todayCourses = currentWeekCourses[day];
    todayCourses.sort((a,b) => a.section.compareTo(b.section));
    List<List<CourseItem>> tempList = [[],[],[],[],[],[],[],[],[],[],[],[]];
    List<List<CourseItem>> widgetList = [];

    todayCourses.forEach((element) {
      for(int sectionIndex = 0; sectionIndex < element.len; sectionIndex++) {
        tempList[sectionIndex+element.section].add(CourseItem(
          classroom: element.classroom,
          courseCode: element.courseCode,
          courseName: element.courseName,
          teachers: element.teachers,
          weeks: element.weeks,
          day: element.day,
          len: 1,
          section: element.section+sectionIndex
        ));
      }
    });

    List<CourseItem> upItem;
    for(int sectionIndex = 0; sectionIndex < tempList.length; sectionIndex++) {
      if (tempList[sectionIndex].length == 0) {
        continue;
      }
      if (upItem == null) {
        widgetList.add(tempList[sectionIndex]);
      } else {
        if (courseEqual(upItem, tempList[sectionIndex])) {
          widgetList[widgetList.length-1].forEach((element) {
            element.len++;
          });
        } else {
          widgetList.add(tempList[sectionIndex]);
        }
      }
      upItem = tempList[sectionIndex];
    }

    List<Widget> widgets = widgetList.map((e) => Positioned(
      left: 0,
      top: e[0].section*courseItemHeight,
      height: courseItemHeight * e[0].len,
      width: screenWidth/15*2,
      child: GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("课程详情"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("确定"),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),
                ],
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: e.map((courseItem) => Container(
                    child: Column(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(courseItem.courseName, style: TextStyle(
                              fontSize: 14,
                            )),
                            Text(courseItem.courseCode, style: TextStyle(
                                color: ThemeRegular.lightColor,
                                fontSize: 10
                            ))
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(6, 12, 6, 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Text("任课教师", style: TextStyle(
                                  fontSize: 12,
                                  color: ThemeRegular.textColor,
                                )),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(courseItem.teachers.join(",") == "" ? "未安排" : courseItem.teachers.join(","), style: TextStyle(
                                    fontSize: 12,
                                    color: ThemeRegular.themeTextColor
                                )),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(6, 6, 6, 1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Text("上课地点", style: TextStyle(
                                  fontSize: 12,
                                  color: ThemeRegular.textColor,
                                )),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(courseItem.classroom == null || courseItem.classroom == ""? "未安排":courseItem.classroom, style: TextStyle(
                                    fontSize: 12,
                                    color: ThemeRegular.themeTextColor
                                )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              )
          );
        },
        child: Container(
          padding: EdgeInsets.all(4),
          child: Container(
            decoration: BoxDecoration(
                color: e.length == 1 ? Colors.blue : Colors.red,
                borderRadius: BorderRadius.all(Radius.circular(3)),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(1.5, .5),
                    blurRadius: 3,
                    spreadRadius: 0.8,
                    color: Color.fromARGB(200, 150, 150, 150),
                  )
                ]
            ),
            child: e.length == 1 ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Text(e[0].courseName, textAlign: TextAlign.center, style: TextStyle(
                    fontSize: 11,
                  )),
                ),
                Expanded(
                  flex: 5,
                  child: Text(e[0].classroom, textAlign: TextAlign.center, style: TextStyle(
                      fontSize: 11
                  )),
                ),
              ],
            ) : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("${e[0].courseName}等${e.length}门课程", textAlign: TextAlign.center, style: TextStyle(
                  fontSize: 11,
                ))
              ],
            ),
          ),
        ),
      ),
    )).toList();

    return Stack(
      children: widgets,
    );

  }

  dateText(int day) {
    DateTime start = PreloadData.semesterStartMap[semester];
    DateTime current = DateTime.fromMillisecondsSinceEpoch(
      start.millisecondsSinceEpoch + ((week-1)*7+day)*24*3600000
    );
    DateTime today = DateTime.now();
    bool isToday = today.year == current.year && today.month == current.month && today.day == current.day;

    return Column(
      children: <Widget>[
        Text("周${["日", "一", "二", "三", "四", "五", "六"][day]}", style: TextStyle(
          color: isToday ? ThemeRegular.themeTextColor : ThemeRegular.textColor,
        )),
        Text("${current.month}-${current.day}", style: TextStyle(
          color: isToday ? ThemeRegular.themeTextColor : ThemeRegular.textColor,
        )),
      ],
    );

  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Text(""),
            ),
            Expanded(
              flex: 2,
              child: Container(
                margin: EdgeInsets.all(5),
                child: dateText(0),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                margin: EdgeInsets.all(5),
                child: dateText(1),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                margin: EdgeInsets.all(5),
                child: dateText(2),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                margin: EdgeInsets.all(5),
                child: dateText(3),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                margin: EdgeInsets.all(5),
                child: dateText(4),
              ),
            ),
            Expanded(
              flex: 2,
              child: dateText(5),
            ),
            Expanded(
              flex: 2,
              child: Container(
                margin: EdgeInsets.all(5),
                child: dateText(6),
              ),
            ),
          ],
        ),
        Container(
          height: 12*courseItemHeight,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [1,2,3,4,5,6,7,8,9,10,11,12].map((e) => Container(
                    padding: EdgeInsets.all(5),
                    height: courseItemHeight,
                    child: Text(e.toString()),
                  )).toList(),
                ),
              ),
              Expanded(
                flex: 2,
                child: _getDayCourses(0, context),
              ),
              Expanded(
                flex: 2,
                child: _getDayCourses(1, context),
              ),
              Expanded(
                flex: 2,
                child: _getDayCourses(2, context),
              ),
              Expanded(
                flex: 2,
                child: _getDayCourses(3, context),
              ),
              Expanded(
                flex: 2,
                child: _getDayCourses(4, context),
              ),
              Expanded(
                flex: 2,
                child: _getDayCourses(5, context),
              ),
              Expanded(
                flex: 2,
                child: _getDayCourses(6, context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SchedulePage extends StatefulWidget {
  
  @override
  _SchedulePageState createState() => _SchedulePageState();

}

class _SchedulePageState extends State<SchedulePage> {

  int currentWeek;
  int maxWeek;
  
  _calculateWeekTime(int weekIndex) {
    DateTime semesterStartTime = PreloadData.semesterStartMap[PreloadData.scheduleSemesterId];
    DateTime startTime = DateTime.fromMillisecondsSinceEpoch(semesterStartTime.millisecondsSinceEpoch + (weekIndex-1)*7*24*3600000);
    DateTime endTime = DateTime.fromMillisecondsSinceEpoch(startTime.millisecondsSinceEpoch + 6*24*3600000);
    return "${startTime.month}月${startTime.day}日-${endTime.month}月${endTime.day}日";
  }

  showWeekPicker() {
    Picker(
      adapter: PickerDataAdapter(
        data: List.generate(maxWeek, (index) => index+1).map((e) => PickerItem(
          text: Text("第$e周(${_calculateWeekTime(e)})")
        )).toList(),
      ),
        cancelText: "取消",
        confirmText: "确认",
        onConfirm: (Picker picker,List value) {
          setState(() {
            currentWeek = value[0] + 1;
          });
        }
    ).showModal(context);
  }

  reloadData() async {

    int tryTimes = 0;
    List<CourseItem> courses;
    try {
      while(tryTimes < 5) {
        courses = await querySchedule(PreloadData.scheduleSemesterId);
        if (courses != null) {
          print(courses);
          break;
        }
        await Future.delayed(Duration(milliseconds: 200));
      }
      if (courses == null) {
        throw Exception("course null");
      }

      setState(() {
        PreloadData.scheduleCourses = [];
        courses.forEach((element) {
          PreloadData.scheduleCourses.add(element);
          PreloadData.saveSchedule(null);
        });
      });

    } catch (e,stack) {
      Fluttertoast.showToast(msg: "获取课表错误");
      print(e);
      print(stack);
      courses = [];
    }
    
  }


  @override
  void initState() {
    DateTime start = PreloadData.semesterStartMap[PreloadData.scheduleSemesterId];
    print("current schedule id:" + PreloadData.scheduleSemesterId.toString());
    DateTime now = DateTime.now();
    currentWeek = ((now.millisecondsSinceEpoch - start.millisecondsSinceEpoch)/(24*3600000*7)).ceil();
    maxWeek = PreloadData.maxWeekMap[PreloadData.scheduleSemesterId];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> actions = PreloadData.isLogin ? [
      IconButton(
        icon: Icon(Icons.refresh),
        iconSize: 26,
        onPressed: () {

          showDialog(
            context: context,
            child: AlertDialog(
              title: Text("确定刷新？",style: TextStyle(
                  fontSize: 16
              )),
              content: Text("如果刷新，您编辑和修改的课程将被清除", style: TextStyle(
                  fontSize: 14
              )),
              actions: <Widget>[
                FlatButton(
                  child: new Text('取消'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: new Text('确定'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    // 展示加载
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
                    await reloadData();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                )
              ],
            ),
          );
        },
      ),
    ] : [];

    actions.add(IconButton(
      icon: Icon(Icons.edit),
      iconSize: 26,
      onPressed: () {
        Navigator
          .push(context, MaterialPageRoute(builder: (context) => CourseListPage()))
          .then((value) => setState(() {}));
      },
    ),);

    return Scaffold(
      appBar: AppBar(
        title: Text("课程表"),
        actions: actions,
        bottom: PreferredSize(
          child: Container(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: IconButton(
                    icon: Icon(Icons.keyboard_arrow_left),
                    onPressed: currentWeek == 1 ? null : () {
                      setState(() {
                        currentWeek--;
                      });
                      print(currentWeek);
                    },
                  ),
                  margin: EdgeInsets.all(9),
                ),
                InkWell(
                  onTap: showWeekPicker,
                  child: Container(
                    child: Text("第$currentWeek周", style: TextStyle(
                        fontSize: 17
                    )),
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.all(4),
                  ),
                ),
                Container(
                  child: IconButton(
                    icon: Icon(Icons.keyboard_arrow_right),
                    onPressed: currentWeek==maxWeek? null : () {
                      setState(() {
                        currentWeek++;
                      });
                    },
                  ),
                  margin: EdgeInsets.all(9),
                ),
              ],
            ),
          ),
          preferredSize: Size.fromHeight(60),
        ),
      ),
      backgroundColor: ThemeRegular.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/neu.png"),
            fit: BoxFit.fitWidth
          )
        ),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: <Widget>[
              _ScheduleBody(
                week: currentWeek,
                screenWidth: MediaQuery.of(context).size.width,
                courses: PreloadData.scheduleCourses,
              ),
            ],
          ),
        ),
      )
    );
  }
}