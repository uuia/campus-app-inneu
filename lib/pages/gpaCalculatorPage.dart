import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inneu/components/titleLine.dart';
import 'package:inneu/pages/loginPage.dart';
import 'package:inneu/preloadData.dart';
import 'package:inneu/service/request.dart';
import 'package:inneu/theme.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:url_launcher/url_launcher.dart';


class _CheckBox extends StatefulWidget {

  final Function(bool) onChange;
  final bool select;

  _CheckBox({this.onChange, this.select});

  @override
  _CheckBoxState createState() => _CheckBoxState();

}

class _CheckBoxState extends State<_CheckBox> {

  bool select;

  @override
  void initState() {
    select = widget.select;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      tristate: false,
      value: select,
      onChanged: (data) {
        setState(() {
          select = data;
        });
        widget.onChange(data);
      },
    );
  }
}


class _GradeItem {
  String sumGrade;
  double sumGradeNumber;
  double gp;
  String courseName;
  bool select;
  bool fromAAO;
  int gradeType;

  _GradeItem({this.sumGrade,this.gp,this.courseName,this.select, this.sumGradeNumber, this.fromAAO = false, this.gradeType = 0});

}


class _GpaCalculatorGradeContent extends StatelessWidget {

  final List<_GradeItem> grade;
  final Function(int index) deleteFunction;
  _GpaCalculatorGradeContent({this.grade, this.deleteFunction});

  @override
  Widget build(BuildContext context) {

    if (grade == null || grade.length == 0) {
      return Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(10),
            child: Icon(Icons.hourglass_empty, color: ThemeRegular.themeTextColor, size: 48),
          ),
          Text(
            "还没有添加课程，请手动导入或点击下方由教务处自动导入",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontFamily: "SourceHanSans",
            ),
          )
        ],
      );
    }

    double contentWidth = MediaQuery.of(context).size.width - ThemeRegular.cardMargin * 2 - 15;

    List<Widget> columnChildren = [
      Container(
        color: ThemeRegular.backgroundColor,
        padding: EdgeInsets.fromLTRB(0, 6, 0, 6),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              width: contentWidth*0.13,
            ),
            Container(
              width: contentWidth*0.25,
              child: Center(child: Text("课程名称")),
            ),
            Container(
              width: contentWidth*0.15,
              child: Center(child: Text("学分")),
            ),
            Container(
              width: contentWidth*0.20,
              child: Center(child: Text("最终成绩")),
            ),
          ],
        ),
      ),
    ];

    int widgetIndex = 0;
    grade.forEach((element) {
      columnChildren.add(
        Container(
          color: widgetIndex%2 == 0? ThemeRegular.cardBackgroundColor : ThemeRegular.backgroundColor,
          padding: EdgeInsets.fromLTRB(0, 6, 0, 6),
          child: Row(
            children: <Widget>[
              Container(
                width: contentWidth*0.13,
                child: Center(
                  child: _CheckBox(
                    select: element.select,
                    onChange: (data) {
                      element.select = data;
                    },
                  ),
                ),
              ),
              Container(
                width: contentWidth*0.25,
                child: Center(child: Text(element.courseName, textAlign: TextAlign.center,)),
              ),
              Container(
                width: contentWidth*0.15,
                child: Center(child: Text(element.gp.toString())),
              ),
              Container(
                width: contentWidth*0.20,
                child: Center(child: Text(element.sumGrade)),
              ),
              Container(
                width: contentWidth*0.15,
                child: Center(
                  child: GestureDetector(
                    onTap: (i) {
                      return () {
                        deleteFunction(i);
                      };
                    }(widgetIndex),
                    child: Icon(Icons.delete_outline),
                  ),
                ),
              )
            ],
          ),
        ),
      );
      widgetIndex++;
    });

    return Column(children: columnChildren);
  }
}


class GpaCalculatorBody extends StatefulWidget {

  @override
  _GpaCalculatorBodyState createState() => _GpaCalculatorBodyState();

}

class _GpaCalculatorBodyState extends State<GpaCalculatorBody> {

  double stdGPA;
  double std4GPA;
  double improve4GPA;
  double improve4pGPA;
  double pkuGPA;
  double zjuGPA;
  double sjtuGPA;
  double ustcGPA;
  double candaGPA;
  double wesGPA;
  double weightedAverage;
  double arithmeticMean;

