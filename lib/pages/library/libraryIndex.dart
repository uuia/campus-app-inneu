import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inneu/components/errorRefresh.dart';
import 'package:inneu/components/titleLine.dart';
import 'package:inneu/pages/library/librarySearch.dart';
import 'package:inneu/preloadData.dart';
import 'package:inneu/service/request.dart';
import 'package:inneu/theme.dart';
import 'package:loading/indicator/line_scale_indicator.dart';
import 'package:loading/loading.dart';

_parseTime(String date) {
  var time = DateTime.parse(date);
  var now = DateTime.now();
  var deltaTime = time.millisecondsSinceEpoch - now.millisecondsSinceEpoch;
  bool isToday = now.year == time.year && now.month == time.month && now.day == time.day;
  return Row(
    children: <Widget>[
      isToday? Text("今日归还", style: TextStyle(
        fontSize: 13,
        color: Colors.red,
        fontFamily: "SourceHanSans",
      )) : (deltaTime > 0 ? 
        Text("还剩${(deltaTime/(3600000*24)).floor()}天",style: TextStyle(
          fontSize: 13,
        )) : 
        Text("已逾期", style: TextStyle(
          fontSize: 13,
          color: Colors.red
        ))  
      ) ,
      Text(" ${time.year}/${time.month}/${time.day}应还", style: TextStyle(
        fontSize: 13,
      ))
    ],
  );
}

class _LibraryPageCard extends StatelessWidget {

  final ImageProvider<dynamic> bg;
  final ImageProvider<dynamic> icon;
  final String text;
  final Function() onPressed;

