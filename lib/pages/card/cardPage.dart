
import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inneu/components/errorRefresh.dart';
import 'package:inneu/pages/card/tradeDetailPage.dart';
import 'package:inneu/preloadData.dart';
import 'package:inneu/service/request.dart';
import 'package:inneu/theme.dart';
import 'package:loading/indicator/line_scale_indicator.dart';
import 'package:loading/loading.dart';

class _CardMoney extends StatefulWidget {

  _CardMoney({Key key}) : super(key: key);

  @override
  _CardMoneyState createState() => _CardMoneyState();

}

class _CardMoneyState extends State<_CardMoney> {

  String cardMoney = "0";
  String unreceivedMoney = "0";
  String subMoney = "0";
  bool isLoading = true;
  bool error = false;


  loadData() async {

    setState(() {
      isLoading = true;
    });

    var data = await queryCardMoney();
    if (data != null) {
      setState(() {
        cardMoney = ((num n) => n.toStringAsFixed(2))(data["main_fare"]);
        unreceivedMoney = ((num n) => n.toStringAsFixed(2))(data["fund_fare"]);
        subMoney = ((num n) => n.toStringAsFixed(2))(data["subsidy_fare"]);
        isLoading = false;
        error = false;
      });
    } else {
      setState(() {
        error = true;
        isLoading = false;
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
      padding: EdgeInsets.fromLTRB(10, 15, 5, 15),
      decoration: BoxDecoration(
        color: ThemeRegular.cardBackgroundColor,
        borderRadius: ThemeRegular.cardRadius,
      ),
      child: (!isLoading && error) ? ErrorRefresh(onRefresh: loadData) : Row(
        mainAxisSize: MainAxisSize.max,
        children: isLoading ? [
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                margin: EdgeInsets.all(15),
                child: Loading(
                  indicator: LineScaleIndicator(),
                  size: 50,
                  color: ThemeRegular.textColor,
                ),
              ),
            ),
          )
        ]  : [
          Expanded(
            flex: 1,
            child: Center(
              child: Image(
                height: 70,
                width: 70,
                image: AssetImage("assets/images/neu.png"),
              ),
            )
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(4),
                  child: Center(
                    child: Text("主钱包余额"),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(4),
                  child: Center(
                    child: Text("￥$cardMoney", style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ThemeRegular.themeTextColor,
                    )),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(4),
                  child: Center(
                    child: Text("未领余额"),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(4),
                  child: Center(
                    child: Text("￥$unreceivedMoney", style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ThemeRegular.themeTextColor
                    )),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(4),
                  child: Center(
                    child: Text("补助余额"),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(4),
                  child: Center(
                    child: Text("￥$subMoney", style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ThemeRegular.themeTextColor
                    )),
                  ),
                )
              ],
            ),
          ),
        ],
      )
    );
  }
}

class CardTradeHistory extends StatefulWidget {
  final DateTime start;
  final DateTime end;
  final Function() onRefresh;

  CardTradeHistory({Key key,this.start,this.end,this.onRefresh,}) : super(key: key);

  @override
  _CardTradeHistoryState createState() => _CardTradeHistoryState();

}

class _CardTradeHistoryState extends State<CardTradeHistory> {

  List<Map<String,dynamic>> data = [];
  DateTime start;
  DateTime end;
  bool isLoading = true;
  bool error = false;


