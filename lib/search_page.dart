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

  void fetchPolitician() async {
    final Uri uri =
        Uri.https('pacific-everglades-42005.herokuapp.com', '/politician', {
      'fullname': widget.name,
      'twitterhandle': widget.twitter,
    });
    politician = Politician.fromJson(
        widget.name, jsonDecode((await http.get(uri)).body));
    print(politician);
    setState(() {});
  }

  @override
  initState() {
    super.initState();
    fetchPolitician();
  }
}

class _SearchDelegate extends SearchDelegate<String> {
  final Map<String, String> politicians;
  _SearchDelegate({@required final this.politicians});
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

  @override
  Widget buildResults(final BuildContext context) {
    if (!politicians.keys.contains(query)) {
      return const Center(child: Text('No Results'));
    }
    return ListView(
      children: <Widget>[
        _ResultCard(
            name: query, twitter: politicians[query], searchDelegate: this)
      ],
    );
  }

  @override
  Widget buildSuggestions(final BuildContext context) {
    final Iterable<String> suggestions = query.isEmpty
        ? politicians.keys.toList()
        : politicians.keys
            .where((final String test) =>
                test.toLowerCase().contains(query.toLowerCase()))
            .toList();
    return _SuggestionList(
        query: query,
        suggestions: suggestions,
        onSelected: (final String suggestion) {
          query = suggestion;
          showResults(context);
        });
  }
}

class _SearchPageState extends State<SearchPage> {
  Map<String, String> _politicians = Map<String, String>();
  Widget _localPoliticians;
  bool _loading = true;
  @override
  Widget build(final BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final Widget search = RaisedButton(
      child: const Text('Search all Politicians'),
      onPressed: () => showSearch(
          context: context,
          delegate: _SearchDelegate(politicians: _politicians)),
    );
    return Scaffold(
        appBar: AppBar(
            title: Text(
          'Politi-Rate',
          style: TextStyle(color: Colors.white),
        )),
        body: Column(
          children: <Widget>[_localPoliticians, SizedBox(height: 64.0), search],
          mainAxisAlignment: MainAxisAlignment.center,
        ));
  }

  void fetchPoliticians() async {
    final List<dynamic> congressNamesParsed = jsonDecode((await http.get(
            'https://theunitedstates.io/congress-legislators/legislators-current.json'))
        .body);
    final List<dynamic> congressSocialsParsed = jsonDecode((await http.get(
            'https://theunitedstates.io/congress-legislators/legislators-social-media.json'))
        .body);
    // Geolocator geolocator = Geolocator();
    // Position location = await geolocator.getCurrentPosition();
    // print(location);
    // Placemark address = (await geolocator.placemarkFromCoordinates(
    //     location.latitude, location.longitude))[0];
    final List<dynamic> phone2actionData = jsonDecode((await http.get(
            'https://fmrrixuk32.execute-api.us-east-1.amazonaws.com/hacktj/legislators?address=Virginia',
            // 'https://fmrrixuk32.execute-api.us-east-1.amazonaws.com/hacktj/legislators?address=${address.administrativeArea}',
            headers: {'x-api-key': 'ie5EtNqb2pafUpw0FsMC84hHqrW9L4uf2Ql9YTJF'}))
        .body)['officials'];
    _localPoliticians = Column(children: <Widget>[
      Text('Local Politicians:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36.0)),
      ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: phone2actionData.length,
          itemBuilder: (final BuildContext context, final int index) => Text(
                phone2actionData[index]['first_name'] +
                    ' ' +
                    phone2actionData[index]['last_name'],
                style: TextStyle(fontSize: 24.0),
                textAlign: TextAlign.center,
              ))
    ]);
    phone2actionData.forEach((final dynamic f) {
      f['socials'].forEach((final dynamic social) {
        if (social['identifier_type'] == 'TWITTER') {
          _politicians.putIfAbsent(f['first_name'] + ' ' + f['last_name'],
              () => social['identifier_value']);
        }
      });
    });
    congressNamesParsed.forEach((final dynamic f) {
      int index = congressSocialsParsed.indexWhere((final dynamic test) =>
          test['id']['bioguide'] == f['id']['bioguide']);
      if (0 <= index && index < congressSocialsParsed.length) {
        _politicians.putIfAbsent(f['name']['official_full'],
            () => congressSocialsParsed[index]['social']['twitter']);
      }
    });
    setState(() {
      _loading = false;
      _politicians = Map<String, String>.from(_politicians);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchPoliticians();
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
