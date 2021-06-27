

import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:inneu/theme.dart';

import '../preloadData.dart';

class IndexBanner extends StatefulWidget {

  final List<Map<String,dynamic>> data;

  IndexBanner({this.data});

  @override
  _BannerState createState() => _BannerState();

}

class _BannerState extends State<IndexBanner> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(ThemeRegular.cardMargin),
      height: 0.5*(MediaQuery.of(context).size.width-2*ThemeRegular.cardMargin),
      child: PhysicalModel(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Swiper(
          itemBuilder: (BuildContext ctx, int index) {
            return GestureDetector(
              onTap: () {
                if (widget.data[index]["nav"] != null && widget.data[index]["nav"] != "") {
                  if (widget.data[index]["need_login"] == true && !PreloadData.isLogin) {
                    return;
                  } else {
                    try {
                      Navigator.pushNamed(context, widget.data[index]["nav"]);
                    } catch (e,stack) {
                      print(e);
                      print(stack);
                    }
                  }
                }
              },
              child: Image.network(widget.data[index]["url"], fit: BoxFit.fill,),
            );
          },
          itemCount: widget.data.length,
          pagination: SwiperPagination(
              margin: EdgeInsets.all(0)
          ),
          controller: SwiperController(),
        ),
      ),
    );
  }
}