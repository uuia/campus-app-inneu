
import 'package:flutter/material.dart';
import 'package:inneu/components/courseGlance.dart';
import 'package:inneu/components/indexBanner.dart';
import 'package:inneu/components/gradeCard.dart';
import 'package:inneu/components/neuNews.dart';
import 'package:inneu/event.dart';
import 'package:inneu/preloadData.dart';
import 'package:inneu/versionConfig.dart';
import 'components/cardInfo.dart';
import 'components/libraryInfo.dart';

class Index extends StatefulWidget {

  @override
  _IndexState createState() => _IndexState();

}

class _IndexState extends State<Index> {

  static bool _firstShow = true;


  _reload() {
    setState(() {});
  }

  @override
  void dispose() {
    EventBus.removeListen("login", _reload);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    EventBus.addListener("login", _reload);
    EventBus.addListener("index_change", _reload);

    if (_firstShow) {
      _firstShow = false;
      if (PreloadData.autoCheckUpdate) {
        VersionConfig.checkUpdate(null);
      }
    }

  }

  @override
  Widget build(BuildContext context) {

    List<Widget> components = [IndexBanner(
      data: PreloadData.banner,
    )];

    PreloadData.indexComponents.forEach((componentName) {
      print(componentName);
      switch (componentName) {
        case "grade":
          components.add(GradeCard());
          break;
        case "card":
          components.add(CardInfo());
          break;
        case "library":
          components.add(LibraryInfo());
          break;
        case "news":
          components.add(NEUNews());
          break;
        case "schedule":
          components.add(CourseGlance());
          break;
      }
    });

    return Container(
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: components,
        ),
      ),
    );
  }
}