import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inneu/pages/schedule/schedulePage.dart';
import 'package:inneu/preloadData.dart';
import 'package:inneu/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';


String _parseWeek(List<int> weeks) {
  String res = "";
  int start = -1;
  int up = -2;
  bool isStart = true;
  for (int index=0;index < weeks.length; index++) {
    if (up + 1 != weeks[index]) {
      if (isStart) {
        start = weeks[index];
        isStart = false;
      } else {
        if (up == start) {
          res += (res == "")?up.toString():",$up";
        } else {
          res += (res == "")?"$start~$up":",$start~$up";
        }
        start = weeks[index];
      }
    }
    if (index+1 == weeks.length) {
      if (weeks[index] == start) {
        res += (res == "")?weeks[index].toString():",${weeks[index]}";
      } else {
        res += (res == "")?"$start~${weeks[index]}":",$start~${weeks[index]}";
      }
    }
    up = weeks[index];
  }
  return res;
}


class _WeekSelectItem extends StatefulWidget {

  final bool initValue;
  final Function(bool) onChange;
  final Widget tag;

  _WeekSelectItem({this.initValue,this.onChange,this.tag});

  @override
  _WeekSelectItemState createState() => _WeekSelectItemState();

}

class _WeekSelectItemState extends State<_WeekSelectItem> {

  bool isSelect;

  @override
  void initState() {
    isSelect = widget.initValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: EdgeInsets.fromLTRB(4, 3, 4, 3),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(2),
            child: Checkbox(
              value: isSelect,
              onChanged: (value) {
                setState(() {
                  isSelect = value;
                  widget.onChange(value);
                });
              },
            ),
          ),
          widget.tag
        ],
      ),
    );
  }
}

class _CourseTimeSelector extends StatefulWidget {

  final int day;
  final int section;
  final int len;
  final Function(int,int,int) onSet;

  _CourseTimeSelector({this.day,this.section,this.len,this.onSet});

  @override
  _CourseTimeSelectorState createState() => _CourseTimeSelectorState();
}

class _CourseTimeSelectorState extends State<_CourseTimeSelector> {

  int _day;
  int _section;
  int _len;

  @override
  void initState() {
    _day = widget.day;
    _section = widget.section;
    _len = widget.len;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () {
          Picker(
            confirmText: "确认",
            cancelText: "取消",
            adapter: PickerDataAdapter(
              data: ["日","一","二"," 三","四","五","六"].map((day) => PickerItem(
                text: Text("星期$day"),
                children: List.generate(12, (start) => PickerItem(
                  text: Text("${start+1}节"),
                  children: List.generate(12-start, (end) => PickerItem(
                    text: Text("${start+end+1}节")
                  ))
                )),
              )).toList()
            ),
            onConfirm: (Picker picker,List value) {
              setState(() {
                _day = value[0];
                _section = value[1];
                _len = value[2]+1;
              });
              widget.onSet(_day,_section,_len);
            }
          ).showModal(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("上课时间"),
            Container(
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                color: ThemeRegular.backgroundColor,
              ),
              padding: EdgeInsets.fromLTRB(10, 4, 10, 6),
              child: Text(_day==null || _section==null || _len==null? "未安排" : "星期${["日","一","二"," 三","四","五","六"][_day]} 第${_section+1}节${_len>1?"~第${_section+_len}节":""}", style: TextStyle(
                  color: ThemeRegular.themeTextColor,
                  fontSize: 14
              )),
            ),
          ],
        ),
      ),
    );
  }
}


class _WeekPickerModal extends StatefulWidget {

  final List<int> weekList;
  final int max;
  final Function(List<int>) onConfirm;

  _WeekPickerModal({this.onConfirm, this.max, this.weekList});

  @override
  _WeekPickerModalState createState() => _WeekPickerModalState();

}

class _WeekPickerModalState extends State<_WeekPickerModal> {

  List<int> _weekList;

