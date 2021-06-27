
import 'package:flutter/material.dart';

class TitleLine extends StatelessWidget {

  final String title;
  final String eng;

  TitleLine({this.title, this.eng});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(18, 8, 18, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(title, style: TextStyle(
            fontSize: 24,
            fontFamily: "SourceHanSans"
          )),
          Text(eng, style: TextStyle(
            color: Color.fromARGB(230, 90, 90, 90),
            fontFamily: "Recursive",
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ))
        ],
      ),
    );
  }
}