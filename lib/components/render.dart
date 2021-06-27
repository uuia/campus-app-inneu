
import 'dart:convert';

import 'package:flutter/material.dart';

ComponentItem parseComponent(Map<String,dynamic> component) {
  return ComponentItem(
    attr: component.containsKey("attr")?Map<String,String>.from(component["attr"]):{},
    tag: component["tag"],
    content: component["content"],
    children: component.containsKey("children")? List<dynamic>.from(component["children"]).map((e) => parseComponent(Map<String,dynamic>.from(e))).toList() : [],
  );
}

enum XmlParserStatus {
  startTag,
  startTagEnd,
}

ComponentItem parseXMLComponent(String xmlStr) {

  return null;

}

class ComponentItem {

  Map<String,String> attr;
  String tag;
  String content;
  List<ComponentItem> children;

  ComponentItem({
    @required this.tag,
    this.content,
    this.children,
    this.attr,
  }) {
    if (attr == null) {
      attr = Map<String,String>();
    }
  }

}

// ignore: must_be_immutable
class RenderComponent extends StatelessWidget {

  final ComponentItem content;
  final String code;
  final String format;
  ComponentItem _realContent;

  RenderComponent({this.content, this.code, this.format}) {
    if (code != null) {
      if (format.toUpperCase()=="JSON") {
        _realContent = parseComponent(Map<String,dynamic>.from(json.decode(code)));
      }
    } else {
      _realContent = content;
    }
  }

  _parseColor(String colorStr) {
    int a = int.parse("0x" + colorStr.substring(1,3));
    int r = int.parse("0x" + colorStr.substring(3,5));
    int g = int.parse("0x" + colorStr.substring(5,7));
    int b = int.parse("0x" + colorStr.substring(7,9));
    return Color.fromARGB(a, r, g, b);
  }

  @override
  Widget build(BuildContext context) {
    return ((ComponentItem item) {
      if (item.tag == "text") {

        var style = TextStyle(
          fontSize: item.attr.containsKey("font-size")? double.parse(item.attr["font-size"]) : 15,
          color: item.attr.containsKey("color")? _parseColor(item.attr["colors"]) : Colors.black,
        );

        TextAlign textAlign = TextAlign.start;
        if (item.attr.containsKey("align") && item.attr["align"] != null) {
          switch (item.attr["align"]) {
            case "center":
              textAlign = TextAlign.center;
              break;
            case "left":
              textAlign = TextAlign.left;
              break;
            case "right":
              textAlign = TextAlign.right;
              break;
          }
        }
        var widget = Text(item.content, style: style, textAlign: textAlign);
        return widget;

      } else if (item.tag == "column") {
        return Column(
          crossAxisAlignment: item.attr.containsKey("cross-axis")? item.attr["cross-axis"]=="center" ? CrossAxisAlignment.center : CrossAxisAlignment.start : CrossAxisAlignment.start,
          mainAxisSize: item.attr.containsKey("main-axis-size")? item.attr["main-axis-size"]=="max"? MainAxisSize.max : MainAxisSize.min : MainAxisSize.max,
          children: item.children.map((e) => RenderComponent(content: e)).toList(),
        );
      } else if (item.tag == "row") {
        return Row(
          mainAxisSize: item.attr.containsKey("main-axis-size")? item.attr["main-axis-size"]=="max"? MainAxisSize.max : MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment: item.attr.containsKey("main-axis")? item.attr["main-axis"]=="center"? MainAxisAlignment.center : item.attr["main-axis"]=="space-between"? MainAxisAlignment.spaceBetween : MainAxisAlignment.start : MainAxisAlignment.start,
          children: item.children.map((e) => RenderComponent(content: e)).toList(),
        );
      } else if (item.tag == "container") {
        return Container(
          padding: EdgeInsets.fromLTRB(double.parse(item.attr["padding-left"]??"0"), double.parse(item.attr["padding-top"]??"0"), double.parse(item.attr["padding-right"]??"0"), double.parse(item.attr["padding-bottom"]??"0")),
          margin: EdgeInsets.fromLTRB(double.parse(item.attr["margin-left"]??"0"), double.parse(item.attr["margin-top"]??"0"), double.parse(item.attr["margin-right"]??"0"), double.parse(item.attr["margin-bottom"]??"0")),
          child: item.children!=null&&item.children.length>0? RenderComponent(content: item.children[0]) : Container(),
          decoration: BoxDecoration(
              color: item.attr.containsKey("color")? _parseColor(item.attr["color"]) : Color.fromARGB(0, 0, 0, 0),
              borderRadius: BorderRadius.all(Radius.circular(item.attr.containsKey("radius")?double.parse(item.attr["radius"]):0))
          ),
        );
      } else if (item.tag == "image") {
        if (item.content.startsWith("https://")) {
          print("network "+ item.content);
          return Image.network(item.content,
              height: item.attr.containsKey("height")? double.parse(item.attr["height"]) : null,
              width: item.attr.containsKey("width")? double.parse(item.attr["width"]) : null,
              fit: item.attr.containsKey("fit")?
              item.attr["fit"]=="fit-width"? BoxFit.fitWidth :
              item.attr["fit"]=="fit-height"? BoxFit.fitHeight :
              item.attr["fit"]=="fill"? BoxFit.fill :
              item.attr["fit"]=="cover"? BoxFit.cover : BoxFit.none: BoxFit.none
          );
        } else if (item.content.startsWith("assert://")) {
          return Image(
              image: AssetImage(item.content.replaceFirst("assert://", "")),
              height: item.attr.containsKey("height")? double.parse(item.attr["height"]) : null,
              width: item.attr.containsKey("width")? double.parse(item.attr["width"]) : null,
              fit: item.attr.containsKey("fit")?
              item.attr["fit"]=="fit-width"? BoxFit.fitWidth :
              item.attr["fit"]=="fit-height"? BoxFit.fitHeight :
              item.attr["fit"]=="fill"? BoxFit.fill :
              item.attr["fit"]=="cover"? BoxFit.cover : BoxFit.none: BoxFit.none
          );
        }
      } else if (item.tag == "center") {
        return Center(
          child: item.children!=null && item.children.length>0? RenderComponent(content: item.children[0]) : Container(),
        );
      }
      return Container();
    })(_realContent);
  }

}