  @override
  void initState() {
    _weekList = widget.weekList.map((e) => e).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () {
          List tempWeeks = _weekList.map((e) => e).toList();
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("取消"),
                      ),
                      FlatButton(
                        onPressed: () {
                          setState(() {
                            _weekList = tempWeeks;
                          });
                          widget.onConfirm(_weekList);
                          Navigator.pop(context);
                        },
                        child: Text("确定"),
                      )
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Wrap(
                      spacing: 5,
                      runSpacing: 0,
                      children: List.generate(widget.max, (index) => _WeekSelectItem(
                        initValue: tempWeeks.contains(index+1),
                        onChange: (value) {
                          if (value && !tempWeeks.contains(index+1)) {
                            tempWeeks.add(index+1);
                            tempWeeks.sort();
                          } else if (!value) {
                            tempWeeks.remove(index+1);
                          }
                        },
                        tag: Text("${index+1}周"),
                      )),
                    ),
                  ),
                ],
              ),
            )
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("上课周"),
            Container(
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                color: ThemeRegular.backgroundColor,
              ),
              padding: EdgeInsets.fromLTRB(10, 6, 10, 4),
              child: Text( _weekList.length > 0 ? _parseWeek(_weekList) : "未安排", style: TextStyle(
                color: ThemeRegular.themeTextColor,
                fontSize: 14
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseItemWidget extends StatelessWidget {
  
  final CourseItem item;
  final int itemIndex;
  final Function(int) deleteFunc;
  final Future Function(int,CourseItem) changeFunc;
  
  _CourseItemWidget({this.item, this.itemIndex, this.deleteFunc, this.changeFunc});

  showEditDialog(BuildContext context) {
    int courseDay = PreloadData.scheduleCourses[itemIndex].day;
    int courseSection = PreloadData.scheduleCourses[itemIndex].section;
    int courseLen = PreloadData.scheduleCourses[itemIndex].len;

    TextEditingController teacherController = TextEditingController();
    teacherController.text = PreloadData.scheduleCourses[itemIndex].teachers.join(",");

    TextEditingController classroomController = TextEditingController();
    classroomController.text = PreloadData.scheduleCourses[itemIndex].classroom;

    List<int> tempWeeks = PreloadData.scheduleCourses[itemIndex].weeks;

    showDialog(
        context: context,
        child: AlertDialog(
          title: Column(
            children: <Widget>[
              Text(PreloadData.scheduleCourses[itemIndex].courseName),
              Text(PreloadData.scheduleCourses[itemIndex].courseCode, style: TextStyle(
                fontSize: 12,
                color: ThemeRegular.textColor,
              )),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(4, 10, 4, 10),
                  child: TextField(
                    controller: classroomController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      border: OutlineInputBorder(),
                      labelText: "上课教室",
                      hintText: "上课教室",
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(4, 10, 4, 10),
                  child: TextField(
                    controller: teacherController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      border: OutlineInputBorder(),
                      labelText: "授课老师",
                      hintText: "授课老师",
                    ),
                  ),
                ),
                _CourseTimeSelector(
                  day: PreloadData.scheduleCourses[itemIndex].day,
                  len: PreloadData.scheduleCourses[itemIndex].len,
                  section: PreloadData.scheduleCourses[itemIndex].section,
                  onSet: (newDay,newSection,newLen) {
                    courseDay = newDay;
                    courseLen = newLen;
                    courseSection = newSection;
                  },
                ),
                _WeekPickerModal(
                  weekList: PreloadData.scheduleCourses[itemIndex].weeks,
                  max: PreloadData.maxWeekMap[PreloadData.scheduleSemesterId],
                  onConfirm: (data) {
                    tempWeeks = data;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: new Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: new Text('修改'),
              onPressed: () async {

                await changeFunc(itemIndex, CourseItem(
                  courseName: PreloadData.scheduleCourses[itemIndex].courseName,
                  courseCode: PreloadData.scheduleCourses[itemIndex].courseCode,
                  teachers: teacherController.text.split(","),
                  classroom: classroomController.text,
                  section: courseSection,
                  len: courseLen,
                  day: courseDay,
                  weeks: tempWeeks,
                ));

                Navigator.of(context).pop();
              },
            ),
          ],
        )
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(ThemeRegular.cardMargin),
      padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
      decoration: BoxDecoration(
        color: ThemeRegular.cardBackgroundColor,
        borderRadius: ThemeRegular.cardRadius,
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                child: Text(item.courseName, style: TextStyle(
                  fontSize: 16,
                )),
              )
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                child: Text(item.courseCode, style: TextStyle(
                  fontSize: 12,
                  color: ThemeRegular.lightColor,
                )),
              )
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 3),
                child: Text("任课教师", style: TextStyle(
                  fontSize: 15,
                  color: ThemeRegular.textColor,
                )),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 3),
                child: Text(item.teachers.join(",")=="" ? "未安排" : item.teachers.join(","), style: TextStyle(
                  fontSize: 15,
                  color: ThemeRegular.themeTextColor,
                )),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
                child: Text("上课周", style: TextStyle(
                  fontSize: 15,
                  color: ThemeRegular.textColor,
                )),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
                child: Text(_parseWeek(item.weeks)+"周", style: TextStyle(
                  fontSize: 15,
                  color: ThemeRegular.themeTextColor,
                )),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
                child: Text("上课时间", style: TextStyle(
                  fontSize: 15,
                  color: ThemeRegular.textColor,
                )),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
                child: Text("星期${["日","一","二","三","四","五","六"][item.day]} 第${item.section+1}${item.len>1? "~${item.section+item.len}":""}节", style: TextStyle(
                  fontSize: 15,
                  color: ThemeRegular.themeTextColor,
                )),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
                child: Text("上课教室", style: TextStyle(
                  fontSize: 15,
                  color: ThemeRegular.textColor,
                )),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
                child: Text(item.classroom=="" || item.classroom==null? "未安排" : item.classroom, style: TextStyle(
                  fontSize: 15,
                  color: ThemeRegular.themeTextColor,
                )),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 8, 0),
                child: SizedBox(
                  height: 26,
                  width: 60,
                  child: RaisedButton(
                    child: Center(
                      child: Text("编辑", style: TextStyle(
                          fontSize: 12
                      )),
                    ),
                    onPressed: () {
                      showEditDialog(context);
                    },
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(13))
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: SizedBox(
                  height: 26,
                  width: 60,
                  child: RaisedButton(
                    color: Color.fromARGB(160, 255, 0, 0),
                    child: Center(
                      child: Text("删除", style: TextStyle(
                          fontSize: 12
                      )),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        child: AlertDialog(
                          title: Text("确认删除？"),
                          content: Text("该操作不可撤销"),
                          actions: <Widget>[
                            FlatButton(
                              child: new Text('取消'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            FlatButton(
                              child: new Text('确定'),
                              onPressed: () {
                                deleteFunc(itemIndex);
                              },
                            )
                          ],
                        )
                      );
                    },
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(13))
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class CourseListPage extends StatefulWidget {

  @override
  _CourseListPageState createState() => _CourseListPageState();

}

class _CourseListPageState extends State<CourseListPage> {

  showAddDialog() {

    TextEditingController courseNameController = TextEditingController();
    courseNameController.text = "";
    TextEditingController courseCodeController = TextEditingController();
    courseCodeController.text = "";
    TextEditingController teacherController = TextEditingController();
    teacherController.text = "";
    TextEditingController classroomController = TextEditingController();
    classroomController.text = "";
    List<int> courseWeeks = [];
    int courseDay,courseSection,courseLen;
    
    showDialog(
      context: context,
      child: AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("新建课程"),
              Container(
                margin: EdgeInsets.fromLTRB(4, 10, 4, 10),
                child: TextField(
                  controller: courseNameController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                    labelText: "课程名称",
                    hintText: "课程名称",
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(4, 10, 4, 10),
                child: TextField(
                  controller: courseCodeController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                    labelText: "课程代码",
                    hintText: "课程代码",
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(4, 10, 4, 10),
                child: TextField(
                  controller: teacherController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                    labelText: "任课教师",
                    hintText: "任课教师",
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(4, 10, 4, 10),
                child: TextField(
                  controller: classroomController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                    labelText: "上课教室",
                    hintText: "上课教室",
                  ),
                ),
              ),
              _WeekPickerModal(
                weekList: [],
                max: PreloadData.maxWeekMap[PreloadData.scheduleSemesterId],
                onConfirm: (res) {
                  courseWeeks = res;
                },
              ),
              _CourseTimeSelector(
                onSet: (_day,_section,_len) {
                  courseDay = _day;
                  courseSection = _section;
                  courseLen = _len;
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: new Text('取消'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: new Text('添加'),
            onPressed: () {

              if (courseNameController.text == "") {
                Fluttertoast.showToast(
                    msg: "请输入课程名",
                    backgroundColor: ThemeRegular.backgroundColor,
                    textColor: ThemeRegular.textColor
                );
                return;
              }

              if (courseWeeks.length == 0) {
                Fluttertoast.showToast(
                    msg: "上课周数未设定",
                    backgroundColor: ThemeRegular.backgroundColor,
                    textColor: ThemeRegular.textColor
                );
                return;
              }

              if (courseDay == null || courseSection == null || courseLen == null) {
                Fluttertoast.showToast(
                  msg: "课程时间未设定",
                  backgroundColor: ThemeRegular.backgroundColor,
                  textColor: ThemeRegular.textColor
                );
                return;
              }

              setState(() {
                PreloadData.scheduleCourses.add(CourseItem(
                  day: courseDay,
                  weeks: courseWeeks,
                  section: courseSection,
                  len: courseLen,
                  courseName: courseNameController.text,
                  courseCode: courseCodeController.text,
                  teachers: teacherController.text.split(","),
                  classroom: classroomController.text
                ));
                PreloadData.saveSchedule(null);
              });

              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {

    int _index = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text("课程列表"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            iconSize: 26,
            onPressed: showAddDialog,
          ),
        ],
      ),
      backgroundColor: ThemeRegular.backgroundColor,
      body: SingleChildScrollView(
        child: PreloadData.scheduleCourses==null || PreloadData.scheduleCourses.length == 0? Container(
          margin: EdgeInsets.all(ThemeRegular.cardMargin),
          padding: EdgeInsets.fromLTRB(12, 20, 10, 10),
          decoration: BoxDecoration(
            color: ThemeRegular.cardBackgroundColor,
            borderRadius: ThemeRegular.cardRadius,
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.info_outline, size: 35, color: ThemeRegular.themeTextColor,),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text("当前没有任何课程"),
                )
              ],
            ),
          ),
        ) : Column(
          children: PreloadData.scheduleCourses.map((e) => _CourseItemWidget(
            item: e,
            itemIndex: _index++,
            changeFunc: (index,item) async {

              setState(() {
                PreloadData.scheduleCourses[index] = item;
                PreloadData.saveSchedule(null);
              });

            },
            deleteFunc: (index) async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              PreloadData.scheduleCourses.removeAt(index);

              setState(() {
                PreloadData.saveSchedule(null);
              });

              Navigator.of(context).pop();
            },
          )).toList(),
        ),
      ),
    );
  }
}