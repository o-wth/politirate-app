import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:politirate/configs/endpoints.dart';
import 'package:politirate/services/api.dart';
import '../theme/style.dart';

class SearchPage extends StatefulWidget {

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            color: cBackground,
            width: 100,
            height: size.height,
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: HomeContent()
            ),
          )
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: NoOverScrollBehavior(),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Text("Politirate", style: ThemeText.pageTitle),
          SizedBox(height: 2.0),
          Text(
              "A free and open source platform evaluating politicians and their social media presence through sentiment and language analysis"),
          SizedBox(height: 13.0),
          RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            onPressed: () {
              showSearch(context: context, delegate: PoliticianSearch());
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 12.0, horizontal: 8.0),
              child: Text(
                "Start Searching!",
                style: ThemeText.buttonText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PoliticianSearch extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.clear), onPressed: (){
        query = "";
      })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return null;
  }


  @override
  Widget buildSuggestions(BuildContext context) {
    var finalList  = [
      "George Washington",
      "Abraham Lincoln",
      "Donald Trump"
    ];
    var endpoint = GET_POLITICIAN_ENDPOINT;
    var queryParams = {
      "name": query
    };
    return FutureBuilder(
      future: getAPIResponseFromEndpoint(endpoint: endpoint, queryParams: queryParams),
      builder: (context, snapshot) {
        switch(snapshot.connectionState) {
          case ConnectionState.none:
            return ListTile(title: Text("Search something!"));
          case ConnectionState.active:
          case ConnectionState.waiting:
            return ListTile(title: Text("Loading..."));
          case ConnectionState.done:
            if(snapshot.hasError)
              return Text("Oops! An error occured");
            return ListView.builder(
              itemBuilder: (context, index) => ListTile(
                title: Text(snapshot.data[index]["name"]),
                onTap: () {},
              ),
              itemCount: snapshot.data.length,
            );
        } return null;
      },
    );
  }
}