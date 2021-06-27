
import 'package:flutter/material.dart';
import 'package:inneu/theme.dart';

class MenuItem {

  String name;
  Widget icon;
  Widget right;

  Function() onTap;

  MenuItem({this.name,this.icon,this.right,this.onTap});

}

class MenuItems extends StatelessWidget {

  final List<MenuItem> data;

  MenuItems({this.data});

  @override
  Widget build(BuildContext context) {

    while(data.contains(null)) {
      data.remove(null);
    }

    return Container(
      margin: EdgeInsets.all(ThemeRegular.cardMargin),
      decoration: BoxDecoration(
        color: ThemeRegular.cardBackgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: PhysicalModel(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: Column(
          children: data.map((e) => Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: ThemeRegular.backgroundColor
                )
              )
            ),
            child: Material(
              child: Ink(
                color: Colors.white,
                child: InkWell(
                  onTap: e.onTap,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.fromLTRB(4, 7, 10, 4),
                              child: e.icon,
                            ),
                            Container(
                              child: Text(e.name, style: TextStyle(
                                fontSize: 16,
                                color: ThemeRegular.deepColor,
                                fontWeight: FontWeight.w500
                              )),
                            )
                          ],
                        ),
                        e.right??Container()
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )).toList(),
        ),
      )
    );
  }
}