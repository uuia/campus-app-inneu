
import 'package:flutter/material.dart';
import 'package:inneu/theme.dart';

class ErrorRefresh extends StatelessWidget {

  final Function onRefresh;

  ErrorRefresh({this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRefresh,
      child:  Center(
        child: Column(
          children: [
            Container(
              child: Icon(Icons.error_outline, color: ThemeRegular.themeTextColor, size: 35,),
              margin: EdgeInsets.fromLTRB(0, 15, 0, 10),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 2, 0, 15),
              child: Text("加载错误，点击重新加载", style: TextStyle(
                fontSize: 15,
              )),
            )
          ],
        ),
      ),
    );
  }
}