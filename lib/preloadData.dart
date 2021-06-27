
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:inneu/pages/schedule/schedulePage.dart';
import 'package:inneu/service/state.dart';
import 'package:inneu/service/request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreloadData {

  static const method = const MethodChannel("com.neuyan.inneu/native");

  static bool isLogin = false;
  static bool autoCheckUpdate = false;
  static bool autoSyncSemester = true;
  static bool isHoliday = true;
  static int examSemesterId = 31;
  static String examSemesterName = "2019-2020学年春季学期";
  static int scheduleSemesterId = 31;
  static String scheduleSemesterName = "2019-2020学年春季学期";
  static int gradeSemesterId = 31;
  static String gradeSemesterName = "2019-2020学年春季学期";
  static int currentSemesterId = 31;
  static bool netError = false;

  static String session = "";
  static String userType;

  // 首页组件
  static List<String> indexComponents = ["news"];
  // 生活在东大
  static List<Map<String,dynamic>> lifeFunctions = [];
  // 学习在东大
  static List<Map<String,dynamic>> studyFunctions = [];
  static final Map<String,String> homeComponentsName = {
    "card": "校园卡",
    "grade": "学期成绩",
    "library": "图书借阅",
    "news": "东大要闻",
    "schedule": "课程速览",
    "exam": "考试倒计时"
  };

  static List<Map<String,dynamic>> banner = [
    {"comment":"成绩查询","url":"https://img-pool.zxysy.net/grade_query.png", "nav":"/grade", "need_login": true},
  ];

  static Map<int,int> maxWeekMap = {
    60: 18, 59: 18, 58: 5, 57: 18, 56: 18, 55: 5, 48: 18,
    47: 18, 54: 5, 31: 18, 12: 18, 49: 5, 30: 18,
    11: 18, 29: 18
  };
  static Map<int,DateTime> semesterStartMap = {
    48: DateTime(2021, 2, 28),
    47: DateTime(2020, 9, 6),
    54: DateTime(2020, 6, 28),
    31: DateTime(2020, 2, 23),
    12: DateTime(2019, 9, 8),
  };
  static Map<String,int> semesterMap = {
//    "2022-2023学年春季学期": 60,
//    "2022-2023学年秋季学期": 59,
//    "2021-2022学年夏季学期": 58,
//    "2021-2022学年春季学期": 57,
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
  // 全局课程表
  static List<CourseItem> scheduleCourses = [];
  // 用户信息
  static Map<String,dynamic> userInfo = {};

  static Map<String,String> setting = {
//    "cardIndex": "http://hub.17wanxiao.com/cas-dongbei/cas/cjgy/light.action?flag=dongbei_dongbeidaxue&amp;ecardFunc=index",
    "cardIndex": "http://ecard.neu.edu.cn/selflogin/login.aspx",
  };

  static saveSchedule(SharedPreferences prefs) async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }

    List<Map<String,dynamic>> courseJsonObj = [];
    scheduleCourses.forEach((element) {
      courseJsonObj.add({
        "course_code": element.courseCode,
        "course_name": element.courseName,
        "weeks": element.weeks,
        "teachers": element.teachers,
        "section": element.section,
        "day": element.day,
        "len": element.len,
        "classroom": element.classroom,
      });
    });

    prefs.setString("courses_cache_$scheduleSemesterId", json.encode(courseJsonObj));

    method.invokeMethod("save_schedule", json.encode({
      "courses": scheduleCourses.map((element) => {
        "course_code": element.courseCode,
        "course_name": element.courseName,
        "weeks": element.weeks,
        "teachers": element.teachers,
        "section": element.section,
        "day": element.day,
        "len": element.len,
        "classroom": element.classroom,
      }).toList(),
      "start": semesterStartMap[scheduleSemesterId].millisecondsSinceEpoch
    }));

  }

  static loadSchedule(SharedPreferences prefs) async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }

    scheduleCourses = [];

    if (PreloadData.userType == "postgraduate") {
      return;
    }

    String courseCache = prefs.getString("courses_cache_$scheduleSemesterId");
    print("cache: $courseCache");
    if (courseCache == null || courseCache == "" || courseCache == "[]") {

      if (!PreloadData.isLogin) {
        return;
      }

      List<CourseItem> courses;
      try {
        courses = await querySchedule(scheduleSemesterId);
        if (courses == null) {
          throw Exception("course null");
        }
        List<Map<String,dynamic>> courseJsonObj = [];
        courses.forEach((element) {
          courseJsonObj.add({
            "course_code": element.courseCode,
            "course_name": element.courseName,
            "weeks": element.weeks,
            "teachers": element.teachers,
            "section": element.section,
            "day": element.day,
            "len": element.len,
            "classroom": element.classroom,
          });
        });

        prefs.setString("courses_cache_$scheduleSemesterId", json.encode(courseJsonObj));

      } catch (e,stack) {
        print(e);
        print(stack);
        courses = [];
      }
      courses.forEach((element) {
        scheduleCourses.add(element);
      });

    } else {
      List<dynamic> courseCacheObj = json.decode(courseCache);
      courseCacheObj.forEach((element) {
        scheduleCourses.add(CourseItem(
          courseCode: element["course_code"],
          classroom: element["classroom"],
          courseName: element["course_name"],
          teachers: List<String>.from(element["teachers"]),
          section: element["section"],
          len: element["len"],
          day: element["day"],
          weeks: List<int>.from(element["weeks"]),
        ));
      });
    }

    // 传递给native用于桌面组件
    method.invokeMethod("save_schedule", json.encode({
      "courses": scheduleCourses.map((element) => {
        "course_code": element.courseCode,
        "course_name": element.courseName,
        "weeks": element.weeks,
        "teachers": element.teachers,
        "section": element.section,
        "day": element.day,
        "len": element.len,
        "classroom": element.classroom,
      }).toList(),
      "start": semesterStartMap[scheduleSemesterId].millisecondsSinceEpoch
    }));

  }

  static _loadSemesterFromStorage(SharedPreferences prefs) async {
    var semesterList = await getSemesterList();

    // 获取考试默认学期
    String _examSemesterName = prefs.getString("exam_semester");
    if(_examSemesterName != "" && _examSemesterName != null) {
      examSemesterName = _examSemesterName;
      examSemesterId = semesterList[examSemesterName];
    }

    // 加载学期最大周Map
    String _maxWeekMap = prefs.getString("max_week");
    if (_maxWeekMap != null && _maxWeekMap != "") {
      maxWeekMap = Map<int,int>.from(json.decode(_maxWeekMap));
    }

    // 加载学期开始时间
    String _semesterStart = prefs.getString(("semester_start"));
    if (_semesterStart != null && _semesterStart != "") {
      Map<int,int> map = json.decode(_semesterStart);
      semesterStartMap = map.map((key, value) => MapEntry(key, DateTime.fromMillisecondsSinceEpoch(value)));
    }

    // 获取课表学期
    String _scheduleSemesterName = prefs.getString("schedule_semester");
    if (_scheduleSemesterName != "" && _scheduleSemesterName != null) {
      scheduleSemesterName = _scheduleSemesterName;
      scheduleSemesterId = semesterList[_scheduleSemesterName];
    }

    // 获取成绩查询默认学期
    String _gradeSemesterName = prefs.getString("grade_semester");
    if (_gradeSemesterName != "" && _scheduleSemesterName != null) {
      gradeSemesterName = _gradeSemesterName;
      gradeSemesterId = semesterList[_gradeSemesterName];
    }

  }

  static Future<bool> loadSemesters(SharedPreferences prefs) async {

    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }

    var _autoSyncSemester = prefs.getBool("auto_async_semesters");
    if (_autoSyncSemester == null || _autoSyncSemester) {
      PreloadData.autoSyncSemester = true;
    } else {
      PreloadData.autoSyncSemester = false;
    }

    try {
      var resp = await getNetData("https://cdn.jsdelivr.net/gh/yearsyan/inneu-public/app-status/semesters.json");
      if (resp != null) {

        Map<String,dynamic> map = Map<String,dynamic>.from(resp);

        prefs.setBool("is_holiday", map["is_holiday"]);
        prefs.setInt("current_semester_id", map["current_semester_id"]);
        PreloadData.currentSemesterId = map["current_semester_id"];
        PreloadData.isHoliday = map["is_holiday"];

        if (PreloadData.autoSyncSemester) {
          print("schedule: " + map["schedule_semester_id"].toString());
          PreloadData.gradeSemesterName = map["grade_semester_name"];
          prefs.setString("grade_semester", PreloadData.gradeSemesterName);
          PreloadData.gradeSemesterId = map["grade_semester_id"];
          PreloadData.examSemesterName = map["exam_semester_name"];
          prefs.setString("exam_semester", PreloadData.examSemesterName);
          PreloadData.examSemesterId = map["exam_semester_id"];
          PreloadData.scheduleSemesterName = map["schedule_semester_name"];
          prefs.setString("schedule_semester", PreloadData.scheduleSemesterName);
          PreloadData.scheduleSemesterId = map["schedule_semester_id"];
          PreloadData.currentSemesterId = map["current_semester_id"];
          PreloadData.isHoliday = map["is_holiday"];
          return true;
        } else {
          _loadSemesterFromStorage(prefs);
          return true;
        }

      } else {
        PreloadData.isHoliday = prefs.getBool("is_holiday")??false;
        PreloadData.currentSemesterId = prefs.getInt("current_semester_id")??31;
        throw Exception();
      }
    } catch(e) {

      await _loadSemesterFromStorage(prefs);

      return false;
    }


  }

  static loadIndexComponent(SharedPreferences prefs) async {

    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }

    List<String> indexComponentsStorage = prefs.getStringList("index_components");
    if (indexComponentsStorage == null) {
      if (PreloadData.isLogin) {
        indexComponents = ["card"];
      } else {
        indexComponents = ["news"];
      }
    } else {
      indexComponents = indexComponentsStorage;
    }

  }

  static loadFunctions(SharedPreferences prefs) async {

    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }

    try {
      var resp = await getNetData("https://cdn.jsdelivr.net/gh/yearsyan/inneu-public/app-status/functions.json");
      lifeFunctions = List<Map<String,dynamic>>.from(resp["life"]);
      studyFunctions = List<Map<String,dynamic>>.from(resp["study"]);
      prefs.setString("online_functions", json.encode(resp));
    } catch(e) {
      String jsonStr = prefs.getString("online_functions");
      if (jsonStr != null) {
        var _data = json.decode(jsonStr);
        lifeFunctions = List<Map<String,dynamic>>.from(_data["life"]);
        studyFunctions = List<Map<String,dynamic>>.from(_data["life"]);
      } else {
        lifeFunctions = [
          {
            "name": "校历",
            "icon": "",
            "url": "https://img-pool.zxysy.net/article/neu-calendar-2020-2021.html"
          }
        ];
      }
    }

  }

  static loadBanner(SharedPreferences prefs) async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }

    try {
      var resp = await getNetData("https://cdn.jsdelivr.net/gh/yearsyan/inneu-public/app-status/banner.json");
      banner = List<Map<String,dynamic>>.from(resp);
      prefs.setString("banner", json.encode(resp));
    } catch(e) {
      String jsonStr = prefs.getString("banner");
      if (jsonStr != null) {
        var _data = json.decode(jsonStr);
        banner = List<Map<String,dynamic>>.from(_data);
      }
    }

  }

  static _preloadCard() async {
    bool isCardLogin = false;

    Dio dio = Dio();
    dio.options.connectTimeout = 1000;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    while(true) {
      try {
        var resp = await dio.post("https://inneu-api.neuyan.com/campusCard/cardMoney", data: {
          "user_id": prefs.getString("user_id"),
          "enc_pwd": prefs.getString("enc_pwd")
        });
        if (resp.data["code"] == 0) {
          isCardLogin = true;
        } else {
          isCardLogin = false;
        }
      } catch(e) {}

      if(isCardLogin) {
        await Future.delayed(Duration(seconds: 1));
      } else {
        await Future.delayed(Duration(seconds: 30));
      }

    }
  }

  static loadData() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool("has_launch") == null || prefs.getBool("has_launch") == false) {
      prefs.setBool("has_launch", true);
      Random random = Random();
      PreloadData.session = List<String>.generate(32, (index) => "abcdefghijklmnopqrstuvwxyz1234567890".split('')[random.nextInt(35)]).join("");
      prefs.setString("session", PreloadData.session);
    } else {
      PreloadData.session = prefs.getString("session");
    }

    bool _isLogin = prefs.getBool("login_status");
    if (_isLogin != null && _isLogin) {
      isLogin = true;
      PreloadData.userType = prefs.getString("user_type");
      if (PreloadData.userType == null) {
        // 需要重新登录
        PreloadData.isLogin = false;
        prefs.setBool("login_status", false);
        prefs.setString("userInfo", null);
        prefs.setString("enc_pwd", null);
        prefs.setString("user_id", null);
        prefs.setStringList("index_components", ["news"]);
        await loadFunctions(prefs);
        await loadBanner(prefs);
        return;
      }
    }

    bool _autoCheckUpdate = prefs.getBool("auto_check_update");
    if (_autoCheckUpdate == null || _autoCheckUpdate) {
      autoCheckUpdate = true;
    } else {
      autoCheckUpdate = false;
    }

    // 加载首页需要的组件
    Future componentFuture = loadIndexComponent(prefs);

    // 加载功能页网页功能
    Future onlineFunctionFuture = loadFunctions(prefs);

    // 加载banner
    Future bannerFuture = loadBanner(prefs);

    // 加载学期
    await loadSemesters(prefs);

    // 加载课表
    Future scheduleFuture = loadSchedule(prefs);

    if (isLogin) {

      // 加载个人信息
      String userInfoCache = prefs.getString("userInfo");
      if (userInfoCache != null) {
        userInfo = Map<String,dynamic>.from(json.decode(userInfoCache));
      } else {
        userInfo = await queryUserInfo();
        if (userInfo != null) {
          prefs.setString("userInfo", json.encode(userInfo));
        }
      }

      _preloadCard();

    }

    await componentFuture;
    await scheduleFuture;
    await onlineFunctionFuture;
    await bannerFuture;

  }
}