  bool showLoadFromAAO;
  bool showLoading;

  List<_GradeItem> data = [];

  @override
  initState() {
    showLoadFromAAO = true;
    showLoading = false;
    super.initState();
  }

  computeGPA() {

    stdGPA = 0;
    std4GPA = 0;
    improve4GPA = 0;
    improve4pGPA = 0;
    pkuGPA = 0;
    zjuGPA = 0;
    sjtuGPA = 0;
    ustcGPA = 0;
    candaGPA = 0;
    wesGPA = 0;
    weightedAverage = 0;
    arithmeticMean = 0;

    double gpSum = 0;
    data.forEach((element) {
      if (element.select == false) {
        return;
      }
      gpSum += element.gp;
    });

    setState(() {
      data.forEach((element) {

        if (element.select == false) {
          return;
        }

        // 标准加权
        stdGPA += 4*element.sumGradeNumber/100*element.gp/gpSum;

        // 标准4.0
        std4GPA += (element.sumGradeNumber >= 90 ? 4.0 :
        (element.sumGradeNumber >= 80 ? 3.0 : (
        element.sumGradeNumber >= 70 ? 2.0 : (
        element.sumGradeNumber >= 60 ? 1.0 : 0
        ))))*element.gp/gpSum;

        // 改进4.0
        improve4GPA += (element.sumGradeNumber >= 85 ? 4.0 :
        (element.sumGradeNumber >= 70 ? 3.0 : (
        element.sumGradeNumber >= 60 ? 2.0 : 0
        )))*element.gp/gpSum;

        // 改进4.0 2
        improve4pGPA += (element.sumGradeNumber >= 85 ? 4.0 :
        (element.sumGradeNumber >= 75 ? 3.0 : (
        element.sumGradeNumber >= 60 ? 2.0 : 0
        )))*element.gp/gpSum;

        // 浙江大学
        zjuGPA += (element.gradeType == 0 ? (element.sumGradeNumber >= 85 ? 4.0 :(element.sumGradeNumber >= 60 ? (element.sumGradeNumber-45)/10 : 0 )) :
        element.gradeType == 1 ? (element.sumGrade == "优" ? 4.0 : element.sumGrade == "良" ? 3.5 : element.sumGrade == "中" ? 2.5 : element.sumGrade == "及格" ? 1.5 : 0) :
        element.sumGrade == "合格" ? 3.0 : 0 )*element.gp/gpSum;

        // 北大
        pkuGPA += (element.sumGradeNumber >= 90 ? 4.0 :
        (element.sumGradeNumber > 85 ? 3.7 :
        (element.sumGradeNumber >= 82 ? 3.3 :
        (element.sumGradeNumber >= 78 ? 3.0 :
        (element.sumGradeNumber >= 75 ? 2.7 :
        (element.sumGradeNumber >= 72 ? 2.3 :
        (element.sumGradeNumber >= 68 ? 2.0 :
        (element.sumGradeNumber >= 64 ? 1.5 :
        (element.sumGradeNumber >= 60 ? 1 : 0
        )))))))))*element.gp/gpSum;

        // 上交
        sjtuGPA += (element.sumGradeNumber >= 95 ? 4.3 :
        (element.sumGradeNumber > 90 ? 4.0 :
        (element.sumGradeNumber >= 85 ? 3.7 :
        (element.sumGradeNumber >= 80 ? 3.3 :
        (element.sumGradeNumber >= 75 ? 3.0 :
        (element.sumGradeNumber >= 70 ? 2.7 :
        (element.sumGradeNumber >= 67 ? 2.3 :
        (element.sumGradeNumber >= 65 ? 2.0 :
        (element.sumGradeNumber >= 62 ? 1.7 :
        (element.sumGradeNumber >= 60 ? 1.0 : 0
        ))))))))))*element.gp/gpSum;

        // 中科大
        ustcGPA += (element.sumGradeNumber >= 95 ? 4.3 :
        (element.sumGradeNumber > 90 ? 4.0 :
        (element.sumGradeNumber >= 85 ? 3.7 :
        (element.sumGradeNumber >= 82 ? 3.3 :
        (element.sumGradeNumber >= 78 ? 3.0 :
        (element.sumGradeNumber >= 75 ? 2.7 :
        (element.sumGradeNumber >= 72 ? 2.3 :
        (element.sumGradeNumber >= 71 ? 2.0 :
        (element.sumGradeNumber >= 65 ? 1.7 :
        (element.sumGradeNumber >= 64 ? 1.5 :
        (element.sumGradeNumber >= 61 ? 1.3 :
        (element.sumGradeNumber >= 60 ? 1.0 : 0
        ))))))))))))*element.gp/gpSum;

        // WES
        wesGPA += (element.sumGradeNumber  >= 90 ? 4.0 :
        (element.sumGradeNumber >= 80 ? 3.0 :
        (element.sumGradeNumber >= 70 ? 2.0 :
        (element.sumGradeNumber >= 60 ? 1.0 : 0
        ))))*element.gp/gpSum;

        // 加拿大
        candaGPA += (element.sumGradeNumber  >= 90 ? 4.3 :
        (element.sumGradeNumber >= 85 ? 4.0 :
        (element.sumGradeNumber >= 80 ? 3.7 :
        (element.sumGradeNumber >= 75 ? 3.3 :
        (element.sumGradeNumber >= 70 ? 3.0 :
        (element.sumGradeNumber >= 65 ? 2.7 :
        (element.sumGradeNumber >= 60 ? 2.3 : 0
        )))))))*element.gp/gpSum;

        // 算数平均数
        arithmeticMean += element.sumGradeNumber/data.length;
        // 加权平均数
        weightedAverage += element.sumGradeNumber*element.gp/gpSum;

      });
    });
  }

