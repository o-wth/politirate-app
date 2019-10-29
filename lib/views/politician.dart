import 'package:flutter/material.dart';
import 'package:politirate/services/api.dart';
import 'package:politirate/widgets/card.dart';
import 'package:transparent_image/transparent_image.dart';
import '../theme/style.dart';

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
          Container(
            margin: EdgeInsets.fromLTRB(16, 32, 0, 0),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: cText),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 64, 32, 32),
            child: PoliticianContent(widget.politicianData)
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

  @override
  void initState() {
    getTweets(widget.politicianData["twitter"]).then((data) {
      setState(() {
        tweetsScore = data["tweetScores"]["totalScore"];
      });
    });
    getNews(widget.politicianData["name"]).then((data) {
      setState(() {
        newsScore = data["totalScore"];
      });
    });
    getTwitterProfileImage(widget.politicianData["twitter"]).then((link) {
      setState(() { profileUrl = link; });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var splitName = widget.politicianData["name"].split(" ");
    return ScrollConfiguration(
      behavior: NoOverScrollBehavior(),
      child: ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${splitName[0]}',
                      style: ThemeText.nameText
                    ),
                    Text(
                        '${splitName[splitName.length-1]}',
                        style: ThemeText.lastName
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      '@${widget.politicianData["twitter"]}',
                      style: ThemeText.subTitle,
                    )
                  ],
                )
              ),
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
                    (profileUrl != null) ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage, image: profileUrl,
                        fit: BoxFit.cover,
                        width: 125,
                        height: 125,
                      )
                    ) : Container(),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 28),
          (tweetsScore != null && newsScore != null) ? ScoreCard(
            tweetsScore: tweetsScore,
            newsScore: newsScore,
          ) : Container()
        ],
      ),
    );
  }
}

class ScoreCard extends StatelessWidget {
  final newsScore, tweetsScore;
  ScoreCard({@required this.newsScore, @required this.tweetsScore})
  : assert(newsScore != null),
    assert(tweetsScore != null);
  @override
  Widget build(BuildContext context) {
    return DataCard(
      child: Table(
        children: [
          TableRow(
            children: <Widget> [
              Center(child: Text("Twitter", style: ThemeText.subTitle,)),
              Center(child: Text("Combined", style: ThemeText.subTitle)),
              Center(child: Text("News", style: ThemeText.subTitle))
            ]
          ),
          TableRow(
            children: <Widget> [
              Center(child: Text("$tweetsScore", style: ThemeText.lastName)),
              Center(child: Text("${(newsScore * 4 + tweetsScore)}", style: ThemeText.lastName)),
              Center(child: Text("$newsScore", style: ThemeText.lastName))
            ]
          )
        ],
      )
    );
  }



}