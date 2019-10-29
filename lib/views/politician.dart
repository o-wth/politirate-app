import 'package:flutter/material.dart';
import 'package:politirate/services/api.dart';
import 'package:politirate/widgets/card.dart';
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

  @override
  void initState() {
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
                        '${splitName[1]}',
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
                  boxShadow: [cardShadow]
                ),
                child: (profileUrl == null) ? Container(
                  width: 125,
                  height: 125,
                  color: cBackground,
                ) : ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    profileUrl,
                    scale: 73/125,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 28),
          DataCard(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "This is where the score will be.",
                    style: ThemeText.subTitle,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}