  _LibraryPageCard({this.bg,this.icon,this.onPressed,this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.all(ThemeRegular.cardMargin),
        decoration: BoxDecoration(
            borderRadius: ThemeRegular.cardRadius,
            image: DecorationImage(
              image: bg,
              fit: BoxFit.fitHeight,
            )
        ),
        child: Center(
          child: Container(
            height: 80,
            width: 80,
            margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
            decoration: BoxDecoration(
              color: ThemeRegular.cardBackgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                  height: 35,
                  width: 35,
                  image: icon,
                ),
                Text(text, style: TextStyle(
                  color: ThemeRegular.textColor,
                  fontSize: 13,
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LibraryBorrowCard extends StatefulWidget {

  @override
  _LibraryBorrowCardState createState() => _LibraryBorrowCardState();

}

class _LibraryBorrowCardState extends State<_LibraryBorrowCard> {

  bool isLoading;
  List<Map<String,dynamic>> current;
  List<Map<String,dynamic>> history;

  bool showCurrentDetail;
  bool showHistoryDetail;
  bool error = false;
  
  loadData() async {

    setState(() {
      isLoading = true;
    });

    var _data = await queryLibraryBorrow();
    if (_data == null) {
      setState(() {
        error = true;
        isLoading = false;
      });
    } else {
      setState(() {
        error = false;
        isLoading = false;
        current = List<Map<String,dynamic>>.from(_data["current"]);
        history = List<Map<String,dynamic>>.from(_data["history"]);
      });
    }

  }
  
  @override
  void initState() {
    isLoading = true;
    showCurrentDetail = false;
    showHistoryDetail = false;
    super.initState();
    if (PreloadData.isLogin) {
      loadData();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return PreloadData.isLogin ? (isLoading? Container(
      margin: EdgeInsets.all(ThemeRegular.cardMargin),
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: ThemeRegular.cardBackgroundColor,
        borderRadius: ThemeRegular.cardRadius,
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Loading(
              size: 44,
              indicator: LineScaleIndicator(),
              color: ThemeRegular.textColor,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 8, 0, 5),
              child: Text("正在加载您的借阅记录"),
            )
          ],
        ),
      ),
    ) :  error ? Container(
      margin: EdgeInsets.all(ThemeRegular.cardMargin),
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: ThemeRegular.cardBackgroundColor,
        borderRadius: ThemeRegular.cardRadius,
      ),
      child: ErrorRefresh(onRefresh: loadData),
    ) : Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            setState(() {
              showCurrentDetail = !showCurrentDetail;
            });
          },
          child: Container(
            margin: EdgeInsets.all(ThemeRegular.cardMargin),
            padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: ThemeRegular.cardBackgroundColor,
              borderRadius: ThemeRegular.cardRadius,
            ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("待还", style: TextStyle(
                      fontSize: 16,
                      color: ThemeRegular.textColor,
                    )),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        Text(current.length.toString(), style: TextStyle(
                          fontSize: 28,
                          color: ThemeRegular.themeTextColor,
                        )),
                        Text("本", style: TextStyle(
                          fontSize: 10,
                          color: ThemeRegular.textColor
                        ))
                      ],
                    )
                  ],
                ),
                showCurrentDetail ? Container(
                  child: Column(
                    children: current.map((e) => Container(
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Text(e["book_name"], style: TextStyle(
                                fontSize: 13
                            )),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[_parseTime(e["back_day"])],
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ) : Container(),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              showHistoryDetail = !showHistoryDetail;
            });
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(ThemeRegular.cardMargin, 0, ThemeRegular.cardMargin, ThemeRegular.cardMargin),
            padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: ThemeRegular.cardBackgroundColor,
              borderRadius: ThemeRegular.cardRadius,
            ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("历史", style: TextStyle(
                      fontSize: 16,
                      color: ThemeRegular.textColor,
                    )),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        Text(history.length.toString(), style: TextStyle(
                          fontSize: 28,
                          color: ThemeRegular.themeTextColor,
                        )),
                        Text("本", style: TextStyle(
                            fontSize: 10,
                            color: ThemeRegular.textColor
                        ))
                      ],
                    )
                  ],
                ),
                showHistoryDetail ? Container(
                  child: Column(
                    children: history.map((e) => Container(
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.fromLTRB(3, 0, 0, 5),
                            child: Row(
                              children: <Widget>[Text(e["book_name"], style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500
                              ))],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.all(3),
                                      padding: EdgeInsets.fromLTRB(5, 1, 5, 3),
                                      height: 18,
                                      width: 52,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(2)),
                                        color: ThemeRegular.backgroundColor,
                                      ),
                                      child: Center(
                                        child: Text("作者", style: TextStyle(
                                            fontSize: 10
                                        )),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Text(e["author"], style: TextStyle(
                                      fontSize: 10
                                  ))
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.all(3),
                                        padding: EdgeInsets.fromLTRB(5, 1, 5, 3),
                                        height: 18,
                                        width: 52,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(2)),
                                          color: ThemeRegular.backgroundColor,
                                        ),
                                        child: Center(
                                          child: Text("出版时间", style: TextStyle(
                                              fontSize: 10
                                          )),
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Text(e["publish_year"], style: TextStyle(
                                      fontSize: 10
                                  ))
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.all(3),
                                      padding: EdgeInsets.fromLTRB(5, 1, 5, 3),
                                      height: 18,
                                      width: 52,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(2)),
                                        color: ThemeRegular.backgroundColor,
                                      ),
                                      child: Center(
                                        child: Text("归还时间", style: TextStyle(
                                            fontSize: 10
                                        )),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(e["actual_back_time"], style: TextStyle(
                                    fontSize: 10
                                ))
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.all(3),
                                      padding: EdgeInsets.fromLTRB(5, 1, 5, 3),
                                      height: 18,
                                      width: 52,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(2)),
                                        color: ThemeRegular.backgroundColor,
                                      ),
                                      child: Center(
                                        child: Text("限还时间", style: TextStyle(
                                            fontSize: 10
                                        )),
                                      ),
                                    ),
                                  ],
                                )
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Text(e["should_back_time"], style: TextStyle(
                                      fontSize: 10
                                  ))
                              )
                            ],
                          ),
                          history.indexOf(e) == history.length - 1? Container():Container(
                            height: 1,
                            margin: EdgeInsets.fromLTRB(0, 6, 0, 0),
                            color: ThemeRegular.backgroundColor,
                            child: Row(mainAxisSize: MainAxisSize.max),
                          )
                        ],
                      )
                    )).toList(),
                  ),
                ) : Container(),
              ],
            ),
          ),
        ),
      ],
    )) : Container(width: 0,height: 0);
  }
}

class LibraryIndexPage extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("图书馆"),
      ),
      backgroundColor: ThemeRegular.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _LibraryBorrowCard(),
            _LibraryPageCard(
              bg: AssetImage("assets/images/search_bg.png"),
              icon: AssetImage("assets/images/search.png"),
              text: "搜索",
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LibrarySearchPage())
                );
              },
            ),
            _LibraryPageCard(
              bg: AssetImage("assets/images/navigator_bg.png"),
              icon: AssetImage("assets/images/navigator.png"),
              text: "导航",
              onPressed: (){
                PreloadData.method.invokeMethod("open", json.encode({
                  "title": "图书馆导航",
                  "url": "https://img-pool.neuyan.com/library-nav.html"
                }));
              },
            ),
          ]..addAll(PreloadData.isLogin? [
            TitleLine(
              title: "说明",
              eng: "Notes",
            ),
            Container(
              margin: EdgeInsets.all(15),
              child: Text(
                "「以上数据来自哪里」图书借阅数据来自东北大学图书馆，点击即可展开详情，记录仅供参考，实际以图书馆显示为准",
                style: TextStyle(
                  color: ThemeRegular.textColor,
                  fontSize: 12,
                ),
              ),
            ),
          ] : []),
        ),
      ),
    );
  }
}