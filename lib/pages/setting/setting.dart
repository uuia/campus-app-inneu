import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:inneu/components/menuItems.dart';
import 'package:inneu/preloadData.dart';
import 'package:inneu/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../event.dart';

class _ComponentItem extends StatefulWidget {

  final bool inList;
  final Function(bool, String) onChange;
  final String componentName;

  _ComponentItem({this.inList,this.onChange,this.componentName});

  @override
  _ComponentItemState createState() => _ComponentItemState();

}

class _ComponentItemState extends State<_ComponentItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChange(!widget.inList, widget.componentName);
      },
      child: Container(
        height: 30,
        width: 120,
        decoration: BoxDecoration(
            color: ThemeRegular.backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(15))
        ),
        child: Stack(
          children: [
            Positioned(
              left: 10,
              top: 0,
              child: Container(
                height: 30,
                width: 80,
                child: Center(
                  child: Text(PreloadData.homeComponentsName[widget.componentName]),
                ),
              ),
            ),
            Positioned(
              right: 3,
              top: 3,
              child: Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                    color: ThemeRegular.cardBackgroundColor,
                    borderRadius: BorderRadius.all(Radius.circular(12))
                ),
                child: Center(
                  child: Icon(widget.inList? Icons.remove : Icons.add, size: 18,),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _IndexItemSelector extends StatefulWidget {

  final List<String> using;
  final List<String> unused;

  _IndexItemSelector({this.unused,this.using});

  @override
  _IndexItemSelectorState createState() => _IndexItemSelectorState();

}

class _IndexItemSelectorState extends State<_IndexItemSelector> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
            child: Text("已选择", style: TextStyle(
              fontSize: 16
            )),
          ),
          widget.using.length == 0? Text("没有已选择的组件", style: TextStyle(
            fontSize: 12,
            color: ThemeRegular.textColor
          )) : Wrap(
            spacing: 30,
            children: widget.using.map((e) => Container(
              margin: EdgeInsets.all(5),
              child: _ComponentItem(
                inList: true,
                componentName: e,
                onChange: (nextState, name) {
                  setState(() {
                    widget.using.remove(name);
                    widget.unused.add(name);
                  });
                },
              ),
            )).toList(),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
            child: Text("未选择", style: TextStyle(
                fontSize: 16
            )),
          ),
          widget.unused.length == 0? Text("没有可选择的组件", style: TextStyle(
            fontSize: 12,
            color: ThemeRegular.textColor
          )) : Wrap(
            spacing: 30,
            children: widget.unused.map((e) => Container(
              margin: EdgeInsets.all(5),
              child: _ComponentItem(
                inList: false,
                componentName: e,
                onChange: (nextState, name) {
                  setState(() {
                    widget.using.add(name);
                    widget.unused.remove(name);
                  });
                },
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class AppSetting extends StatefulWidget {

  @override
  _AppSettingState createState() => _AppSettingState();

}

class _AppSettingState extends State<AppSetting> {

  List<String> semesters = PreloadData.semesterMap.keys.toList();

  _showLoading() {
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
  }

  _cancelLoading() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  _reloadSchedule() async {

    _showLoading();
    await PreloadData.loadSchedule(null);
    _cancelLoading();

  }

  _showSemesterSelector(Function(String,int) onConfirmCallback) {
    Picker(
      adapter: PickerDataAdapter(
        data: semesters.map((k) => PickerItem(
          text: Text(k)
        )).toList()
      ),
      confirmText: "确认",
      cancelText: "取消",
      onConfirm: (Picker picker,List value) {
        String semesterName = semesters[value[0]];
        onConfirmCallback(semesterName, PreloadData.semesterMap[semesterName]);
      }
    ).showModal(context);
  }

  _showIndexItemSelector() {

    Set<String> allowSet = {"news"};
    if (PreloadData.isLogin) {
      allowSet.addAll(["card", "grade", "schedule", "library"]);
    }
    List<String> usingComponents = [];
    List<String> unusedComponents = [];
    PreloadData.indexComponents.forEach((element) {
      usingComponents.add(element);
      allowSet.remove(element);
    });
    allowSet.forEach((element) {
      unusedComponents.add(element);
    });

    showModalBottomSheet(

      context: context,
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  PreloadData.indexComponents = usingComponents;
                  prefs.setStringList("index_components", usingComponents);
                  Navigator.pop(context);
                  EventBus.emitEvent("index_change");
                },
                child: Text("确定"),
              )
            ],
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: _IndexItemSelector(
              unused: unusedComponents,
              using: usingComponents,
            ),
          ),
          Container(
            margin: EdgeInsets.all(5),
            child: Text("首页组件将按照顺序展示", style: TextStyle(
              fontSize: 12,
              color: ThemeRegular.textColor
            )),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设置"),
      ),
      backgroundColor: ThemeRegular.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            MenuItems(
              data: [
                MenuItem(
                    icon: Icon(Icons.update),
                    name: "启动时自动检测更新",
                    right: Switch(
                      value: PreloadData.autoCheckUpdate,
                      onChanged: (value) async {
                        setState(() {
                          PreloadData.autoCheckUpdate = value;
                        });

                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setBool("auto_check_update", value);

                      },
                    ),
                    onTap: () {}
                ),
                MenuItem(
                    icon: Icon(Icons.sync),
                    name: "自动同步学期",
                    right: Switch(
                      value: PreloadData.autoSyncSemester,
                      onChanged: (value) async {

                        setState(() {
                          PreloadData.autoSyncSemester = value;
                        });

                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setBool("auto_async_semesters", value);

                        if (value) {
                          _showLoading();
                          await PreloadData.loadSemesters(null);
                          _cancelLoading();
                          setState(() {});
                        }

                      },
                    ),
                    onTap: () {}
                ),
              ],
            ),
            MenuItems(
              data: [
                MenuItem(
                  icon: Icon(Icons.schedule),
                  name: "课程表学期",
                  right: Text(PreloadData.scheduleSemesterName, style: TextStyle(
                    fontSize: 12,
                    color: ThemeRegular.textColor
                  )),
                  onTap: () {

                    _showSemesterSelector((semesterName, semesterId) {
                      setState(() {
                        PreloadData.autoSyncSemester = false;
                        PreloadData.scheduleSemesterId = semesterId;
                        PreloadData.scheduleSemesterName = semesterName;
                      });
                    });

                    _reloadSchedule();

                  }
                ),
                MenuItem(
                    icon: Icon(Icons.speaker_notes),
                    name: "考试日程默认学期",
                    right: Text(PreloadData.examSemesterName, style: TextStyle(
                        fontSize: 12,
                        color: ThemeRegular.textColor
                    )),
                    onTap: () {
                      _showSemesterSelector((semesterName, semesterId) {
                        setState(() {
                          PreloadData.autoSyncSemester = false;
                          PreloadData.examSemesterId = semesterId;
                          PreloadData.examSemesterName = semesterName;
                        });
                      });
                    }
                ),
              ]..addAll(PreloadData.isLogin? [
                MenuItem(
                    icon: Icon(Icons.grade),
                    name: "成绩查询默认学期",
                    right: Text(PreloadData.gradeSemesterName, style: TextStyle(
                        fontSize: 12,
                        color: ThemeRegular.textColor
                    )),
                    onTap: () {
                      _showSemesterSelector((semesterName, semesterId) {
                        setState(() {
                          PreloadData.gradeSemesterId = semesterId;
                          PreloadData.gradeSemesterName = semesterName;
                        });
                      });
                    }
                ),
              ] : [])..add(
                MenuItem(
                  name: "首页组件",
                  icon: Icon(Icons.home),
                  onTap: _showIndexItemSelector
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}