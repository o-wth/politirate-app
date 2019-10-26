import 'dart:async' show Future;
import 'dart:convert' show jsonDecode;

import 'package:circular_profile_avatar/circular_profile_avatar.dart'
    show CircularProfileAvatar;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http show get;

import 'politician.dart' show Politician;

class SearchPage extends StatefulWidget {
  static const String tag = '/';
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _ResultCard extends StatefulWidget {
  final String name;
  final SearchDelegate<String> searchDelegate;
  final String twitter;

  _ResultCard({this.name, this.twitter, this.searchDelegate});
  @override
  State<_ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<_ResultCard> {
  Politician politician;
  @override
  Widget build(final BuildContext context) {
    if (politician == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            CircularProfileAvatar(politician.photo, radius: 128),
            Text(
              widget.name,
              style: const TextStyle(fontSize: 48.0),
              textAlign: TextAlign.center,
            ),
            Text(
              politician.chambername,
              style: const TextStyle(fontSize: 24.0),
              textAlign: TextAlign.center,
            ),
            Text(politician.state,
                style: const TextStyle(fontSize: 24.0),
                textAlign: TextAlign.center),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: FloatingActionButton(
                      heroTag: 'party',
                      child: politician.party,
                      onPressed: null,
                    )),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        height: 100.0,
                        width: 100.0,
                        child: FittedBox(
                            child: FloatingActionButton(
                          heroTag: 'score',
                          onPressed: null,
                          child: Text(
                            'Score ' + politician.score.toStringAsFixed(2),
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        )))),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: FloatingActionButton(
                      heroTag: 'contact',
                      child: Icon(
                        Icons.contact_mail,
                        color: Colors.white,
                      ),
                      onPressed: () => showDialog(
                          context: context,
                          builder: (final BuildContext context) => AlertDialog(
                                title: const Text('Contact Information'),
                                content:
                                    Text("""Phone Number: ${politician.phone}
"""),
                              )),
                    ))
              ],
            ),
            const Text(
              'Recent News:',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: politician.threeStories.length,
              itemBuilder: (final BuildContext context, final int index) =>
                  Card(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(politician.threeStories[index])),
                margin: const EdgeInsets.all(8.0),
                color: Colors.white70,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _SearchDelegate extends SearchDelegate<String> {
  List<dynamic> _suggestions;

  _SearchDelegate();
  @override
  List<Widget> buildActions(final BuildContext context) {
    return <Widget>[
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(final BuildContext context) {
    return IconButton(
        tooltip: 'Back',
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () => close(context, null));
  }

  Future<List<dynamic>> makeQuery(final String query) async {
    return jsonDecode((await http.get(
            'https://politirate-api.sites.tjhsst.edu/api/get_politicians/?name=${query}'))
        .body);
  }

  @override
  Widget buildResults(final BuildContext context) {
    if (_suggestions?.isEmpty ?? true) {
      return const Center(child: Text('No Results'));
    }
    return FutureBuilder(
        future: makeQuery(query),
        builder:
            (final BuildContext context, final AsyncSnapshot<List<dynamic>> list) =>
                ListView(
                    children: list.data
                        .map<Widget>((final dynamic politicianInfo) => _ResultCard(
                            name: politicianInfo['name'],
                            twitter: politicianInfo['twitter'],
                            searchDelegate: this))
                        .toList()));
  }

  @override
  Widget buildSuggestions(final BuildContext context) {
    return FutureBuilder(
        future: makeQuery(query),
        builder:
            (final BuildContext context, final AsyncSnapshot<List<dynamic>> list) =>
                _SuggestionList(
                    query: query,
                    suggestions: list.data
                        .map<String>((final dynamic politicianInfo) =>
                            politicianInfo['name'])
                        .toList(),
                    onSelected: (final String suggestion) {
                      query = suggestion;
                      showResults(context);
                    }));
  }
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(final BuildContext context) {
    final Widget search = RaisedButton(
      child: const Text('Search all Politicians'),
      onPressed: () =>
          showSearch(context: context, delegate: _SearchDelegate()),
    );
    return Scaffold(
        appBar: AppBar(
            title: Text(
          'Politi-Rate',
          style: TextStyle(color: Colors.white),
        )),
        body: Center(child: search));
  }
}

class _SuggestionList extends StatelessWidget {
  final List<String> suggestions;

  final String query;
  final ValueChanged<String> onSelected;
  const _SuggestionList({this.suggestions, this.query, this.onSelected});

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (final BuildContext context, final int index) {
        final String suggestion = suggestions[index];
        final String lowQuery = query.toLowerCase(),
            lowSuggestion = suggestion.toLowerCase();
        print(lowQuery);
        return ListTile(
          leading: query.isEmpty ? const Icon(Icons.person) : const Icon(null),
          title: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                    text: suggestion.substring(
                        0, lowSuggestion.indexOf(lowQuery)),
                    style: theme.textTheme.subhead),
                TextSpan(
                  text: suggestion.substring(lowSuggestion.indexOf(lowQuery),
                      lowSuggestion.indexOf(lowQuery) + query.length),
                  style: theme.textTheme.subhead
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                    text: suggestion.substring(
                        lowSuggestion.indexOf(lowQuery) + query.length),
                    style: theme.textTheme.subhead)
              ],
            ),
          ),
          onTap: () => onSelected(suggestion),
        );
      },
    );
  }
}
