import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'book.dart';
import 'dart:convert';
import 'libgen.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'dart:async';

void main() {
  runApp(new App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => new _AppState();
}

class _AppState extends State<App> {
  String response = "", URL;
  Scraper scraper;
  TextEditingController textEditingController = new TextEditingController();
  int toDraw = 0; //1 - loading, 2 - only ISBN
  Map details;
  Book book = null;
  String barcode = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void clear() {
    book = null;
    toDraw = 0;
    URL = "";
  }

  void _request(String isbn) {
    setState(() {
      toDraw = 1;
    });
    var url = "https://www.googleapis.com/books/v1/volumes?q=isbn:" + isbn;
    try {
      http.read(url).then((r) {
        setState(() {
          details = json.decode(r);
          if (details["totalItems"] != 0) {
            details = details["items"][(details["totalItems"] - 1)];
            book = new Book(details);
            scraper = new Scraper(book.title);
            //print(details);
          } else
            toDraw = 2;
        });
      });
    } catch (e) {
      print(e.toString());
    } finally {
      print(details);
    }
  }

  Future scan() async {
    try {
      clear();
      barcode = await BarcodeScanner.scan();
      _request(barcode);
      print(barcode);
    } catch (e) {
      print(e.toString());
    }
  }

  void _downloadPressed() {
    scraper.download();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      duration: new Duration(seconds: 8),
      content: new Row(
        children: <Widget>[
          new CircularProgressIndicator(),
          new Text("  Getting the download link...")
        ],
      ),
    ));
  }

  Widget _formResult() {
    if (book != null) {
      return new Card(
        elevation: 2.0,
        child: new ListView(
          shrinkWrap: true,
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Center(
                  child: new Text(
                book.title,
                textScaleFactor: 1.6,
              )),
            ),
            (book.getAuthors() != null)
                ? new Text(
                    "Authors - " + book.getAuthors() + "\n",
                    textScaleFactor: 1.2,
                  )
                : new Container(),
            (book.getCategories() != null)
                ? new Text(
                    "Categories - " + book.getCategories() + "\n",
                    textScaleFactor: 1.2,
                  )
                : new Container(),
            (book.publisher != null)
                ? Text(
                    "Publisher - " + book.publisher + "\n",
                    textScaleFactor: 1.2,
                  )
                : new Container(),
            (book.published != null)
                ? new Text(
                    "Published - " + book.published + "\n",
                    textScaleFactor: 1.2,
                  )
                : new Container(),
            new Text("Description - " + book.description),
            new RaisedButton(
                onPressed: _downloadPressed,
                child: new Text("Download"),
                color: Colors.blueAccent),
          ],
        ),
      );
    } else if (toDraw == 1) {
      toDraw = 0;
      return new CircularProgressIndicator();
    } else if (toDraw == 2) {
      toDraw = 0;
      return new Center(
        child: new Column(
          children: <Widget>[
            new Text(
              "Could not read the barcode properly. ISBN read - $barcode",
              textScaleFactor: 1.6,
            ),
            new TextField(
              controller: textEditingController,
              decoration: new InputDecoration(
                  labelText: "ISBN", hintText: "Type in the ISBN number"),
              keyboardType: TextInputType.number,
            ),
            new RaisedButton(
                onPressed: _buttonPressed, child: new Text("Submit")),
          ],
        ),
      );
    }
    return new Container();
  }

  void _buttonPressed() {
    String isbn = textEditingController.text;
    setState(() {
      textEditingController.clear();
    });
    clear();
    _request(isbn);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: "Books Info",
        home: new Scaffold(
          key: _scaffoldKey,
          appBar: new AppBar(
            title: new Text("Book Info"),
            actions: <Widget>[
              new IconButton(
                  icon: new Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      clear();
                    });
                  })
            ],
          ),
          body: new Container(
            padding: const EdgeInsets.all(10.0),
            child: new Column(
              children: <Widget>[
//                new TextField(controller: textEditingController, decoration: new InputDecoration(labelText: "ISBN"),
//                keyboardType: TextInputType.number,),
                new Center(
                    child: new RaisedButton(
                        onPressed: scan, child: new Text("Scan"))),
                new Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: _formResult(),
                ),
              ],
            ),
          ),
        ));
  }
}
