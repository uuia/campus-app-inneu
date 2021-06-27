
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inneu/components/titleLine.dart';
import 'package:inneu/preloadData.dart';
import 'package:inneu/service/request.dart';
import 'package:inneu/service/storage.dart';
import 'package:inneu/theme.dart';
import 'package:loading/indicator/line_scale_indicator.dart';
import 'package:loading/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 将两个时间格式化为 year-month-date hh:mm-hh:mm的字符串
String _parseTime(DateTime start, DateTime end) {
  return "${start.year}-${start.month.toString().padLeft(2,'0')}-${start.day.toString().padLeft(2,'0')} "
  "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}-"
  "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}";
}

// 考试卡片上面的键值对
class _KeyValue extends StatelessWidget {

  final String keyName;
  final String value;

  _KeyValue({this.keyName, this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(12, 5, 10, 5),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(8, 4, 10, 4),
            width: 80,
            child: Text(keyName, style: TextStyle(
              fontSize: 14,
              color: ThemeRegular.lightColor,
              fontWeight: FontWeight.w500,
              fontFamily: "SourceHanSans",
            )),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(8, 4, 10, 4),
            child: Text(value, style: TextStyle(
              fontSize: 14,
              color: ThemeRegular.deepColor,
            )),
          )
        ],
      ),
    );
  }

}

// 整个结果体
class _ExamPageBody extends StatelessWidget {

  final List<Map<String,dynamic>> data;
  final Function(int index) showEdit;

  _ExamPageBody({this.data, this.showEdit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: data.length == 0 ? [Container(
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
                child: Text("当前没有任何考试日程"),
              )
            ],
          ),
        ),
      )] : data.map((e) => Container(
        margin: EdgeInsets.all(ThemeRegular.cardMargin),
        padding: EdgeInsets.fromLTRB(12, 8, 10, 12),
        decoration: BoxDecoration(
          color: ThemeRegular.cardBackgroundColor,
          borderRadius: ThemeRegular.cardRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(18, 8, 8, 4),
                  child: Text(e["course_name"], style: TextStyle(
                    color: ThemeRegular.deepColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: "SourceHanSans",
                  )),
                ),
                SizedBox(
                  height: 26,
                  width: 60,
                  child: RaisedButton(
                    color: ThemeRegular.backgroundColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(13)),
                    ),
                    onPressed: () {showEdit(data.indexOf(e));},
                    child: Text("编辑"),
                  ),
                ),
              ],
            ),
            _KeyValue(keyName: "课程号", value: e["code"]),
            _KeyValue(keyName: "考试类别", value: e["type"]),
            _KeyValue(keyName: "考场", value: e["room"]),
            _KeyValue(keyName: "座位号", value: e["seat"]),
            _KeyValue(
                keyName: "时间",
                value: e["timestamp"] == -1?
                "时间未安排"
                    :
                _parseTime(DateTime.fromMillisecondsSinceEpoch(e["timestamp"]) , DateTime.fromMillisecondsSinceEpoch(e["timestamp_end"]))
            )
          ],
        ),
      )).toList(),
    );
  }

}

class _TimeRangPicker extends StatefulWidget {

  final DateTime start;
  final DateTime end;
  final Function(DateTime start,DateTime end) setter;

  _TimeRangPicker({this.start,this.end,this.setter});

  @override
  _TimeRangePickerState createState() => _TimeRangePickerState();

}

class _TimeRangePickerState extends State<_TimeRangPicker> {

  DateTime _startTime;
  DateTime _endTime;

  @override
  initState() {
    _startTime = widget.start;
    _endTime = widget.end;
    super.initState();
  }

  showDateTimePicker() {
    DatePicker.showDateTimePicker(
        context,
        onConfirm: (date) {
          DatePicker.showTimePicker(
              context,
              currentTime: _startTime,
              locale: LocaleType.zh,
              onConfirm: (endDate) {
                setState(() {
                  _startTime = date;
                  _endTime = endDate;
                });
                widget.setter(date,endDate);
                print(endDate);
              }
          );
        },
        currentTime: _startTime??DateTime.now(),
        locale: LocaleType.zh
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(5),
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        color: ThemeRegular.backgroundColor,
      ),
      child: Center(
        child: GestureDetector(
          onTap: () {
            showDateTimePicker();
          },
          child: Text(_startTime == null || _endTime == null? "时间未安排" : _parseTime(_startTime, _endTime), style: TextStyle(
              fontSize: 14
          )),
        ),
      ),
    );
  }
}


