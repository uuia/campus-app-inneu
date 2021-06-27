import 'package:flutter/material.dart';
import 'package:inneu/components/render.dart';
import 'package:inneu/theme.dart';

class RenderPageArgument {
  String codeFormat;
  String code;
  String pageName;

  RenderPageArgument({this.code,this.codeFormat,this.pageName});

}

class RenderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    RenderPageArgument argument = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(argument.pageName),
      ),
      backgroundColor: ThemeRegular.backgroundColor,
      body: SingleChildScrollView(
        child: RenderComponent(
          format: argument.codeFormat,
          code: argument.code,
        ),
      ),
    );

  }
}