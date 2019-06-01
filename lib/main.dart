import 'package:attesa_bus/parsing_atac.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:core';

void main() => runApp(new FermateAtacApp());

class FermateAtacApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Tempi di attesa fermata ATAC',
      theme: new ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: new MyHomePage(title: 'Tempi di attesa fermata ATAC'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AtacFermataInfo _info = new AtacFermataInfo();
  TextEditingController _controller = new TextEditingController();

  Future<AtacFermataInfo> readAtacWebSite(String fermata) async {
    HttpClientRequest request = await HttpClient().postUrl(Uri.parse("https://www.atac.roma.it/function/pg_previsioni_arrivo.asp?pa_src=" + fermata));
    HttpClientResponse response = await request.close();

    var temp = await response.transform(utf8.decoder).toList();

    var result = "";

    for (var i = 0; i < temp.length; i++) {
      result += temp[i];
    }

    return AtacPageParser.parse(result);
  }

  void _refreshInfo() {
    var value = _controller.text;

    if (value == "") {
      setState(() {
        _info = new AtacFermataInfo();
      });
    } else {
      readAtacWebSite(value).then((value) {
        setState(() {
          _info = value;
        });
      });
    }
  }

  Future _handleRefresh() async {
    var c = new Completer();
    _refreshInfo();
    c.complete(1);
    return c.future;
  }

  Future _submitted(String value) async {
    await _handleRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.teal[900],
        title: new Text(widget.title),
      ),
      body: new RefreshIndicator(
        onRefresh: _handleRefresh,
      child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _info.Linee.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return new Card(
                child: new Column(
                  children: <Widget>[
                    new ListTile(
                      title: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Inserisci il numero della fermata',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: _refreshInfo,
                        ),
                      ),
                        onSubmitted: _submitted,
                    )),
                    new ListTile(
                      leading: const Icon(Icons.place),
                      title: Text(_info.Nome),
                    )
                  ],
                ),
              );
            }

            var content = new List<Widget>();
            content.add(new Container(
                color: Colors.teal,
                child: new ListTile(
                    leading:
                        const Icon(Icons.directions_bus, color: Colors.white),
                    title: Text(_info.Linee[index - 1].Nome,
                        style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white)))));

            for (var i = 0;
                i < _info.Linee[index - 1].TempiAttesa.length;
                i++) {
              content.add(ListTile(
                  title: Text('${_info.Linee[index - 1].TempiAttesa[i]}')));
            }
            return Card(
                child: new Column(
                    mainAxisSize: MainAxisSize.min, children: content));
          }),
    ));
  }
}
