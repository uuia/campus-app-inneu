
import 'package:flutter/material.dart';

class IconTitle extends StatelessWidget {

  final IconData icon;
  final String title;

  IconTitle({this.icon,this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            child: Icon(icon, size: 15, color: Color.fromARGB(240, 90, 90, 90)),
            margin: EdgeInsets.fromLTRB(3, 5, 3, 2),
          ),
          Text(title, style: TextStyle(
              color: Color.fromARGB(240, 90, 90, 90)
          ))
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
    );
  }
}