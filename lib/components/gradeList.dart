
import 'package:flutter/material.dart';

class GradeList extends StatelessWidget {

  final List<Map<String,dynamic>> data;
  final double width;

  GradeList({this.data, this.width});

  List<DataCell> getDataCell(Map<String,dynamic> e, bool withExtra) {

    var res = [
      DataCell(
        Container(
          child: Text(e["course_name"]),
          width: width * 0.2,
        ),
      ),
      DataCell(
        Container(
          child: Text(e["credit"]),
          width: width * 0.1,
        ),
      ),
      DataCell(
        Container(
          child: Text(e["usual_grade"]),
          width: width * 0.1,
        ),
      ),
      DataCell(
        Container(
          child: Text(e["mid_grade"]),
          width: width * 0.1,
        ),
      ),
      DataCell(
        Container(
          child: Text(e["final_grade"]),
          width: width * 0.1,
        ),
      ),
    ];
    
    if (withExtra) {
      res.add(DataCell(Text(e["extra_grade"] == null ? "-" : e["extra_grade"])));
    }

    res.add(DataCell(
      Container(
        child: Text(e["sum_grade"]),
        width: width * 0.1,
      )
    ));

    return res;
  }


  @override
  Widget build(BuildContext context) {

    bool withExtraGrade = data.any((element) => element["extra_grade"] != null );

    var columns = [
      DataColumn(label: Container(
        child: Text("课程名称"),
        width: width * 0.2,
      )),
      DataColumn(label: Container(
        child: Text("学分"),
        width: width * 0.1,
      )),
      DataColumn(label: Container(
        child: Text("平时"),
        width: width * 0.1,
      )),
      DataColumn(label: Container(
        child: Text("期中"),
        width: width * 0.1,
      )),
      DataColumn(label: Container(
        child: Text("期末"),
        width: width * 0.1,
      )),
    ];

    if (withExtraGrade) {
      columns.add(DataColumn(label: Text("补考")));
    }

    columns.add(DataColumn(label: Container(
      child: Text("总计"),
      width: width * 0.1,
    )));

    return DataTable(
      columns: columns,
      columnSpacing: withExtraGrade? width * 0.018 : width * 0.028,
      rows: data.map((e) => DataRow(
          cells: getDataCell(e, withExtraGrade)
      )).toList(),
    );
  }
}