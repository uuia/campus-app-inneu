
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inneu/components/errorRefresh.dart';
import 'package:inneu/service/request.dart';
import 'package:loading/indicator/line_scale_indicator.dart';
import 'package:loading/loading.dart';
import 'package:inneu/theme.dart';

class _InitCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(ThemeRegular.cardMargin),
      decoration: BoxDecoration(
        color: ThemeRegular.cardBackgroundColor,
        borderRadius: ThemeRegular.cardRadius,
      ),
      padding: EdgeInsets.all(15),
      child: Center(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: Icon(Icons.list, color: ThemeRegular.themeTextColor, size: 60,),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: Text("请选择开始与结束时间后查询"),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataCard extends StatelessWidget {

  final List<Map<String,dynamic>> data;

  _DataCard({this.data});

  @override
  Widget build(BuildContext context) {

    int itemIndex = 0;

    TextStyle style = TextStyle(
        fontSize: 13,
        color: ThemeRegular.textColor
    );

    return Container(
      margin: EdgeInsets.all(ThemeRegular.cardMargin),
      padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
      decoration: BoxDecoration(
        color: ThemeRegular.cardBackgroundColor,
        borderRadius: ThemeRegular.cardRadius,
      ),
      child: data.length==0? Center(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 20, 0, 3),
              child: Icon(Icons.label_outline, size: 40, color: ThemeRegular.themeTextColor,),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 18),
              child: Text("所查询的时间没有任何交易"),
            )
          ],
        ),
      ) : Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 10,
                child: Center(
                  child: Text("交易时间"),
                ),
              ),
              Expanded(
                flex: 10,
                child: Center(
                  child: Text("消费类型"),
                ),
              ),
              Expanded(
                flex: 10,
                child: Center(
                  child: Text("消费终端"),
                ),
              ),
              Expanded(
                flex: 7,
                child: Center(
                  child: Text("交易金额"),
                ),
              ),
            ],
          )
        ]..addAll(data.map((e) => Container(
          margin: EdgeInsets.fromLTRB(5, 2, 5, 2),
          padding: EdgeInsets.all(5),
          color: (itemIndex++)%2==0?ThemeRegular.backgroundColor:ThemeRegular.cardBackgroundColor,
          child: Row(
            children: [
              Expanded(
                flex: 10,
                child: Center(
                  child: Text(formatDate(DateTime.fromMillisecondsSinceEpoch(e["time"]),["mm","/","dd"," ","HH",":","nn"]), textAlign: TextAlign.center, style: style),
                ),
              ),
              Expanded(
                flex: 10,
                child: Center(
                  child: Text(e["trade_type"], textAlign: TextAlign.center, style: style),
                ),
              ),
              Expanded(
                flex: 10,
                child: Center(
                  child: Text(e["terminal"], textAlign: TextAlign.center, style: style),
                ),
              ),
              Expanded(
                flex: 7,
                child: Center(
                  child: Text((e["type"]=="0"? "-":"+")+ "￥" + e["amount"].toString(), style: style),
                ),
              ),
            ],
          ),
        )).toList()),
      ),
    );
  }
}

class TradeDetailPage extends StatefulWidget {

  @override
  _TradeDetailPageState createState() => _TradeDetailPageState();

}

class _TradeDetailPageState extends State<TradeDetailPage> {

  List<Map<String,dynamic>> trades =[];
  Map<String,num> summary = {};

  DateTime start;
  DateTime end;

  bool isLoading = false;
  bool isInit = true;
  bool error = false;

  loadData() async {

    error = true;

    setState(() {
      isLoading = true;
    });

    var respData = await queryCardTrade(start, end);
    if (respData != null) {
      setState(() {
        error = false;
        isLoading = false;
        trades = List<Map<String,dynamic>>.from(respData["trade"]);
      });
    } else {
      setState(() {
        isLoading = false;
        error = true;
      });
    }



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("历史交易查询"),
      ),
      backgroundColor: ThemeRegular.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(ThemeRegular.cardMargin),
              padding: EdgeInsets.fromLTRB(8, 15, 8, 15),
              decoration: BoxDecoration(
                color: ThemeRegular.cardBackgroundColor,
                borderRadius: ThemeRegular.cardRadius,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: GestureDetector(
                      onTap: () {
                        DatePicker.showDatePicker(
                            context,
                            locale: LocaleType.zh,
                            maxTime: DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch-24*3600000),
                            minTime: DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch-24*3600000*365*4),
                            onConfirm: (t) {
                              setState(() {
                                start = t;
                                if (end!=null && start.millisecondsSinceEpoch > end.millisecondsSinceEpoch) {
                                  end = null;
                                }
                              });
                            }
                        );
                      },
                      child: Center(
                        child: Text(start == null? "请选择开始时间" : formatDate(start, ["yyyy","年","m", "月", "d","日"]), style: TextStyle(
                          fontSize: 14,
                          color: ThemeRegular.themeTextColor,
                        )),
                      ),
                    ) ,
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text("~"),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: GestureDetector(
                      onTap: () {
                        if (start == null) {
                          Fluttertoast.showToast(
                            msg: "请先选择开始时间",
                            backgroundColor: ThemeRegular.backgroundColor,
                            textColor: ThemeRegular.textColor,
                          );
                          return;
                        }
                        DatePicker.showDatePicker(
                          context,
                          locale: LocaleType.zh,
                          maxTime: DateTime.now(),
                          minTime: start,
                          onConfirm: (t) {
                            setState(() {
                              end = t;
                            });
                          }
                        );
                      },
                      child: Center(
                        child: Text(end == null? "请选择结束时间" : formatDate(end, ["yyyy","年","m", "月", "d","日"]),  style: TextStyle(
                          fontSize: 14,
                          color: ThemeRegular.themeTextColor,
                        )),
                      ),
                    ) ,
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10, 2, 10, 2),
                      child: SizedBox(
                        height: 26,
                        child: RaisedButton(
                          onPressed: start != null && end != null && isLoading == false? () {
                            setState(() {
                              isInit = false;
                              isLoading = true;
                            });

                            loadData();

                          } : null,
                          elevation: 0,
                          color: ThemeRegular.backgroundColor,
                          disabledColor: ThemeRegular.backgroundColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(13))
                          ),
                          child: Text("查询", style: TextStyle(
                            fontSize: 14,
                          )),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            isInit? _InitCard(): (isLoading? Container(
              margin: EdgeInsets.all(ThemeRegular.cardMargin),
              decoration: BoxDecoration(
                color: ThemeRegular.cardBackgroundColor,
                borderRadius: ThemeRegular.cardRadius,
              ),
              padding: EdgeInsets.fromLTRB(0, 45, 0, 40),
              child: Center(
                child: Column(
                  children: [
                    Loading(
                      indicator: LineScaleIndicator(),
                      size: 50,
                      color: ThemeRegular.textColor,
                    ),
                    Container(
                      margin: EdgeInsets.all(7),
                      child: Text("加载中"),
                    )
                  ],
                ),
              )
            )  : error ? Container(
              margin: EdgeInsets.all(ThemeRegular.cardMargin),
              decoration: BoxDecoration(
                color: ThemeRegular.cardBackgroundColor,
                borderRadius: ThemeRegular.cardRadius,
              ),
              child: ErrorRefresh(onRefresh: loadData),
            ) : _DataCard(data: trades)),
          ],
        ),
      ),
    );
  }
}