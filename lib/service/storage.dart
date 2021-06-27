import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

setExam(int semesterId,Map<String,dynamic> data) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String storageDataString = prefs.getString("exam_storage_$semesterId");
  if (storageDataString==null || storageDataString == "") {
    storageDataString = "{}";
  }
  Map<String,dynamic> storageData = Map<String,dynamic>.from(json.decode(storageDataString));
  String code = data["code"];
  storageData[code] = data;
  prefs.setString("exam_storage_$semesterId", json.encode(storageData));
}

removeExam(int semesterId, String code) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String storageDataString = prefs.getString("exam_storage_$semesterId");
  if (storageDataString==null || storageDataString == "") {
    storageDataString = "{}";
  }
  Map<String,dynamic> storageData = Map<String,dynamic>.from(json.decode(storageDataString));
  storageData.remove(code);
  prefs.setString("exam_storage_$semesterId", json.encode(storageData));
}