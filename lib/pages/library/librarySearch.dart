
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inneu/service/request.dart';
import 'package:inneu/theme.dart';
import 'package:loading/indicator/line_scale_indicator.dart';
import 'package:loading/loading.dart';


class _SearchResItem extends StatelessWidget {

  final String bookName;
  final String author;
  final String index;
  final String publisher;
  final String cover;
  final String year;
  final int holding;
  final int lending;

  static final RegExp isbnPattern = RegExp("isbn=(.*?)/");

  findISBN() {
    try {
      return isbnPattern.firstMatch(cover).group(1).replaceAll("-", "");
    } catch(e) {
      return "未知";
    }
  }

  _SearchResItem({
    this.cover,
    this.bookName,
    this.author,
    this.index,
    this.publisher,
    this.year,
    this.holding,
    this.lending
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(ThemeRegular.cardMargin),
      padding: EdgeInsets.fromLTRB(15, 8, 15, 8),
      decoration: BoxDecoration(
        color: ThemeRegular.cardBackgroundColor,
        borderRadius: ThemeRegular.cardRadius,
      ),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(bookName.replaceAll(RegExp("(&nbsp)|(:)|(;)"), " "), style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600
                  )),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        color: ThemeRegular.backgroundColor
                    ),
                    child: Center(
                      child: Text("出版社", style: TextStyle(
                          fontSize: 13
                      )),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(publisher, textAlign: TextAlign.center, style: TextStyle(
                        fontSize: 13,
                        color: ThemeRegular.deepColor
                    )),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        color: ThemeRegular.backgroundColor
                    ),
                    child: Center(
                      child:  Text("作者", style: TextStyle(
                          fontSize: 13
                      )),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(author.trim()==""?"未知":author, style: TextStyle(
                        fontSize: 13,
                        color: ThemeRegular.deepColor
                    )),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        color: ThemeRegular.backgroundColor
                    ),
                    child: Center(
                      child: Text("索引号", style: TextStyle(
                          fontSize: 13
                      )),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(index==""?"-":index, style: TextStyle(
                        fontSize: 13,
                        color: ThemeRegular.deepColor
                    )),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        color: ThemeRegular.backgroundColor
                    ),
                    child: Center(
                      child:  Text("ISBN", style: TextStyle(
                          fontSize: 13
                      )),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(findISBN(), style: TextStyle(
                        fontSize: 13,
                        color: ThemeRegular.deepColor
                    )),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        color: ThemeRegular.backgroundColor
                    ),
                    child: Center(
                      child: Text("馆藏数", style: TextStyle(
                          fontSize: 13
                      )),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(holding.toString(), style: TextStyle(
                        fontSize: 13,
                        color: ThemeRegular.deepColor
                    )),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        color: ThemeRegular.backgroundColor
                    ),
                    child: Center(
                      child:  Text("已借", style: TextStyle(
                          fontSize: 13
                      )),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(lending.toString(), style: TextStyle(
                        fontSize: 13,
                        color: ThemeRegular.deepColor
                    )),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _LibrarySearchBody extends StatefulWidget {
  @override
  _LibrarySearchBodyState createState() => _LibrarySearchBodyState();

}

class _LibrarySearchBodyState extends State<_LibrarySearchBody> {

  bool isLoading = false;
  bool disableButton = true;
  bool isEnd = false;
  int currentPage = 0;
  int maxRecord;
  TextEditingController keywordController = TextEditingController();
  FocusNode _focusNode = FocusNode();

  List<Map<String,dynamic>> books = [];

  ScrollController _scrollController;

  loadBooks() async {

    setState(() {
      isLoading = true;
    });

    var data = await queryBook(keywordController.text, currentPage);
    print(data);
    if (data != null) {
      setState(() {
        var newBooks = List<Map<String,dynamic>>.from(data["books"]);
        newBooks.forEach((element) {
          books.add(element);
        });
        maxRecord = data["count"];
        isLoading = false;
        disableButton = false;
      });
    } else {
      Fluttertoast.showToast(
        msg: "加载失败",
        textColor: ThemeRegular.textColor,
        backgroundColor: ThemeRegular.backgroundColor
      );
      setState(() {
        isLoading = false;
        currentPage = 0;
        disableButton = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
    ..addListener(() {
      if (_scrollController.position.pixels + 500 > _scrollController.position.maxScrollExtent && books.length < maxRecord && !isLoading) {
        currentPage++;
        loadBooks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          height: 52,
          color: ThemeRegular.cardBackgroundColor,
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Container(
                  height: 30,
                  margin: EdgeInsets.fromLTRB(5, 3, 10, 3),
                  child: TextField(
                    onChanged: (text) {
                      if(text.length == 0) {
                        setState(() {
                          disableButton = true;
                        });
                      } else if (disableButton) {
                        setState(() {
                          disableButton = false;
                        });
                      }
                    },
                    controller: keywordController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(15, 0, 5, 6),
                      helperMaxLines: 1,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                          borderSide: BorderSide(width: 1)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                          borderSide: BorderSide(width: 1, color: ThemeRegular.mainColor)
                      ),
                      hintText: "请输入关键词",
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.fromLTRB(9, 0, 9, 0),
                  height: 30,
                  child: RaisedButton(
                    color: ThemeRegular.backgroundColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))
                    ),
                    elevation: 0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 3, 3, 0),
                          child: Icon(Icons.search, size: 16, color: ThemeRegular.textColor),
                        ),
                        Text("搜索", style: TextStyle(
                            fontSize: 14,
                            color: ThemeRegular.textColor
                        ))
                      ],
                    ),
                    disabledColor: ThemeRegular.backgroundColor,
                    onPressed: disableButton? null : () {
                      _focusNode.unfocus();
                      setState(() {
                        disableButton = true;
                        currentPage = 1;
                        books = [];
                      });
                      loadBooks();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: List<Widget>.from(books.map((e) => _SearchResItem(
                bookName: e["book_name"],
                author: e["author"],
                index: e["index"],
                publisher: e["publisher"],
                year: e["publisher"],
                holding: e["holding"],
                lending: e["lending"],
                cover: e["cover_img"],
              )).toList())..add(isLoading ? Container(
                margin: EdgeInsets.fromLTRB(ThemeRegular.cardMargin, ThemeRegular.cardMargin, ThemeRegular.cardMargin, 75),
                decoration: BoxDecoration(
                  color: ThemeRegular.cardBackgroundColor,
                  borderRadius: ThemeRegular.cardRadius,
                ),
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Loading(
                        size: 42,
                        indicator: LineScaleIndicator(),
                        color: ThemeRegular.textColor,
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
                        child: Text("加载中", style: TextStyle(
                          color: ThemeRegular.textColor,
                          fontSize: 15,
                        )),
                      ),
                    ],
                  ),
                ),
              ): Container()),
            ),
          ),
        ),
      ],
    );
  }
}


class LibrarySearchPage extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("图书搜索"),
      ),
      backgroundColor: ThemeRegular.backgroundColor,
      body: _LibrarySearchBody(),
    );
  }
}