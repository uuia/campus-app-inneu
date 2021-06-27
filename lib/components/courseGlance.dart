import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inneu/components/iconTitle.dart';
import 'package:inneu/pages/schedule/schedulePage.dart';
import 'package:inneu/preloadData.dart';
import 'package:inneu/theme.dart';



class CourseGlance extends StatefulWidget {

  @override
  CourseGlanceState createState() => CourseGlanceState();

}

class CourseGlanceState extends State<CourseGlance> {

  int _week;
  int _day;
  bool _isToday = true;
  List<CourseItem> _items;

  @override
  void initState() {
    DateTime start = PreloadData.semesterStartMap[PreloadData.scheduleSemesterId];
    DateTime now = DateTime.now();
    _week = ((now.millisecondsSinceEpoch - start.millisecondsSinceEpoch)/(24*3600000*7)).ceil();
    _day = (((now.millisecondsSinceEpoch - start.millisecondsSinceEpoch)%(24*3600000*7))/(24*3600000)).floor();
    loadCourse();
    super.initState();
  }

  loadCourse() {
    _items = [];
    PreloadData.scheduleCourses.forEach((element) {
      if (element.weeks.contains(_week) && element.day==_day) {
        _items.add(element);
      }
    });
    // 按照开始节次排序
    _items.sort((a,b) => a.section.compareTo(b.section));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SchedulePage())
        );
      },
      child: Container(
        margin: EdgeInsets.all(ThemeRegular.cardMargin),
        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
        decoration: BoxDecoration(
          borderRadius: ThemeRegular.cardRadius,
          color: ThemeRegular.cardBackgroundColor,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconTitle(
                  icon: Icons.list,
                  title: "课程速览",
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_isToday) {
                        _week = _day == 6 ? _week+1 : _week;
                        _day = (_day+1)%7;
                      } else {
                        _week = _day == 0 ? _week-1 : _week;
                        _day = _day == 0 ? 6 : (_day - 1);
                      }
                      _isToday = !_isToday;
                      loadCourse();
                      print("week: $_week ,day: $_day");
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 12, 0),
                    child: Text("点击切换为${_isToday?"明日":"今日"}课程", style: TextStyle(
                        color: Color.fromARGB(240, 90, 90, 90),
                        decoration: TextDecoration.underline
                    )),
                  ),
                )
              ],
            )
          ]..addAll(_items.length == 0? [Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 15),
            child: Center(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(8),
                    child: Icon(Icons.reorder, color: ThemeRegular.themeTextColor, size: 40,),
                  ),
                  Container(
                    margin: EdgeInsets.all(0),
                    child: Text("${_isToday?"今":"明"}日暂无课程"),
                  )
                ],
              ),
            ),
          )] : _items.map((e) => Container(
            margin: EdgeInsets.fromLTRB(20, 13, 20, 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(e.courseName, style: TextStyle(
                        fontSize: 17,
                        color: ThemeRegular.themeTextColor,
                        fontWeight: FontWeight.w500,
                      )),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("${e.section+1}${e.len==1?"":"~"+(e.section+e.len).toString()}节", style: TextStyle(
                              fontSize: 17,
                              color: ThemeRegular.lightColor,
                              fontWeight: FontWeight.w300
                          ))
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${e.courseCode} ${e.teachers.join(",")}", style: TextStyle(
                        fontSize: 12,
                        color: ThemeRegular.textColor
                    )),
                    Text("教室：${e.classroom == null || e.classroom == ""? "未安排": e.classroom}", style: TextStyle(
                        fontSize: 12,
                        color: ThemeRegular.textColor
                    ))
                  ],
                )
              ],
            ),
          )).toList()),
        ),
      ),
    );
  }
}