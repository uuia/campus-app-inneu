
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FunctionItem {

  final Icon icon;
  final String name;
  final Function() onTap;

  FunctionItem({this.icon, this.name, this.onTap});

}

class FunctionList extends StatelessWidget {

  final List<FunctionItem> items;
  final int rowNum;
  final String title;

  FunctionList({this.items, this.rowNum = 3, this.title});

  @override
  Widget build(BuildContext context) {
    double boxWidth = MediaQuery.of(context).size.width - 20;
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        color: Colors.white
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width - 20,
            padding: EdgeInsets.fromLTRB(8, 15, 0, 15),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 0.9,
                  color: Color.fromARGB(230, 200, 200, 200)
                )
              )
            ),
            child: Text(title),
          ),
          Flow(
            delegate: FunctionListDelegate(
              rowNum: rowNum,
              width: boxWidth,
              count: items.length,
            ),
            children: items.asMap().keys.map((i) => Container(
              width: boxWidth/rowNum,
              height: boxWidth/rowNum,
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 0.5,
                    style: (i/rowNum).floor() == (items.length%rowNum == 0? (items.length/rowNum)-1 :(items.length/rowNum).floor()) ? BorderStyle.none : BorderStyle.solid,
                    color: Color.fromARGB(230, 200, 200, 200),
                  ),
                  right: BorderSide(
                    width: 0.5,
                    style: i%rowNum == rowNum -1 ? BorderStyle.none : BorderStyle.solid,
                    color: Color.fromARGB(230, 200, 200, 200),
                  ),
                ),
              ),
              child: Material(
                child: Ink(
                  color: Colors.white,
                  child: InkWell(
                    onTap: items[i].onTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(5),
                          child: items[i].icon,
                        ),
                        Text(items[i].name)
                      ],
                    ),
                  ),
                ),
              ),
            ),).toList(),
          ),
        ],
      ),
    );
  }
}

class FunctionListDelegate extends FlowDelegate {

  final int rowNum;
  final double width;
  final int count;

  FunctionListDelegate({this.rowNum, this.width, this.count});

  @override
  void paintChildren(FlowPaintingContext context) {
    double itemWidth = width/rowNum;
    for (int itemIndex = 0; itemIndex < context.childCount; itemIndex++) {
      int rowIndex = itemIndex % rowNum;
      int columnIndex = (itemIndex/rowNum).floor();
      context.paintChild(itemIndex, transform: Matrix4.translationValues((rowIndex * itemWidth).floorToDouble(), (columnIndex * itemWidth).floorToDouble(), 0));
    }
  }

  @override
  Size getSize(BoxConstraints constraints) {
    print(width);
    print((width/rowNum)*( (rowNum/count).floor() + 1));
    return Size(width, (width/rowNum)*((count/rowNum).ceil()));
  }

  @override
  bool shouldRepaint(FlowDelegate oldDelegate) {
    return oldDelegate != this;
  }
}