  loadGradeFromAAO([tryTimes = 0]) async {
    var scoreList = await queryAllGrade();
    if (scoreList == null) {
      if (tryTimes < 5) {
        await Future.delayed(Duration(milliseconds: 280));
        loadGradeFromAAO(tryTimes+1);
      }
      return;
    } else {

      data.removeWhere((element) => element.fromAAO);

      setState(() {
        scoreList.forEach((element) {
          int gradeType = 1;
          String grade = element["sum_grade"];
          double sumGrade = 0;
          if (grade == "优") {
            sumGrade = 95;
          } else if (grade == "良") {
            sumGrade = 85;
          } else if (grade == "中") {
            sumGrade = 75;
          } else if (grade == "及格") {
            sumGrade = 65;
          } else if (grade == "合格") {
            gradeType = 2;
            sumGrade = 80;
          } else if (grade == "不及格" || grade == "不合格") {
            sumGrade = 0;
          } else {

            gradeType = 0;
            try {
              sumGrade = double.parse(grade);
            } catch (e) {
              sumGrade = 0;
            }

          }
          data.add(_GradeItem(
            gp: double.parse(element["credit"].toString()),
            select: true,
            courseName: element["course_name"],
            sumGrade: grade,
            sumGradeNumber: sumGrade,
            fromAAO: true,
            gradeType: gradeType,
          ));
        });
        showLoading = false;
      });
    }
  }

