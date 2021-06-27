
import 'package:flutter/material.dart';
import 'package:inneu/components/errorRefresh.dart';
import 'package:inneu/components/iconTitle.dart';
import 'package:inneu/pages/card/cardPage.dart';
import 'package:inneu/service/request.dart';
import 'package:inneu/theme.dart';

class CardInfo extends StatefulWidget {

  CardInfo({Key key}) : super(key: key);

  @override
  CardInfoState createState() => CardInfoState();

}

class CardInfoState extends State<CardInfo> {

  String balance = "-.-";
  String netBalance = "-.-";
  String sumBytes = "-.-";
  bool error = false;
  Color blue = Color.fromARGB(255, 0, 129, 255);

  loadData() async {

    setState(() {
      error = false;
    });

    var data = await queryPortalInfo();
    if (data == null) {
      setState(() {
        error = true;
      });
    } else {
      String balanceStr = data["card_status"]["card_balance"];
      num netBalanceNum = data["net_status"]["user_balance"];
      String netUserBytes = data["net_status"]["sum_bytes"];
      double.parse(netUserBytes);
      setState(() {
        error = false;
        balance = (double.parse(balanceStr)/100).toStringAsFixed(2);
        netBalance = netBalanceNum.toStringAsFixed(2);
        sumBytes = (double.parse(netUserBytes)/1024/1024).toStringAsFixed(2);
      });

      // 偶尔可能会加载错误
      if (balanceStr == "-1") {
        setState(() {
          balance = "-";
        });
        await Future.delayed(Duration(milliseconds: 600));
        loadData();
      }

    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CardPage())
        );
      },
      child: Container(
        margin: EdgeInsets.all(ThemeRegular.cardMargin),
        decoration: BoxDecoration(
            borderRadius: ThemeRegular.cardRadius,
            color: ThemeRegular.cardBackgroundColor
        ),
        child: error? ErrorRefresh(
          onRefresh: loadData,
        ) : Center(
            child: Column(
              children: <Widget>[
                IconTitle(
                    icon: Icons.credit_card,
                    title: "校园钱包"
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 50),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            child: Text("￥"),
                            padding: EdgeInsets.all(2),
                            margin: EdgeInsets.all(10),
                          ),
                          Container(
                            child: Text(balance, style: TextStyle(
                                fontSize: 50
                            )),
                            margin: EdgeInsets.fromLTRB(4, 0, 25, 0),
                          )
                        ],
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: Icon(Icons.credit_card, size: 12, color: ThemeRegular.lightColor),
                              margin: EdgeInsets.fromLTRB(0, 3, 5, 0),
                            ),
                            Text("校园卡主钱包余额", style: TextStyle(
                                color: ThemeRegular.lightColor,
                                fontSize: 12
                            ))
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: Icon(Icons.wifi, size: 12, color: ThemeRegular.lightColor),
                              margin: EdgeInsets.fromLTRB(1, 2, 2, 0),
                            ),
                            Text("校园网余额", style: TextStyle(
                                color: ThemeRegular.lightColor,
                                fontSize: 12
                            )),
                            Container(
                              margin: EdgeInsets.fromLTRB(4, 2, 2, 0),
                              child: Text(
                                "￥$netBalance",
                                style: TextStyle(
                                    color: ThemeRegular.themeTextColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: Icon(Icons.assessment, size: 12, color: ThemeRegular.lightColor),
                              margin: EdgeInsets.fromLTRB(1, 2, 2, 0),
                            ),
                            Text("已用流量", style: TextStyle(
                                color: ThemeRegular.lightColor,
                                fontSize: 12
                            )),
                            Container(
                              margin: EdgeInsets.fromLTRB(4, 2, 2, 0),
                              child: Text(
                                "${sumBytes}MB",
                                style: TextStyle(
                                    color: ThemeRegular.themeTextColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                ),
              ],
            )
        ),
      ),
    );
  }

}