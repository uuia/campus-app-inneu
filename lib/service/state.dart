
import 'dart:convert';

import 'package:inneu/preloadData.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<int> getCurrentGradeSemester() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String semesterName = prefs.getString("grade_semester");
  if (semesterName == null || semesterName == "") {
    return 31;
  }
  return PreloadData.semesterMap[semesterName];
}

Future<int> getCurrentExamSemester() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String semesterName = prefs.getString("exam_semester");
  if (semesterName == null || semesterName == "") {
    return 31;
  }
  return PreloadData.semesterMap[semesterName];
}

Future<Map<String,int>> getSemesterList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var data = prefs.getString("semester_cache");
  if (data == null || data == "") {
    return {
      "2022-2023学年春季学期": 60,
      "2022-2023学年秋季学期": 59,
      "2021-2022学年夏季学期": 58,
      "2021-2022学年春季学期": 57,
      "2021-2022学年秋季学期": 56,
      "2020-2021学年夏季学期": 55,
      "2020-2021学年春季学期": 48,
      "2020-2021学年秋季学期": 47,
      "2019-2020学年夏季学期": 54,
      "2019-2020学年春季学期": 31,
      "2019-2020学年秋季学期": 12,
      "2018-2019学年夏季学期": 49,
      "2018-2019学年春季学期": 30,
      "2018-2019学年秋季学期": 11,
      "2017-2018学年第二学期": 29,
      "2017-2018学年第一学期": 10,
      "2016-2017学年第二学期": 28,
      "2016-2017学年第一学期": 9,
      "2015-2016学年第二学期": 27,
      "2015-2016学年第一学期": 8,
    };
  }
  return Map<String,int>.from(json.decode(data));
}

