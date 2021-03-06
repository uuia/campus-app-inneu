

import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:inneu/components/errorRefresh.dart';
import 'package:inneu/components/gradeList.dart';
import 'package:inneu/components/titleLine.dart';
import 'package:inneu/service/request.dart';
import 'package:inneu/service/state.dart';
import 'package:inneu/theme.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:url_launcher/url_launcher.dart';

import '../preloadData.dart';


class _ContentLine extends StatelessWidget {

  final String key1;
  final String value1;
  final String key2;
  final String value2;

  _ContentLine({this.key1, this.key2, this.value1, this.value2});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(2),
      padding: EdgeInsets.fromLTRB(14, 1, 14, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(key1, style: TextStyle(
                  color: ThemeRegular.textColor,
                  fontSize: 14
              ),),
              Container(
                margin: EdgeInsets.fromLTRB(3, 1, 1, 1),
                child: Text(value1, style: TextStyle(
                    color: ThemeRegular.themeTextColor,
                    fontSize: 14
                )),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Text(key2, style: TextStyle(
                  color: ThemeRegular.textColor,
                  fontSize: 14
              )),
              Container(
                margin: EdgeInsets.fromLTRB(3, 1, 1, 1),
                child: Text(value2, style: TextStyle(
                    color: ThemeRegular.themeTextColor,
                    fontSize: 14
                )),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _GradeCard extends StatelessWidget {

  final bool isLoading;
  final List<Map<String,dynamic>> data;

  _GradeCard({this.isLoading, this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(ThemeRegular.cardMargin),
      padding: EdgeInsets.fromLTRB(3, 10, 3, 12),
      decoration: BoxDecoration(
          borderRadius: ThemeRegular.cardRadius,
          color: ThemeRegular.cardBackgroundColor
      ),
      child: isLoading? Center(
        child: Container(
          height: 200,
          child: Loading(
            indicator: BallPulseIndicator(),
            color: ThemeRegular.textColor,
            size: 60,
          ),
        ),
      ) : Column(
        children: <Widget>[
          data.length == 0? Center(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  child: Icon(Icons.error_outline, color: ThemeRegular.themeTextColor, size: 40,),
                ),
                Text("?????????????????????????????????", style: TextStyle(
                  fontSize: 15,
                ))
              ],
            ),
          ) : GradeList(
            data: data,
            width: MediaQuery.of(context).size.width,
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("?????????? ????????????", style: TextStyle(
                  color: ThemeRegular.textColor,
                  fontSize: 13,
                )),
                Text(" ??????", style: TextStyle(
                  color: ThemeRegular.textColor,
                  fontSize: 13,
                )),
                GestureDetector(
                  onTap: () {
                    launch("https://webvpn.neu.edu.cn/http/77726476706e69737468656265737421a2a618d275613e1e275ec7f8/eams/");
                  },
                  child: Text("??????", style: TextStyle(
                    fontSize: 13,
                    color: ThemeRegular.themeTextColor
                  )),
                ),
                Text("???????????????", style: TextStyle(
                  color: ThemeRegular.textColor,
                  fontSize: 13,
                ))
              ],
            ),
          )
        ],
      ),
    );
  }
}


class GradePage extends StatefulWidget {
  @override
  _GradePageState createState() => _GradePageState();
}

class _GradePageState extends State<GradePage> {

  String _selectSemesterName = "";
  int _selectSemesterId = -1;
  String _gpa = "-";
  String _semesterGpa = "-";
  String _semesterSumCredit = "-";
  List<Map<String,dynamic>> _data = [];
  bool _isLoading = true;
  bool _isInit = false;
  bool _error = false;

  loadData() async {
    var semesters = PreloadData.semesterMap;
    var currentSemester = PreloadData.gradeSemesterId;
    print(semesters);
    print(currentSemester);

    semesters.keys.forEach((element) {
      if (semesters[element] == currentSemester) {
        setState(() {
          _selectSemesterName = element;
          _selectSemesterId = currentSemester;
        });
      }
    });

    loadSemesterGrade();

  }

