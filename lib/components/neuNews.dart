import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inneu/components/iconTitle.dart';
import 'package:inneu/components/titleLine.dart';
import 'package:inneu/service/request.dart';
import 'package:inneu/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../preloadData.dart';

class NEUNews extends StatefulWidget {

  @override
  _NEUNewsState createState() => _NEUNewsState();

}

class _NEUNewsState extends State<NEUNews> {

  List<Map<String,dynamic>> _data = [
    {
      "name": "教育部召开视频会议部署秋季学期开学和秋冬季疫情防控工作",
      "url": "https://neunews.neu.edu.cn/2020/0901/c189a69841/pagem.htm"
    },
    {
      "name": "东北大学低碳钢铁前沿技术研究院成立",
      "url": "https://neunews.neu.edu.cn/2020/0828/c189a69823/pagem.htm"
    }
  ];

  bool _showAll = false;

  static RegExp _regExp = RegExp("<span class='Article_Title'><a href='(.*?)' target='_blank' title='(.*?)'>(.*?)<\/a><\/span");

  _loadData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.getString("news") != null) {
      setState(() {
        _data = List<Map<String,dynamic>>.from(json.decode(preferences.getString("news")));
      });
    }

    var text = await getNetData("https://neunews.neu.edu.cn/ddyw/listm1.htm");
    setState(() {
      _data = _regExp.allMatches(text).map((e) => {
        "url": "https://neunews.neu.edu.cn"+e.group(1),
        "name": e.group(2)
      }).toList();
    });


    preferences.setString("news", json.encode(_data));

  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(ThemeRegular.cardMargin),
      padding: EdgeInsets.fromLTRB(2, 5, 2, 8),
      decoration: BoxDecoration(
        color: ThemeRegular.cardBackgroundColor,
        borderRadius: ThemeRegular.cardRadius
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTitle(
            icon: Icons.format_align_left,
            title: "东大要闻",
          )
        ]..addAll((_data.length > 8 && !_showAll? _data.sublist(0,8) : _data).map((e) => Container(
          margin: EdgeInsets.fromLTRB(15, 6, 15, 6),
          child: GestureDetector(
            onTap: () {
              print(e["url"]);
              PreloadData.method.invokeListMethod("open", "${e["name"]}#!!${e["url"]}");
            },
            child: Text(e["name"], style: TextStyle(
              fontSize: 14,
              decoration: TextDecoration.underline,
              color: ThemeRegular.deepColor,
            )),
          ),
        )).toList())
        ..add(Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showAll = !_showAll;
                  });
                },
                child: Text(_data.length > 8 && !_showAll? "查看更多" : "收起", style: TextStyle(
                  fontSize: 15,
                  color: ThemeRegular.themeTextColor
                )),
              )
            ],
          ),
        )),
      ),
    );
  }
}