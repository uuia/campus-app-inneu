import 'dart:convert';
import 'package:date_format/date_format.dart';
import 'package:dio/dio.dart';
import 'package:inneu/pages/schedule/schedulePage.dart';
import 'package:inneu/preloadData.dart';
import 'package:shared_preferences/shared_preferences.dart';

String baseUrl = "https://inneu-api.neuyan.com";

_postJson(String url, Map<String,dynamic> map) async {
  Dio dio = Dio();
  dio.options.connectTimeout = 2500;
  var response = await dio.post(url, data: map);
  return response.data;
}

Future<dynamic> getNetData(String url) async {
  Dio dio = Dio();
  dio.options.headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.135 Safari/537.36"
  };

  try {
    var data = (await dio.get(url)).data;
    print(data);
    return data;
  } catch (e) {
    return null;
  }

}

Future<String> getSSOCookie() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userId = prefs.getString("user_id");
  var encPassword = prefs.getString("enc_pwd");
  Map<String,dynamic> res = await _postJson(baseUrl + "/login/sso-cookie-str", {
    "user_id": userId,
    "enc_pwd": encPassword
  });
  print(json.encode(res));
  if (res["code"] == 0) {
    return res["data"]["cookie"];
  }
}

Future<bool> loginService(String userId, String password) async {
  Map<String,dynamic> res = await _postJson(baseUrl + "/login", {
    "user_id": userId,
    "password": password
  });
  if (res["code"] == 0) {
    String encPwd = res["data"]["enc_pwd"];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    PreloadData.isLogin = true;
    prefs.setBool("login_status", true);
    prefs.setString("enc_pwd", encPwd);
    prefs.setString("user_id", userId);
    prefs.setString("pwd_" + userId, password);

    if (userId.length == 8) {
      prefs.setString("user_type", "undergraduate");
      PreloadData.userType = "undergraduate";
    } else if (userId.length == 7) {
      prefs.setString("user_type", "postgraduate");
      PreloadData.userType = "postgraduate";
    }

    return true;
  } else {
    return false;
  }
}

Future<Map<String,dynamic>> queryPortalInfo() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userId = prefs.getString("user_id");
  var encPassword = prefs.getString("enc_pwd");

  for (int tryTimes = 0; tryTimes < 10 ;tryTimes ++ ) {
    try {
      Map<String,dynamic> res = await _postJson(baseUrl + "/portal/service", {
        "user_id": userId,
        "enc_pwd": encPassword
      });
      print(json.encode(res));
      if (res["code"] == 0) {
        return res["data"];
      }
    } catch (e) {}
    await Future.delayed(Duration(milliseconds: 400));
  }

  return null;
}

Future<Map<String,dynamic>> queryUserInfo() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userId = prefs.getString("user_id");
  var encPassword = prefs.getString("enc_pwd");

  for (int tryTimes = 0; tryTimes < 10; tryTimes++) {
    try {
      Map<String,dynamic> res = await _postJson(baseUrl + "/portal/userInfo", {
        "user_id": userId,
        "enc_pwd": encPassword
      });
      print(json.encode(res));
      if (res["code"] == 0) {
        return Map<String,dynamic>.from(res["data"]);
      }
    } catch (e, stack) {
      print("/portal/userInfo");
      print(e);
      print(stack);
    }
    await Future.delayed(Duration(milliseconds: 400));
  }

  return null;
}

Future<Map<String,dynamic>> queryLibraryBorrow() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userId = prefs.getString("user_id");
  var encPassword = prefs.getString("enc_pwd");

  for (int tryTimes = 0; tryTimes < 10; tryTimes++) {
    try {
      Map<String,dynamic> res = await _postJson(baseUrl + "/library/borrow", {
        "user_id": userId,
        "enc_pwd": encPassword
      });
      print(json.encode(res));
      if (res["code"] == 0) {
        return res["data"];
      }
      await Future.delayed(Duration(milliseconds: 400));
    } catch (e) {print(e);}
  }

  return null;
}

Future<Map<String,dynamic>> queryGrade(int semesterId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userId = prefs.getString("user_id");
  var encPassword = prefs.getString("enc_pwd");

  for (int tryTimes = 0; tryTimes < 10 ;tryTimes ++) {
    try {
      Map<String,dynamic> res = await _postJson(baseUrl + "/aao/score", {
        "semester_id": semesterId,
        "user_id": userId,
        "enc_pwd": encPassword
      });
      print(json.encode(res));
      if (res["code"] == 0) {
        return res["data"];
      }
      await Future.delayed(Duration(milliseconds: 550));
    } catch (e) {print(e);}
  }

  return null;
}

