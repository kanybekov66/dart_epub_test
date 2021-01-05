import 'package:flutter/material.dart';
import 'package:epub/epub.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lipsum/lipsum.dart' as lipsum;
import 'package:span_builder/span_builder.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _counter = 'name';

  EpubBook _book;
  String _bookName;
  String _bookAuthor;
  List<String> _bookChapters;
  List<String> _bookContent;

  void _loadBook() async {
    String fileName = 'assets/Dialoghi-Platon.epub';
    ByteData bytes = await rootBundle.load(fileName);
    print('bytes: $bytes');
    final buffer = bytes.buffer;
    List<int> listInt =
        buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    EpubBook epubBook = await EpubReader.readBook(listInt);
    print(epubBook.Chapters);
    print(epubBook.Content.AllFiles);
    setState(() {
      _counter = epubBook.Title;
    });
  }

  // <p class="head"> dawdasdawdasdawdadadawdawdawd awd awd awda <em>asdklhjaklsjdha</em> </p>

  _showPopupMenu() {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(1000.0, 1000.0, 1000.0, 1000.0),
      //position where you want to show the menu on screen
      items: [
        PopupMenuItem<String>(child: const Text('Русский'), value: '1'),
        PopupMenuItem<String>(child: const Text('Кыргызча'), value: '2'),
        PopupMenuItem<String>(child: const Text('Türkçe'), value: '3'),
        PopupMenuItem<String>(child: const Text('Қазақша'), value: '4'),
      ],
      elevation: 8.0,
    ).then<void>((String itemSelected) {
      if (itemSelected == null) return;
    });
  }

  // textSize = default * (.css/.p/{font-size} )

  ///генератор текста
  List<String> _text =
      lipsum.createText(numParagraphs: 10, numSentences: 10).split(" ");

  // List<String> _text = "Моя фывыф фыв ф фыв фывф в фы фы моя фыв ффыв фыфы  фыв".split(" ");

  ///лист из спанов, на случай если виджет не принимает просто текст
  ///каждое слово лежит в отдельном TextSpan(text:'текст')
  List<TextSpan> textSpanList = new List<TextSpan>();
  List<String> list;

  List<TextSpan> parseText() {
    print('TEXT SPLIT: $list');
    ///перекачиваем слова из текста в лист из TextSpan'ов
    _text.forEach((e) => {textSpanList.add(new TextSpan(text: e))});
    // print('TEXT SPANS: $textSpanList');
  }

  ///константный размер текста
  double _textSize = 14;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book"),
      ),
      body: Center(
          child: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              ///Spanbuilder который из стринга делает спаны
              child: SpanBuilderWidget(
                /// justify - разных размеров пробелы между словами
                /// для того, чтобы текста был впритык слева и справа
                textAlign: TextAlign.justify,
                /// максимальное кол-во строк
                // maxLines: 20,
                /// соотношение размера текста
                textScaleFactor: 1,
                /// сам билдер, который моздает СПАНы из _text.toString()
                /// _text.toString делаем потому, что _text это массив из строк
                /// а билдер принимает в себя одну строку
                text: SpanBuilder((_text.toString()))
                /// ..apply(TextSpan(...)... это изменение конкретного слова под
                /// заданную стилистику)
                  ..apply(
                      TextSpan(
                          text: _text[0],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: _textSize + 10,
                          )),
                      onTap: () => {
                        print("weeeee text[0]")
                      })
                  ..apply(TextSpan(
                      text: _text[5],
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.orange))
                  ),
                defaultStyle:
                    TextStyle(
                      color: Colors.black,
                        fontSize: _textSize
                    ),
              ),
            ),
          ),
          Center(
            child: SelectableText(
              "Somae asd a asda w  asdjkhasgdkj k ka ksjhd awa sd a",
              showCursor: true,
              onTap: () => {parseText(), print(textSpanList)},
            ),
          )
        ],
      )),
    );
  }
}