  loadData() async {

    end = DateTime.now();
    start = DateTime.fromMillisecondsSinceEpoch(end.millisecondsSinceEpoch-3600000*24*3);

    setState(() {
      isLoading = true;
    });

    var respData = await queryCardTrade(start, end);
    if (respData != null) {
      setState(() {
        isLoading = false;
        data = List<Map<String,dynamic>>.from(respData["trade"]);
        error = false;
      });
    } else {
      setState(() {
        error = true;
        isLoading = false;
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

    int dataIndex = 0;

    TextStyle style = TextStyle(
      fontSize: 13,
      color: ThemeRegular.textColor
    );

    return Container(
      margin: EdgeInsets.all(ThemeRegular.cardMargin),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeRegular.cardBackgroundColor,
        borderRadius: ThemeRegular.cardRadius,
      ),
      child: isLoading? Center(
        child: Container(
          margin: EdgeInsets.all(25),
          child: Loading(
            indicator: LineScaleIndicator(),
            size: 35,
            color: ThemeRegular.textColor,
          ),
        ),
      ) : error ? ErrorRefresh(onRefresh: loadData) : (data.length == 0? Center(
        child: Container(
          margin: EdgeInsets.all(5),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  if(widget.onRefresh != null) {
                    widget.onRefresh();
                  }
                  loadData();
                },
                child: Container(
                  margin: EdgeInsets.all(5),
                  child: Icon(Icons.refresh,color: ThemeRegular.themeTextColor, size: 35),
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                child: Text("今日还没有任何交易", style: TextStyle(
                  color: ThemeRegular.textColor,
                  fontSize: 15
                ),),
              )
            ],
          ),
        ),
      ) : Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(5, 2, 5, 8),
            child: Row(
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
            ),
          )
        ]..addAll(data.map((e) => Container(
          margin: EdgeInsets.fromLTRB(5, 2, 5, 2),
          padding: EdgeInsets.all(5),
          color: (dataIndex++)%2==0?ThemeRegular.backgroundColor:ThemeRegular.cardBackgroundColor,
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
        )).toList())
        ..add(Container(
          margin: EdgeInsets.fromLTRB(0, 7, 0, 0),
          child: Center(
            child: Text("以上为三日内交易记录", style: TextStyle(
              fontSize: 13,
              color: ThemeRegular.lightColor,
            )),
          ),
        )),
      )),
    );
  }
}

GlobalKey<_CardTradeHistoryState> _cardTradeHistoryKey = GlobalKey<_CardTradeHistoryState>();
GlobalKey<_CardMoneyState> _cardMoneyKey = GlobalKey<_CardMoneyState>();


class CardPage extends StatelessWidget {

  _openCardWeb(BuildContext context) async {
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

    var cookieStr = await getSSOCookie();

    if (cookieStr == null) {
      Navigator.of(context).pop();
      Fluttertoast.showToast(
          msg: "加载错误",
          textColor: ThemeRegular.textColor,
          backgroundColor: ThemeRegular.cardBackgroundColor
      );
      return;
    }

    PreloadData.method.invokeMethod("set_cookie", json.encode(cookieStr.split(";").map((e) => {
      "cookie": e.trim(),
      "domain": "pass.neu.edu.cn"
    }).toList()));

    await Future.delayed(Duration(milliseconds: 150));
    Navigator.of(context).pop();
    PreloadData.method.invokeMethod("open", json.encode({
      "url": "https://hub.17wanxiao.com/cas-dongbei/cas/cjgy/light.action?flag=dongbei_dongbeidaxue&ecardFunc=index",
      "title": " 校园卡"
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("校园卡"),
      ),
      backgroundColor: ThemeRegular.backgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          Future a = _cardMoneyKey.currentState.loadData();
          Future b = _cardTradeHistoryKey.currentState.loadData();
          // await a;
          // await b;
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _CardMoney(
                key: _cardMoneyKey,
              ),
              Container(
                margin: EdgeInsets.all(ThemeRegular.cardMargin),
                decoration: BoxDecoration(
                  color: ThemeRegular.cardBackgroundColor,
                  borderRadius: ThemeRegular.cardRadius,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(15, 8, 15, 8),
                        child: RaisedButton(
                          elevation: 0,
                          color: ThemeRegular.backgroundColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8))
                          ),
                          onPressed: () {
                            _openCardWeb(context);
                          },
                          child: Text("进入校园卡首页"),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(15, 8, 15, 8),
                        child: RaisedButton(
                          elevation: 0,
                          color: ThemeRegular.backgroundColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8))
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => TradeDetailPage() )
                            );
                          },
                          child: Text("历史交易查询"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CardTradeHistory(
                key: _cardTradeHistoryKey,
                onRefresh: () {
                  _cardMoneyKey.currentState.loadData();
                },
              )
            ],
          ),
        ),
      )
    );
  }
}