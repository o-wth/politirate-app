// import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:politirate/services/api.dart';
import 'package:politirate/widgets/card.dart';
import 'package:transparent_image/transparent_image.dart';
import '../theme/style.dart';
import 'package:flutter/services.dart';

class Politician extends StatefulWidget {
  final politicianData;

  Politician(this.politicianData) : assert(politicianData != null);

  @override
  PoliticianState createState() => PoliticianState();
}

class PoliticianState extends State<Politician> {
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
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: Container(child: PoliticianContent(widget.politicianData))
          ),
          Container(
            margin: EdgeInsets.only(left: 16.0, top: 32.0),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: cText),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
            ),
          )
        ],
      ),
    );
  }
}

class PoliticianContent extends StatefulWidget {
  final politicianData;

  PoliticianContent(this.politicianData) : assert(politicianData != null);

  @override
  PoliticianContentState createState() => PoliticianContentState();
}

class PoliticianContentState extends State<PoliticianContent> {
  var profileUrl;
  var tweets, news;
  var newsScore, tweetsScore;
  var dateOfBirth;
  var party;
  var state;

  @override
  void dispose() {
    profileUrl = null;
    super.dispose();
  }

  @override
  void initState() {
    getTweets(widget.politicianData["twitter"]).then((data) {
      setState(() {
        tweets = data["tweetScores"]["tweets"];
        tweetsScore = data["tweetScores"]["totalScore"] / tweets.length;
      });
    });
    getNews(widget.politicianData["name"]).then((data) {
      setState(() {
        news = data["articles"];
        newsScore = data["totalScore"] / news.length;
      });
    });
    getTwitterProfileImage(widget.politicianData["twitter"]).then((link) {
      setState(() {
        profileUrl = link;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: NoOverScrollBehavior(),
      child: ListView(
        addRepaintBoundaries: false,
        children: <Widget>[
          SizedBox(height: 64),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.politicianData['firstName'],
                      style: ThemeText.nameText),
                  Text(widget.politicianData['lastName'],
                      style: ThemeText.lastName),
                  SizedBox(height: 4.0),
                  Text(
                    '@${widget.politicianData["twitter"]}',
                    style: ThemeText.subTitle,
                  )
                ],
              )),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [cardShadow],
                ),
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: 125,
                      height: 125,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: cBackground,
                      ),
                    ),
                    (profileUrl != null)
                        ? InkWell(
                            onTap: () async {
                              await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SimpleDialog(
                                      title: const Text('Politician Info'),
                                      children: <Widget>[
                                        SimpleDialogOption(
                                            child: Text('Date of Birth: ' +
                                                DateFormat.yMMMMd("en_US")
                                                    .format(DateTime.parse(
                                                        widget.politicianData[
                                                            'dob'])))),
                                        SimpleDialogOption(
                                          child: Text('Political Party: ' +
                                              widget.politicianData['party']),
                                        ),
                                        SimpleDialogOption(
                                            child: Text('State: ' +
                                                widget
                                                    .politicianData['state'])),
                                        SimpleDialogOption(
                                            child: const Text(
                                                '\nAll information is based on this politician\'s latest political term.'))
                                      ],
                                    );
                                  });
                            },
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: profileUrl,
                                  fit: BoxFit.cover,
                                  width: 125,
                                  height: 125,
                                )))
                        : Container(),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 28),
          (tweetsScore != null && newsScore != null)
              ? ScoreCard(
                  tweetsScore: tweetsScore,
                  newsScore: newsScore,
                  tweets: tweets,
                  news: news,
                )
              : Container(),
          SizedBox(height: 24),
          (news != null && tweets != null)
              ? IndividualRatings(
                  title: Text("Results", style: ThemeText.medTitle),
                  news: news,
                  tweets: tweets,
                )
              : Container()
        ],
      ),
    );
  }
}

class ScoreCard extends StatelessWidget {
  final newsScore, tweetsScore, news, tweets, finalScore;

  ScoreCard(
      {@required this.newsScore,
      @required this.tweetsScore,
      @required this.news,
      @required this.tweets})
      : assert(newsScore != null),
        assert(tweetsScore != null),
        assert(news != null),
        assert(tweets != null),
        finalScore = newsScore * 2 + tweetsScore * .25;

  @override
  Widget build(BuildContext context) {
    return DataCard(
        child: Table(
      children: [
        TableRow(children: <Widget>[
          Center(child: Text("Twitter", style: ThemeText.subTitle)),
          Center(child: Text("Combined", style: ThemeText.subTitle)),
          Center(child: Text("News", style: ThemeText.subTitle))
        ]),
        TableRow(children: <Widget>[
          Center(
              child: Text("${tweetsScore.toStringAsFixed(2)}",
                  style: ThemeText.lastName.copyWith(
                    color: getErrorColor(tweetsScore),
                  ))),
          Center(
              child: Text("${finalScore.toStringAsFixed(2)}",
                  style: ThemeText.lastName.copyWith(
                    color: getErrorColor(finalScore),
                  ))),
          Center(
              child: Text("${newsScore.toStringAsFixed(2)}",
                  style: ThemeText.lastName.copyWith(
                    color: getErrorColor(newsScore),
                  )))
        ])
      ],
    ));
  }
}

class IndividualRatings extends StatelessWidget {
  final Widget title;
  final news, tweets;
  IndividualRatings(
      {@required this.title, @required this.news, @required this.tweets})
      : assert(title != null),
        assert(news != null),
        assert(tweets != null);

  List<Widget> _generateListingNews(List array) {
    List<Widget> res = array.map((data) {
      return ListTile(
        title: Row(
          children: <Widget>[
            Expanded(
                child: Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text('${data["title"]}'))),
            Text('${data["score"]}',
                style: ThemeText.subTitle
                    .copyWith(color: getErrorColor(data["score"])))
          ],
        ),
      );
    }).toList();
    return res;
  }

  List<Widget> _generateListingTweets(List array) {
    List<Widget> res = array.map((data) {
      return ListTile(
        title: Row(
          children: <Widget>[
            Expanded(
                child: Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text('${data["text"]}'))),
            Text('${data["score"]}',
                style: ThemeText.subTitle
                    .copyWith(color: getErrorColor(data["score"])))
          ],
        ),
      );
    }).toList();
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return new DataCard(
        child: Column(
      children: <Widget>[
        Center(child: title),
        SizedBox(height: 12),
        Theme(
          data: Theme.of(context)
              .copyWith(primaryColor: cText, accentColor: cText),
          child: ExpansionTile(
            initiallyExpanded: false,
            title: Text("News", style: ThemeText.subTitle),
            children: _generateListingNews(news),
          ),
        ),
        Theme(
          data: Theme.of(context)
              .copyWith(primaryColor: cText, accentColor: cText),
          child: ExpansionTile(
            initiallyExpanded: false,
            title: Text("Tweets", style: ThemeText.subTitle),
            children: _generateListingTweets(tweets),
          ),
        )
      ],
    ));
  }
}
