import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter News App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String _category = "general";

  Future<List> _getNews() async {
    var response = await http.get(Uri.parse(
        "https://newsapi.org/v2/top-headlines?country=us&category=$_category&apiKey=API-KEY"));
    var data = json.decode(response.body);
    return data["articles"];
  }

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text('Could not launch URL'),
                content: Text('Could not launch $url'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _category = "general";
                    });
                  },
                  child: const Text("General"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _category = "business";
                    });
                  },
                  child: const Text("Business"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _category = "technology";
                    });
                  },
                  child: const Text("Technology"),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getNews(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return const Center(child: Text("Loading..."));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: snapshot.data[index]["urlToImage"] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                    snapshot.data[index]["urlToImage"],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover))
                            : null,
                        title: Text(snapshot.data[index]["title"]),
                        subtitle: RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: snapshot.data[index]["publishedAt"] + "\n"),
                          TextSpan(
                              text: snapshot.data[index]["url"],
                              style: const TextStyle(color: Colors.blue),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () =>
                                    _launchUrl(snapshot.data[index]["url"]))
                        ])),
                        onTap: () => _launchUrl(snapshot.data[index]["url"]),
                      );
                    },
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