  loadSemesterGrade() async {
    var data = await queryGrade(_selectSemesterId);
    if (data == null) {
      setState(() {
        _isLoading = false;
        _error = true;
      });
      return;
    } else {
      _error = false;
      List<dynamic> coursesData = data["courses"];
      if (coursesData.length == 0) {
        setState(() {
          _isLoading = false;
          _data = coursesData.map((e) => Map<String,dynamic>.from(e)).toList();
          _gpa = data["gpa"];
          _isInit = true;
          _semesterSumCredit = "-";
          _semesterGpa = "-";
        });
        return;
      }
      double creditSum = 0;
      double semesterGpa = 0;
      coursesData.forEach((element) {
        creditSum += double.parse(element["credit"]);
        semesterGpa += double.parse(element["credit"])*double.parse(element["grade_point"]);
      });
      semesterGpa = semesterGpa/creditSum;
      setState(() {
        _isLoading = false;
        _data = coursesData.map((e) => Map<String,dynamic>.from(e)).toList();
        _gpa = data["gpa"];
        _isInit = true;
        _semesterSumCredit = creditSum.toString();
        _semesterGpa = semesterGpa.toStringAsFixed(4);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void showSemesterPicker(BuildContext context) async {

    Picker(
      adapter: PickerDataAdapter(
        data: PreloadData.semesterMap.keys.map((e) => PickerItem(text: Text(e))).toList()
      ),
      confirmText: "??????",
      cancelText: "??????",
      onConfirm: (Picker picker,List value) {
        var name = PreloadData.semesterMap.keys.toList()[value[0]];
        setState(() {
          _isLoading = true;
          _selectSemesterName = name;
          _selectSemesterId = PreloadData.semesterMap[name];
        });
        loadSemesterGrade();
      }
    ).showModal(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("????????????"),
      ),
      backgroundColor: ThemeRegular.backgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await loadSemesterGrade();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.all(ThemeRegular.cardMargin),
                padding: EdgeInsets.fromLTRB(3, 10, 3, 12),
                decoration: BoxDecoration(
                    borderRadius: ThemeRegular.cardRadius,
                    color: ThemeRegular.cardBackgroundColor
                ),
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        if (_isLoading == true) {
                          return;
                        }
                        showSemesterPicker(context);
                      },
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(3) ,
                            child: Text(_selectSemesterName, style: TextStyle(
                              fontSize: 18,
                              color: ThemeRegular.textColor,
                            )),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 4, 4, 0),
                                child: Icon(Icons.refresh, color: ThemeRegular.themeTextColor, size: 14),
                              ),
                              Text("????????????", style: TextStyle(
                                  color: ThemeRegular.themeTextColor, fontSize: 14
                              ))
                            ],
                          )
                        ],
                      ),
                    ),
                    _ContentLine(
                      key1: "????????????",
                      value1: _gpa,
                      key2: "????????????",
                      value2: _semesterGpa,
                    ),
                    _ContentLine(
                      key1: "?????????????????????",
                      value1: _semesterSumCredit,
                      key2: "??????????????????",
                      value2:  _isInit? _data.length.toString() : "-",
                    ),
                  ],
                ),
              ),
              !_isLoading && _error? Container(
                margin: EdgeInsets.all(ThemeRegular.cardMargin),
                decoration: BoxDecoration(
                  color: ThemeRegular.cardBackgroundColor,
                  borderRadius: ThemeRegular.cardRadius,
                ),
                child: ErrorRefresh(onRefresh: loadSemesterGrade),
              ) : _GradeCard(
                data: _data,
                isLoading: _isLoading,
              ),
              TitleLine(
                title: "??????",
                eng: "Notes",
              ),
              Container(
                margin: EdgeInsets.all(15),
                child: Text(
                  "????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????,????????????????????????????????????????????????",
                  style: TextStyle(
                    color: ThemeRegular.textColor,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(15),
                child: Text(
                  "????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????GPA???????????????????????????????????????????????????????????????50??????10???????????????????????????????????????????????????????????????????????????",
                  style: TextStyle(
                    color: ThemeRegular.textColor,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}