class ExamPage extends StatefulWidget{
  _ExamPageState createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {

  String _semesterName = PreloadData.examSemesterName;
  int _semesterId = PreloadData.examSemesterId;
  List<Map<String,dynamic>> _data = [];
  bool _isLoading = false;
  bool _loadError = false;

  TextEditingController codeController = TextEditingController();
  TextEditingController courseNameController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController roomController = TextEditingController();
  TextEditingController seatController = TextEditingController();

  DateTime _startTime;
  DateTime _endTime;

  showPicker() {
    Picker(
      adapter: PickerDataAdapter(
        data: PreloadData.semesterMap.keys.map((e) => PickerItem(text: Text(e))).toList(),
      ),
      cancelText: "取消",
      confirmText: "确认",
      onConfirm: (Picker picker,List value) {
        setState(() {
          _semesterName = PreloadData.semesterMap.keys.toList()[value[0]];
          _semesterId = PreloadData.semesterMap[_semesterName];
        });
        loadData();
      }
    ).showModal(context);
  }


  showAddDialog() async {
    typeController.text = "";
    roomController.text = "";
    seatController.text = "";
    courseNameController.text = "";
    codeController.text = "";

    _startTime = null;
    _endTime = null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("新建"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(4, 10, 4, 10),
                child: TextField(
                  controller: codeController,
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
                  controller: typeController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                    labelText: "考试类别",
                    hintText: "考试类别",
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(4, 10, 4, 10),
                child: TextField(
                  controller: roomController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                    labelText: "考场",
                    hintText: "考场",
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(4, 10, 4, 10),
                child: TextField(
                  controller: seatController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                    labelText: "座位号",
                    hintText: "座位号",
                  ),
                ),
              ),
              _TimeRangPicker(
                start: _startTime,
                end: _endTime,
                setter: (start, end) {
                  _startTime = start;
                  _endTime = end;
                },
              )
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("取消"),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text("新建"),
            onPressed: () async {
              if (typeController.text == "") {
                Fluttertoast.showToast(msg: "考试类型不能为空", backgroundColor: ThemeRegular.lightColor);
                return;
              }
              if(courseNameController.text == "") {
                Fluttertoast.showToast(msg: "课程名称不能为空", backgroundColor: ThemeRegular.lightColor);
                return;
              }
              if(codeController.text == "") {
                Fluttertoast.showToast(msg: "课程号不能为空", backgroundColor: ThemeRegular.lightColor);
                return;
              }
              Map<String,dynamic> newRecord = {
                "type": typeController.text,
                "code": codeController.text,
                "course_name": courseNameController.text,
                "room": roomController.text == "" ? "地点未安排": roomController.text,
                "seat": seatController.text == "" ? "地点未安排": seatController.text,
                "timestamp": _startTime==null? -1 : _startTime.millisecondsSinceEpoch,
                "timestamp_end": _endTime==null? -1 : _endTime.millisecondsSinceEpoch,
              };
              _startTime = null;
              _endTime = null;
              setExam(_semesterId, newRecord);
              Navigator.pop(context);
              await loadData();
            },
          ),
        ],
      ),
    );
  }

  showEditDialog(int index) async {

    typeController.text = _data[index]["type"];
    roomController.text = _data[index]["room"];
    seatController.text = _data[index]["seat"];

    _startTime = _data[index]["timestamp"] == null || _data[index]["timestamp"] == -1  ?
    null :
    DateTime.fromMillisecondsSinceEpoch(_data[index]["timestamp"]);
    _endTime =  _data[index]["timestamp_end"] == null || _data[index]["timestamp"] == -1 ?
    null :
    DateTime.fromMillisecondsSinceEpoch(_data[index]["timestamp_end"]);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Column(
            children: <Widget>[
              Text(_data[index]["course_name"], style: TextStyle(
                fontSize: 18,
                fontFamily: "SourceHanSans",
                color: ThemeRegular.deepColor
              )),
              Container(
                margin: EdgeInsets.all(2),
                child: Text(_data[index]["code"], style: TextStyle(
                  fontSize: 12,
                  color: ThemeRegular.lightColor
                )),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(4, 10, 4, 10),
                child: TextField(
                  controller: typeController,
                  decoration: InputDecoration(
                    labelText: "考试类别",
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                    hintText: "考试类别",
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(4, 10, 4, 10),
                child: TextField(
                  controller: roomController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                    labelText: "考场",
                    hintText: "考场",
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                child: TextField(
                  controller: seatController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                    labelText: "座位号",
                    hintText: "座位号",
                  ),
                ),
              ),
              _TimeRangPicker(
                start: _startTime,
                end: _endTime,
                setter: (start, end) {
                  _startTime = start;
                  _endTime = end;
                },
              )
            ],
          ),
          shape: RoundedRectangleBorder(borderRadius: ThemeRegular.cardRadius),
          backgroundColor: ThemeRegular.cardBackgroundColor,
          actions: <Widget>[
            FlatButton(child: Text('取消'),onPressed: (){
              Navigator.pop(context);
            }),
            _data[index]["delete"]?
            FlatButton(
              child: Text("删除"),
              onPressed: () async {
                String code = _data[index]["code"];
                await removeExam(_semesterId, code);
                _data.remove(index);
                setState(() {
                  _data = _data;
                });
                Navigator.pop(context);
                loadData();
              },
            ):
            Container(),
            FlatButton(child: Text('确认'),onPressed: () async {
              _data[index]["type"] = typeController.text;
              _data[index]["room"] = roomController.text;
              _data[index]["seat"] = seatController.text;
              _data[index]["timestamp"] = _startTime == null? -1 : _startTime.millisecondsSinceEpoch;
              _data[index]["timestamp_end"] = _endTime == null? -1 : _endTime.millisecondsSinceEpoch;
              setState(() {
                _data = _data;
              });
              await setExam(_semesterId, _data[index]);
              Navigator.pop(context);
              await loadData();
            }),
          ]
      )
    );

  }

  loadData() async {

    List<Map<String,dynamic>> data = [];
    Set<String> codeSet = {};

    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storageDataString = prefs.getString("exam_storage_$_semesterId");
    print(storageDataString);
    if (storageDataString!=null && storageDataString != "") {
      Map<String, dynamic> storageData = json.decode(storageDataString);
      storageData.keys.forEach((k) {
        Map<String,dynamic> course = Map<String,dynamic>.from(storageData[k]);
        String courseCode = course["code"];
        if (courseCode != null && courseCode != "") {
          codeSet.add(courseCode);
        }
        course["delete"] = true;
        data.add(course);
      });
    }

    setState(() {
      _data = data;
    });

    if (PreloadData.isLogin) {

      var respData = await queryExam(_semesterId);
      if (respData == null) {
        setState(() {
          _isLoading = false;
          _loadError = true;
        });
      } else {
        _loadError = false;
        respData.forEach((element) {
          String courseCode = element["code"];
          if (courseCode != null && courseCode != "" && codeSet.contains(courseCode)) {
            return;
          }
          element["delete"] = false;
          data.add(element);
        });
      }

    }

    setState(() {
      _data = data;
      _isLoading = false;
    });


  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: Text("考试日程"),
      ),
      backgroundColor: ThemeRegular.backgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await loadData();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      child: Container(
                        height: 40,
                        margin: EdgeInsets.all(ThemeRegular.cardMargin),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: ThemeRegular.cardBackgroundColor,
                        ),
                        child: Text(_semesterName, style: TextStyle(
                          color: ThemeRegular.textColor,
                          fontSize: 14
                        )),
                      ),
                      onTap: showPicker,
                    ),
                    GestureDetector(
                      onTap: () {
                        showAddDialog();
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: ThemeRegular.cardBackgroundColor,
                        ),
                        child: Icon(Icons.add, color: ThemeRegular.textColor, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              _isLoading ? Container(
                height: 150,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(90, 50, 90, 50),
                margin: EdgeInsets.all(ThemeRegular.cardMargin),
                decoration: BoxDecoration(
                  borderRadius: ThemeRegular.cardRadius,
                  color: ThemeRegular.cardBackgroundColor,
                ),
                child: Loading(
                  size: 10,
                  indicator: LineScaleIndicator(),
                  color: ThemeRegular.textColor,
                ),
              ) : _loadError? Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.all(ThemeRegular.cardMargin),
                decoration: BoxDecoration(
                  borderRadius: ThemeRegular.cardRadius,
                  color: ThemeRegular.cardBackgroundColor,
                ),
                child: GestureDetector(
                  onTap: loadData,
                  child: Column(
                    children: [
                      Container(
                        child: Icon(Icons.error_outline, size: 40, color: ThemeRegular.themeTextColor,),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 3, 0, 20),
                        child: Text("加载出错，点击可以重新加载", style: TextStyle(
                          fontSize: 15
                        ),),
                      )
                    ],
                  ),
                ),
              ) : _ExamPageBody(data: _data, showEdit: showEditDialog),
              TitleLine(title: "说明",eng: "Notes"),
              Container(
                margin: EdgeInsets.all(15),
                child: Text(
                  "由教务处自动导入的数据仅供参考，如需与教务处数据核对请点击下方教务处入口。结果仅供参考请以实际通知为准",
                  style: TextStyle(
                    color: ThemeRegular.textColor,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(15),
                child: Text(
                  "「关于优先级与更新」用户手动编辑与修改的优先级要高于由教务处获取到的考试日程。课程以课程号为索引，只要课程号相同就会被认为是同一课程，若用户先手动添加了某课程的考试日程而后从教务处导入则此课程数据将将不会更新，若用户手动编辑了某课程的考试日程，教务处的更新将会被忽视",
                  style: TextStyle(
                    color: ThemeRegular.textColor,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}