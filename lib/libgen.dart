import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class Scraper {
  String url =
      "http://gen.lib.rus.ec/search.php?lg_topic=libgen&open=0&view=simple&res=25&phrase=0&column=title&req=";
  String title;

  Scraper(String title) {
    this.title = title;
    url += this.title;
  }

  Future<String> _getFirstResult() async {
    String getPageURL = "";
    await http.read(url).then((r) {
      Document document = parser.parse(r);
      var table = document.getElementsByTagName("table")[2];
      var attrs = table
          .getElementsByTagName('tr')[1]
          .getElementsByTagName('td')[9]
          .getElementsByTagName('a')[0]
          .attributes;
      getPageURL = attrs['href'];
    });
    return getPageURL;
  }

  Future<String> getURL() async {
    String URL = "";
    String getPageURL = await _getFirstResult();
    await http.read(getPageURL).then((r) {
      Document document = parser.parse(r);
      var h2 = document.getElementsByTagName("h2")[0];
      print(getPageURL);
      print("Length: ${h2.getElementsByTagName('a').length}");
      var attrs = h2.getElementsByTagName('a')[0].attributes;
      URL = attrs['href'];
    });
    print(URL);
    return URL;
  }

  void download() async {
    var source = await getURL();
    print(source);
    try {
      await launch(source);
    } catch (e) {
      print(e.toString());
    }
  }
//    var path = (await getApplicationDocumentsDirectory()).path;
//    var bytes = await http.readBytes(source);
//    File book = new File("$path/$filename");
//    await book.writeAsBytesSync(bytes);

//    HttpClient httpClient = new HttpClient();
//    var request = await httpClient.getUrl(Uri.parse(source));
//    var response = await request.close();
//    var bytes = await consolidateHttpClientResponseBytes(response);
//    String dir = (await getApplicationDocumentsDirectory()).path;
//    File file = new File('$dir/$filename');
//    await file.writeAsBytes(bytes);
//    print('$dir/$filename');

}