  showAddDialog() {

    TextEditingController nameController = TextEditingController();
    TextEditingController creditController = TextEditingController();
    TextEditingController gradeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("添加"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder(),
                  labelText: "课程名称",
                  hintText: "课程名称",
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: creditController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder(),
                  labelText: "课程学分",
                  hintText: "课程学分",
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
              child: TextField(
                controller: gradeController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder(),
                  labelText: "最终成绩",
                  hintText: "最终成绩",
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("取消"),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text("添加"),
            onPressed: (){

              if (nameController.text == "") {
                Fluttertoast.showToast(
                  msg: "课程名不能为空",
                  backgroundColor: ThemeRegular.backgroundColor,
                  textColor: ThemeRegular.textColor,
                );
              }


              try {
                if(double.parse(creditController.text) < 0) {
                  Fluttertoast.showToast(
                    msg: "学分应为正数",
                    backgroundColor: ThemeRegular.backgroundColor,
                    textColor: ThemeRegular.textColor,
                  );
                }
              } catch (e) {
                Fluttertoast.showToast(
                  msg: "学分格式错误",
                  backgroundColor: ThemeRegular.backgroundColor,
                  textColor: ThemeRegular.textColor,
                );
                return;
              }

              try {
                if (double.parse(gradeController.text) <= 100 && double.parse(gradeController.text) >= 0) {
                  setState(() {
                    data.add(_GradeItem(
                      gp: double.parse(creditController.text),
                      courseName: nameController.text,
                      sumGrade: gradeController.text,
                      sumGradeNumber: double.parse(gradeController.text),
                      select: true,
                      gradeType: 0,
                    ));
                  });
                  Navigator.pop(context);
                } else {
                  print("成绩不合法");
                  Fluttertoast.showToast(
                      msg: "成绩应在0-100（包括0、100）之间",
                      backgroundColor: ThemeRegular.backgroundColor,
                      textColor: ThemeRegular.textColor
                  );
                }
              } catch (e) {
                double gradeNumber = 0;
                String gradeStr = gradeController.text;
                switch (gradeStr) {
                  case "优":
                    gradeNumber = 95;
                    break;
                  case "良":
                    gradeNumber = 85;
                    break;
                  case "中":
                    gradeNumber = 75;
                    break;
                  case "及格":
                    gradeNumber = 65;
                    break;
                  case "合格":
                    gradeNumber = 80;
                    break;
                  case "不及格":
                  case "不合格":
                    gradeNumber = 0;
                    break;
                  default :
                    Fluttertoast.showToast(
                        msg: "成绩只允许为数字或优(95)、良(85)、中(75)、及格(65)、不及格、合格(80)、不合格集中",
                        backgroundColor: ThemeRegular.backgroundColor,
                        textColor: ThemeRegular.textColor
                    );
                    return;
                }
                setState(() {
                  data.add(_GradeItem(
                    gp: double.parse(creditController.text),
                    courseName: nameController.text,
                    sumGrade: gradeController.text,
                    sumGradeNumber: gradeNumber,
                    select: true,
                    gradeType: gradeController.text=="合格"? 2 : 1
                  ));
                });
                Navigator.pop(context);
              }

            },
          ),
        ],
      )
    );

  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(ThemeRegular.cardMargin),
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          decoration: BoxDecoration(
            color: ThemeRegular.cardBackgroundColor,
            borderRadius: ThemeRegular.cardRadius,
          ),
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("标准加权:${stdGPA==null?"-":stdGPA.toStringAsFixed(4)}/4.0", style: TextStyle(
                        color: ThemeRegular.deepColor
                    )),
                    Text("标准4.0:${std4GPA==null?"-":std4GPA.toStringAsFixed(4)}/4.0", style: TextStyle(
                        color: ThemeRegular.deepColor
                    ))
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("改进4.0(1):${improve4GPA==null?"-":improve4GPA.toStringAsFixed(4)}/4.0", style: TextStyle(
                        color: ThemeRegular.deepColor
                    )),
                    Text("改进4.0(2):${improve4pGPA==null?"-":improve4pGPA.toStringAsFixed(4)}/4.0", style: TextStyle(
                        color: ThemeRegular.deepColor
                    ))
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("北大:${pkuGPA==null?"-":pkuGPA.toStringAsFixed(4)}/4.0", style: TextStyle(
                        color: ThemeRegular.deepColor
                    )),
                    Text("浙大:${zjuGPA==null?"-":zjuGPA.toStringAsFixed(4)}/4.0", style: TextStyle(
                        color: ThemeRegular.deepColor
                    ))
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("上交:${sjtuGPA==null?"-":sjtuGPA.toStringAsFixed(4)}/4.3", style: TextStyle(
                        color: ThemeRegular.deepColor
                    )),
                    Text("中科大:${ustcGPA==null?"-":ustcGPA.toStringAsFixed(4)}/4.3", style: TextStyle(
                        color: ThemeRegular.deepColor
                    ))
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("加拿大:${candaGPA==null?"-":candaGPA.toStringAsFixed(4)}/4.3", style: TextStyle(
                        color: ThemeRegular.deepColor
                    )),
                    Text("WES:${wesGPA==null?"-":wesGPA.toStringAsFixed(4)}/4.0", style: TextStyle(
                        color: ThemeRegular.deepColor
                    ))
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("加权平均分:${weightedAverage==null?"-":weightedAverage.toStringAsFixed(4)}/100", style: TextStyle(
                        color: ThemeRegular.deepColor
                    )),
                    Text("算术平均分:${arithmeticMean==null?"-":arithmeticMean.toStringAsFixed(4)}/100", style: TextStyle(
                        color: ThemeRegular.deepColor
                    ))
                  ],
                ),
              ),
            ],
          ),
        ), //计算结果
        Container(
          margin: EdgeInsets.all(ThemeRegular.cardMargin),
          padding: EdgeInsets.fromLTRB(12, 2, 12, 10),
          decoration: BoxDecoration(
            color: ThemeRegular.cardBackgroundColor,
            borderRadius: ThemeRegular.cardRadius,
          ),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: SizedBox(
                      height: 26,
                      child: RaisedButton(
                        elevation: 0,
                        onPressed: showAddDialog,
                        color: ThemeRegular.backgroundColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(13))
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.add, size: 13),
                            Text("添加", style: TextStyle(
                              fontSize: 13,
                            ))
                          ],
                        ),
                      ),
                    ),
                    margin: EdgeInsets.all(8),
                  ),
                  Container(
                    child: SizedBox(
                      height: 26,
                      width: 72,
                      child: RaisedButton(
                        onPressed: computeGPA,
                        elevation: 0,
                        color: ThemeRegular.backgroundColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(13))
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.check_circle_outline, size: 13),
                            Text("计算", style: TextStyle(
                              fontSize: 13,
                            ))
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _GpaCalculatorGradeContent(
                grade: data,
                deleteFunction: (deleteIndex){
                  setState(() {
                    data.removeAt(deleteIndex);
                  });
                },
              ),
              showLoadFromAAO?
              Row( // 由教务处导入按钮
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    elevation: 0,
                    color: ThemeRegular.cardBackgroundColor,
                    onPressed: (){
                      if (PreloadData.isLogin == false) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage() )
                        );
                        return;
                      }
                      setState(() {
                        showLoadFromAAO = false;
                        showLoading = true;
                      });
                      loadGradeFromAAO();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(3, 6, 3, 2),
                          child: Icon(Icons.add, size: 16, color: ThemeRegular.themeTextColor),
                        ),
                        Text("点此由教务处导入", style: TextStyle(
                          fontSize: 16,
                          color: ThemeRegular.textColor,
                        ))
                      ],
                    ),
                  )
                ],
              ) : Container(),
              showLoading?
              Container(
                child: Loading(
                  size: 20,
                  color: ThemeRegular.textColor,
                  indicator: BallPulseIndicator(),
                ),
              ) : Container(),
            ],
          ),
        ),
      ],
    );
  }
}


class GpaCalculatorPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GPA计算器"),
      ),
      backgroundColor: ThemeRegular.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            GpaCalculatorBody(),
            TitleLine(title: "说明", eng: "Notes"),
            Container(
              margin: EdgeInsets.all(15),
              child: RichText(
                text: TextSpan(
                    children: [
                      TextSpan(
                          text: "「GPA怎么算的？」GPA计算方法参照网站",
                          style: TextStyle(
                              color: ThemeRegular.textColor,
                              fontSize: 12
                          )
                      ),
                      TextSpan(
                          text: "https://apps.chasedream.com/gpa",
                          style: TextStyle(
                              color: ThemeRegular.themeTextColor,
                              fontSize: 12,
                              decoration: TextDecoration.underline
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            launch("https://apps.chasedream.com/gpa");
                          }
                      ),
                      TextSpan(
                          text: "也就是上面所给的计算方法,一键导入的数据来自东北大学教务处。对于计算器的详情实现以及更多疑问请查看",
                          style: TextStyle(
                              color: ThemeRegular.textColor,
                              fontSize: 12
                          )
                      ),
                      TextSpan(
                          text: "GPA计算器疑难解答详情页",
                          style: TextStyle(
                              color: ThemeRegular.themeTextColor,
                              fontSize: 12,
                              decoration: TextDecoration.underline
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {

                          }
                      )
                    ]
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(15),
              child: Text(
                "「上面的东北大学绩点和教务处绩点不一样？」上面的东北大学绩点是我们利用东北大学绩点算法自行计算的全部课程的GPA，但未考虑因挂科重修导致的绩点偏差。\n"
                    "\t(1) 因条件所限对于有缺考/挂科/降级经历的同学的绩点计算会有些许偏差，我们会尽快完善。\n"
                    "\t(2) 如果有未考评的科目也会导致计算不准确。\n"
                    "\t(3) 暂时仅支持2016级及以后的同学。\n"
                    "如果上面的东北大学绩点与您当前在校实际绩点吻合则证明计算是完全准确的。(查成绩页面所展示的绩点就是您当前在校的实际绩点)",
                style: TextStyle(
                  letterSpacing: 0.7,
                  color: ThemeRegular.textColor,
                  fontSize: 12,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}
