import 'package:flutter/material.dart' show Image;

class Politician {
  final String fullName;
  final String photo;
  final Image party;
  final double score;
  final List<String> threeStories;
  final String phone;
  final String chambername;
  final String state;

  Politician.fromJson(final this.fullName, final Map<String, dynamic> json)
      : score = (json['score'] / 118.0),
        photo = json['profile_picture'],
        threeStories = json['threeStories'].cast<String>(),
        phone = json['phone'],
        party = Image.asset(
          json['party'] == 'Democrat'
              ? 'assets/democratic.png'
              : 'assets/republican.png',
        ),
        chambername = json['chambername']
            .replaceAll(RegExp(r'sen$'), 'Senator')
            .replaceAll(RegExp(r'rep$'), 'Representative'),
        state = json['state'];

  Map<String, dynamic> toJson() =>
      {'fullName': fullName, 'score': score, 'threeStories': threeStories};

  String toString() => toJson().toString();
}