Future<List<Map<String,dynamic>>> queryExam(int semesterId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userId = prefs.getString("user_id");
  var encPassword = prefs.getString("enc_pwd");

  Dio dio = Dio();
  dio.options.connectTimeout = 10000;

  for(int tryTimes = 0; tryTimes < 10; tryTimes ++) {
    try {

      var response = await dio.post(baseUrl + "/aao/exam", data: {
        "semester_id": semesterId,
        "user_id": userId,
        "enc_pwd": encPassword
      });

      Map<String,dynamic> res = response.data;
      print(json.encode(res));
      if (res["code"] == 0) {

        List<dynamic> data = res["data"];
        data.forEach((element) {

          String time = element["time"];
          if (time == null || time == "" || time.contains("时间未安排")) {
            element["timestamp"] = -1;
            return;
          }

          DateTime t1 = DateTime.parse(time.split("~")[0]);
          DateTime t2 = DateTime.parse(time.split(" ")[0] + " " + time.split("~")[1]);
          element["timestamp"] = t1.millisecondsSinceEpoch;
          element["timestamp_end"] = t2.millisecondsSinceEpoch;
        });
        return data.map((e) => Map<String,dynamic>.from(e)).toList();

      }
      await Future.delayed(Duration(milliseconds: 550));
    } catch (e, stack) {
      print(e);
      print(stack);
    }
  }

  return null;
}

Future<List<Map<String,dynamic>>> queryAllGrade() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userId = prefs.getString("user_id");
  var encPassword = prefs.getString("enc_pwd");

  for (int tryTimes  = 0; tryTimes < 10; tryTimes++ ) {
    try {
      Map<String,dynamic> res = await _postJson(baseUrl + "/aao/score-all", {
        "user_id": userId,
        "enc_pwd": encPassword
      });
      print(json.encode(res));
      if (res["code"] == 0) {
        List<dynamic> data = res["data"];
        return data.map((e) => Map<String,dynamic>.from(e)).toList();
      }
      await Future.delayed(Duration(milliseconds: 550));
    } catch (e, stack) {
      print(e);
      print(stack);
    }
  }

  return null;
}

Future<List<CourseItem>> querySchedule(int semesterId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userId = prefs.getString("user_id");
  var encPassword = prefs.getString("enc_pwd");

  for (int tryTimes = 0; tryTimes < 10; tryTimes ++) {
    try {
      Map<String,dynamic> res = await _postJson(baseUrl + "/aao/schedule", {
        "user_id": userId,
        "enc_pwd": encPassword,
        "semester_id": semesterId
      });
      print(res);
      if (res["code"] == 0) {
        List<dynamic> courseList = res["data"];
        prefs.setString("net_cache_courses_$semesterId", json.encode(courseList));
        return courseList.map((e) => CourseItem(
          courseName: e["course_name"],
          courseCode: e["course_code"],
          classroom: e["classroom"],
          weeks: List<int>.from(e["weeks"]),
          day: e["day"],
          section: e["section"],
          len: e["len"],
          teachers: List<String>.from(e["teachers"]),
        )).toList();
      }
      await Future.delayed(Duration(milliseconds: 500));
    } catch (e, stack) {
      print("/aao/schedule");
      print(e);
      print(stack);
    }
  }

  return null;

}

Future<Map<String,dynamic>> queryBook(String name,int page) async {
  Dio dio = Dio();
  int tryTimes = 0;
  Map<String,dynamic> res;

  while(tryTimes < 5) {

    try {
      var resp = await dio.get(baseUrl + "/library/search?name=$name&page=$page");
      print(resp.data);
      print(resp.data["code"] == 0);
      if(resp.data["code"] == 0) {
        res = Map<String,dynamic>.from(resp.data["data"]);
        return res;
      }
      tryTimes ++;
      await Future.delayed(Duration(milliseconds: 500));
    } catch (e, stack) {
      print(e);
      print(stack);
    }

  }

  return null;
}

Future<Map<String,dynamic>> queryCardMoney() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userId = prefs.getString("user_id");
  var encPassword = prefs.getString("enc_pwd");

  for (int tryTimes = 0; tryTimes < 10; tryTimes ++) {
    try {
      Map<String,dynamic> res = await _postJson(baseUrl+"/campusCard/cardMoney", {
        "user_id": userId,
        "enc_pwd": encPassword,
      });

      print(json.encode(res));
      if (res["code"] == 0) {
        return Map<String,dynamic>.from(res["data"]);
      }
    } catch (e, stack) {
      print(e);
      print(stack);
    }
  }

  return null;

}

Future<Map<String,dynamic>> queryCardTrade(DateTime start, DateTime end) async {

  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userId = prefs.getString("user_id");
  var encPassword = prefs.getString("enc_pwd");

  for (int tryTimes = 0; tryTimes < 10; tryTimes ++) {
    try {
      Map<String,dynamic> res = await _postJson(baseUrl+"/campusCard/trade", {
        "user_id": userId,
        "enc_pwd": encPassword,
        "start": formatDate(start, ["yyyy","-","mm","-","dd"]),
        "end": formatDate(end, ["yyyy","-","mm","-","dd"])
      });

      print(json.encode(res));
      if (res["code"] == 0) {
        return Map<String,dynamic>.from(res["data"]);
      }
      await Future.delayed(Duration(milliseconds: 400));
    } catch (e, stack) {
      print(e);
      print(stack);
    }
  }

  return null;

}

Future<String> getLoginUrl(String url) async {

  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userId = prefs.getString("user_id");
  var encPassword = prefs.getString("enc_pwd");

  for(int tryTimes = 0;tryTimes < 5; tryTimes++) {

    try {
      var resp = await _postJson(baseUrl+"/login/url", {
        "user_id": userId,
        "enc_pwd": encPassword,
        "url": url
      });

      if (resp["code"]==0) {
        return resp["data"]["url"];
      }
    } catch (e, stack) {
      print(e);
      print(stack);
    }

  }

  return null;

}